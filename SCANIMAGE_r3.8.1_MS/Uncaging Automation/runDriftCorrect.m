function runDriftCorrect(varargin)
%RUNDRIFTCORRECT(VARARGIN) runs drift correction and autofocus
% runDriftCorrect is the rebuilt form of run_AF. It is called when
% autofocus and drift correct runs.
%
% Inputs:
%
% 'LowResolution' , true or false(default). Determines if resolution needs
% to be lowered for autofocus routine.
%
% 'PosID' , indicates position for which autofocus is calculated. Default:
% current position.
%
% 'LiveAutofocus' , true/false. Overrides the default behavior and
% indicates that a round of images are collected and autofocus is run.
%
% 'BeforeUA' , true/false(default) indicates whether the autofocus is
% running manually for each position in the uncaging automation position
% set
%
% 'ShiftZPosition' , true/false. Overrides the default behavior to update
% the Z position after autofocus has calculated it.
global dia state af

if ~af.params.isAFon && ~af.drift.on %check if autofocus or drift is on
    return
end

%set all parameters
model = localGetDefaultModel;
if length(varargin)>1
    for n = 1:2:length(varargin)
        switch(lower(varargin{n}))
            case 'lowresolution'
                model.lowresolution = varargin{n+1};
            case 'posid'
                model.posID = varargin{n+1};
            case 'liveautofocus'
                model.liveautofocus = varargin{n+1};
            case 'beforeua'
                model.beforeUA = varargin{n+1};
                if model.beforeUA
                    model.liveautofocus = true;
                end
            case 'shiftzposition'
                model.moveToZ = varargin{n+1};
        end
    end
end

model.channel = af.params.channel;
model.imSize = [state.acq.pixelsPerLine,state.acq.linesPerFrame];
switch af.params.mode %single or multimode imaging
    case 'singleMode'
        model.multiMode=false;
    case 'multiMode'
        model.multiMode=true;
end
switch af.drift.mode %scan shift or motor XY drift correction
    case 'motorDriftMode'
        model.driftMotor=true;
    case 'scanDriftMode'
        model.driftMotor=false;
end
if isfield(af,'closestspine') && ~isempty(af.closestspine) %set ROI for autofocus if closestspine values are present
    model.afRoi=[af.closestspine.x1-af.roisize/2,af.closestspine.y1-af.roisize/2,af.roisize,af.roisize];
else
    model.afRoi=[];
end

%Run Autofocus
if model.liveautofocus
    newAbsZ = liveAFscan(model);
else
    newAbsZ = acquiredAF(model);
end

if model.moveToZ %move to new Z after calculation
    motorOrETLMove([state.motor.absXPosition state.motor.absYPosition newAbsZ],'verify');
end

%------------------------------------------%
function model = localGetDefaultModel
global af
model.lowresolution = false;
model.posID = [];
model.liveautofocus = ~af.params.useAcqForAF;
model.beforeUA = false;
model.moveToZ = false;

%------------------------------------------%
function newAbsZ = liveAFscan(model)
%liveAFscan changes the Z position and takes images instead of
%collecting acquired images
global af dia ua state gh
% clear previous values
af.focusvalue=[];
af.images=[];
af.position=[];
if isfield(ua,'zoomscale')
    zoomscale=ua.zoomscale;
else
    zoomscale=1;
end

%lower resolution
if model.lowresolution
    changeRes(1);
    model.afRoi=[];
end

if model.beforeUA && ua.zoomedOut % use center of image when image is zoomed out
    rw=model.imSize(1)/(zoomscale/2);
    rh=model.imSize(2)/(zoomscale/2);
    model.afRoi=round([model.imSize(1)/2-rw/2, model.imSize(2)/2-rh/2, rw, rh]);
end
% get current position
xyzPos = dia.hPos.getMotorAndEtlPosition;
af.position.origin_abs = xyzPos;

%set proper z step info
if model.beforeUA && ~ua.zoomedOut %if focusing after zoomed out focus, set normal z slice amount
    updateCurrentImage(model.channel,2); %collect images
else
    %use z slice and step size from autofocus options
    numberOfZSlices = state.acq.numberOfZSlices;
    zStepSize = state.acq.zStepSize;
    state.acq.zStepSize=af.params.zstep;
    set(gh.motorControls.etNumberOfZSlices,'String',num2str(af.params.scancount));
    motorControls('etNumberOfZSlices_Callback',gh.motorControls.etNumberOfZSlices);
    updateNumberOfZSlices(gh.motorControls.etNumberOfZSlices);
    set(gh.motorControls.etZStepPerSlice,'String',num2str(af.params.zstep));
    motorControls('etZStepPerSlice_Callback',gh.motorControls.etZStepPerSlice);
    updateCurrentImage(model.channel,2); %collect images
    %reset z step info
    state.acq.numberOfZSlices = numberOfZSlices;
    state.acq.zStepSize = zStepSize;
    set(gh.motorControls.etNumberOfZSlices,'String',num2str(numberOfZSlices));
    motorControls('etNumberOfZSlices_Callback',gh.motorControls.etNumberOfZSlices);
    set(gh.motorControls.etZStepPerSlice,'String',num2str(zStepSize));
    motorControls('etZStepPerSlice_Callback',gh.motorControls.etZStepPerSlice);
end

if model.beforeUA && ua.zoomedOut %use zoomed out ref image
    %%%%%%%%%%%%% THIS POSID VALUE MAY BE MISSING???%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Iref=dia.hPos.allPositionsDS.refImgZoomOut{dia.hPos.allPositionsDS.posID==model.posID};
    imageArray = zeros([size(Iref),length(af.images)]);
    for i = 1:length(af.images)
        imageArray(:,:,i) = af.images{i};
    end
    [ind, sx, sy, ccShift] = focusUsingReference(imageArray,Iref);
    af.focusvalue = ccShift;
    af.bestfocus = ind;
    af.bestFocusAbsZ = af.position.af_list_abs_z(ind);
    cont_driftCorrect(model,af.bestFocusAbsZ,sx,sy);
else %run regular autofocus routine
    for i=1:length(af.images)
        af.focusvalue(i)=fmeasure(af.images{i},af.algorithm.operator,model.afRoi);
    end
    [~, af.bestfocus] = max(af.focusvalue);
    af.bestFocusAbsZ = af.position.af_list_abs_z(af.bestfocus);
    % Update position, move to drift correct, or move to new position and
    % verify the coordinates
    
    if af.drift.on
        [ shiftx, shifty ] = getDriftInfo(model);
        cont_driftCorrect(model,af.bestFocusAbsZ,shiftx,shifty);
    elseif     model.multiMode
        updateUAposition(model.posID,af.bestFocusAbsZ);
    else
        motorOrETLMove([af.position.origin_abs(1) af.position.origin_abs(2) af.bestFocusAbsZ],'verify');
    end
end
newAbsZ = af.bestFocusAbsZ;

displayAFimages;

if model.lowresolution%reinstate old resolution
    changeRes(0);
end



function newAbsZ = acquiredAF(model)
global dia af state ua

if af.params.isAFon
    if af.drift.on && ua.drift.useMaxProjection %run drift correction first so ROI is shifted appropriately
        [ shiftx, shifty ] = getDriftInfo(model);
        model.afRoi = [model.afRoi(1) - shiftx, model.afRoi(2) - shifty, model.afRoi(3), model.afRoi(4)];
    end
    af.focusvalue=[];
    for i=1:length(af.images)
        af.focusvalue(i)=fmeasure(af.images{i},af.algorithm.operator,model.afRoi);
    end
    [~,af.bestfocus]=max(af.focusvalue); 
    newAbsZ=af.position.af_list_abs_z(af.bestfocus);
else
    newAbsZ=state.motor.absZPosition;
end
if af.drift.on % if drift correction is on, set all 3 positions. if not, set just z.
    if ~ua.drift.useMaxProjection %if drift wasn't calculated earlier based on max projection
        [ shiftx, shifty ] = getDriftInfo(model);
    end
    cont_driftCorrect(model,newAbsZ,shiftx,shifty);
else
    if ua.params.fovModeOn
        updateUAposition(model.posID,newAbsZ);
    else
        motorOrETLMove([state.motor.absXPosition state.motor.absYPosition newAbsZ],'verify');
    end
end
displayAFimages(af.images,af.position,model.afRoi);

function [ shiftx, shifty ] = getDriftInfo(model)
global af state ua dia

%set test image
if af.params.isAFon
    if ~ua.drift.useMaxProjection || ~af.params.useAcqForAF %use single slice
        I=af.images{af.bestfocus};
    else %use max projection
        I = getLastAcqImage( model.channel,1 );
    end
else %if AF us off
    if ua.drift.useMaxProjection
        I = getLastAcqImage( model.channel,1 );
    elseif state.acq.averaging
        I = getLastAcqImage( model.channel,0 );
    else
        I=state.acq.acquiredData{2}{model.channel};
    end
end
%set reference image
if model.multiMode
    if ua.zoomedOut %set reference image
        Iref=dia.hPos.allPositionsDS.refImgZoomOut{dia.hPos.allPositionsDS.posID==model.posID};
    else
        Iref=dia.hPos.allPositionsDS.refImg{dia.hPos.allPositionsDS.posID==model.posID};
    end
else
    try
        Iref=af.drift.Iref; %single reference image
    catch
        disp('Warning - Reference Image for drift correction not set. Using first acquired image as reference');
        af.drift.Iref = I;
        Iref = I;
    end
end
[ shiftx, shifty ] = computeDrift(Iref,I);




function [ shiftx, shifty ]  = cont_driftCorrect(model,newAbsZ,shiftx,shifty)
global af state ua dia
%store drift correction info and/or move to new coordinates

if model.multiMode % multiple positions
    if model.driftMotor %this doesn't actually update the xy drift...
        scale=af.drift.scale;
        af.motorshift.x=(round(shiftx/scale*10))/10;
        af.motorshift.y=(round(shifty/scale*10))/10;
        motorOrETLMove([state.motor.absXPosition+af.motorshift.x state.motor.absYPosition+af.motorshift.y newAbsZ],'verify');
        updateUAposition(model.posID);
        disp(['Drift (x,y) corrected by: ' num2str(af.motorshift.x) ' , ' num2str(af.motorshift.y)]);
        disp('WARNING: DRIFT CORRECTION SHOULD BE IN SCAN SHIFT MODE. IT MAY NOT GET UPDATED PROPERLY IN MOTOR MODE');
    elseif ua.params.fovModeOn
        if isfield(ua,'zoomscale')
            zoomscale=ua.zoomscale;
        else
            zoomscale=1;
        end
        pos=[model.imSize(2)/2-shiftx, model.imSize(1)/2-shifty, 0, 0];
        [ssF, ssS, ~, ~, ~, ~]=scanShiftCalc(pos, ua.params.initialZoom/zoomscale, model.imSize);
        updateUAposition(model.posID,newAbsZ,[ssF,ssS]);
    end
elseif ~model.multiMode %single position mode
    
    if model.driftMotor
        scale=af.drift.scale;
        af.motorshift.x=(round(shiftx/scale*10))/10;
        af.motorshift.y=(round(shifty/scale*10))/10;
        motorOrETLMove([state.motor.absXPosition+af.motorshift.x state.motor.absYPosition+af.motorshift.y newAbsZ],'verify');
        disp(['Drift (x,y) corrected by: ' num2str(af.motorshift.x) ' , ' num2str(af.motorshift.y)]);
    else %scanShift mode
        pos=[model.imSize(1)/2-shiftx, model.imSize(2)/2-shifty, 0, 0];
        [ssF, ssS, ~, ~, ~, ~]=scanShiftCalc(pos, state.acq.zoomFactor, model.imSize);
        state.acq.scanShiftFast=state.acq.scanShiftFast+ssF;
        state.acq.scanShiftSlow=state.acq.scanShiftSlow+ssS;
        updateGUIByGlobal('state.acq.scanShiftFast');
        updateGUIByGlobal('state.acq.scanShiftSlow');
        setupAOData; %needed to reset scanning shift
        motorOrETLMove([state.motor.absXPosition state.motor.absYPosition newAbsZ],'verify');
    end
end


function changeRes(lowerRes)
global state
persistent pixelsLines

if lowerRes
    pixelsLines(1)=state.acq.pixelsPerLine;
    pixelsLines(2)=state.acq.linesPerFrame;
    state.acq.pixelsPerLine=32;
    state.acq.linesPerFrame=32;
else
    state.acq.pixelsPerLine=pixelsLines(1);
    state.acq.linesPerFrame=pixelsLines(2);
    clear('pixelsLines');
end
applyConfigurationSettings;

