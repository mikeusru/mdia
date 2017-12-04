function run_AF( command,lowRes,posID )
%run_AF runs the AF either on the previously acquired images or takes new
%images and runs AF using them. it is called from waitForLoopRepeat as soon
%as the countdown starts. the potential input is a command
%for what kind of autofocus to do. 'UA' runs the autofocus once on the
%current position using the Focus button and assumes it's called from the UA
%loop
% lowRes tells scanimage to set a lower resolution for the autofocusing
% procedure

global state gh af ua dia
%%
logActions;
try
    if ~af.params.isAFon && ~af.drift.on %check if autofocus or drift is on
        return
    end
    
    if nargin<2 || isempty(lowRes)
        lowRes=false;
    end
    
    if nargin<1 || isempty(command)
        command=[];
    end
    
    if nargin<3
        posID=[];
    end
    
    channel=af.params.channel;
    
    switch af.params.mode
        case 'singleMode'
            multiMode=false;
        case 'multiMode'
            multiMode=true;
    end
    switch af.drift.mode
        case 'motorDriftMode'
            driftMotor=true;
        case 'scanDriftMode'
            driftMotor=false;
    end
    
    if isfield(af,'closestspine') && ~isempty(af.closestspine) %set ROI for autofocus if closestspine values are present
        afRoi=[af.closestspine.x1-af.roisize/2,af.closestspine.y1-af.roisize/2,af.roisize,af.roisize];
    else
        afRoi=[];
    end
    
    imsize=[state.acq.pixelsPerLine,state.acq.linesPerFrame];
    
    
    if  strcmp(command,'beforeUA') || strcmp(command,'test')
        liveAFscan;
        
    elseif af.params.useAcqForAF || (~af.params.isAFon && af.drift.on) % MISHA - 1-30-15 - run AF and drift correct using aquired images
        acquiredAF;
        
    elseif  af.params.isAFon && ~af.params.useAcqForAF && ~multiMode %autofocus in single position without using acquired images
        af.timing=state.internal.repeatCounter/af.params.frequency;
        if mod(af.timing,1)==0 ... % check to see if set repeat frequency coincides with current repeat counter (if one divided by the other is an integer)
                && af.counter < af.timing ... % make sure autofocus hasn't been done for this round yet
                && state.internal.repeatCounter > 0 ... %make sure more than 0 repeats have been done. not sure if this is necessary but just in case...
                && ~state.cycle.cycleOn %cycling mode is not on
            if state.internal.looping % pause loop mode
                state.internal.loopPaused=1;
            end
            %If using FLIM, turn off FLIM for autofocus and then turn it back
            %on
            setFLIM=0;
            if state.spc.acq.spc_takeFLIM
                set(gh.spc.FLIMimage.flimcheck,'Value',0);
                FLIMimage('flimcheck_Callback',gh.spc.FLIMimage.flimcheck);
                setFLIM=1;
            end
            af.active=1; %set autofocus to active
            liveAFscan; %run autofocus in different positions;
            %% update autofocus counter
            af.counter=af.counter+1;
            af.active=0; %set autofocus to inactive
            %reset FLIM if necessary
            if setFLIM
                set(gh.spc.FLIMimage.flimcheck,'Value',1);
                FLIMimage('flimcheck_Callback',gh.spc.FLIMimage.flimcheck);
            end
            %resume looping sequence
            abortFocus;
           
        end
    end
    
catch ME
    disp(getReport(ME));
    throw(ME);
end
%%
    function liveAFscan
        %liveAFscan changes the Z position and takes images instead of
        %collecting acquired images
        
        % clear previous values
        af.focusvalue=[];
        af.images=[];
        af.position=[];
        if isfield(ua,'zoomscale')
            zoomscale=ua.zoomscale;
        else
            zoomscale=1;
        end
        if strcmp(command,'beforeUA') && ua.zoomedOut % use center of image when image is zoomed out
            rw=imsize(1)/(zoomscale/2);
            rh=imsize(2)/(zoomscale/2);
            afRoi=round([imsize(1)/2-rw/2, imsize(2)/2-rh/2, rw, rh]);
            %         else
            %             afRoi=[af.closestspine.x1-af.roisize/2,af.closestspine.y1-af.roisize/2,af.roisize,af.roisize];
        end
        % get current position
        xyzPos = dia.hPos.getMotorAndEtlPosition;
        af.position.origin_abs = xyzPos;
%         [af.position.origin_abs,af.position.origin_rel]=motorGetPosition;
%         if dia.etl.acq.etlOn
%             af.position.origin_abs(3)=af.position.origin_abs(3)+etlVoltToMotorZCalc;
%         end
        % create list of positions to do autofocus in
%         af.position.af_list_abs_z=linspace((xyzPos(3)-(af.params.zrange/2)),(xyzPos(3)+(af.params.zrange/2)),af.params.scancount);
        % 2. run loop where z is moved from lowest to highest position, recording
        % each image
%         motorOrETLMove([xyzPos(1) xyzPos(2) af.position.af_list_abs_z(1)]);
        
        if lowRes %lower resolution
            changeRes(1);
            afRoi=[];
        end
        
        %collect images
        if strcmp(command,'beforeUA') && ~ua.zoomedOut %if focusing after zoomed out focus, set normal z slice amount
            I = updateCurrentImage(channel,2);
        else
            numberOfZSlices = state.acq.numberOfZSlices;
            zStepSize = state.acq.zStepSize;
            state.acq.zStepSize=af.params.zstep;
            set(gh.motorControls.etNumberOfZSlices,'String',num2str(af.params.scancount));
            motorControls('etNumberOfZSlices_Callback',gh.motorControls.etNumberOfZSlices);
            updateNumberOfZSlices(gh.motorControls.etNumberOfZSlices);
            set(gh.motorControls.etZStepPerSlice,'String',num2str(af.params.zstep));
            motorControls('etZStepPerSlice_Callback',gh.motorControls.etZStepPerSlice);
            I = updateCurrentImage(channel,2);
            state.acq.numberOfZSlices = numberOfZSlices;
            state.acq.zStepSize = zStepSize;
            set(gh.motorControls.etNumberOfZSlices,'String',num2str(numberOfZSlices));
            motorControls('etNumberOfZSlices_Callback',gh.motorControls.etNumberOfZSlices);
            set(gh.motorControls.etZStepPerSlice,'String',num2str(zStepSize));
            motorControls('etZStepPerSlice_Callback',gh.motorControls.etZStepPerSlice);
        end
        if strcmp(command,'beforeUA') && ua.zoomedOut
            Iref=dia.hPos.allPositionsDS.refImgZoomOut{dia.hPos.allPositionsDS.posID==posID};
            imageArray = zeros([size(Iref),size(af.images(:,channel),1)]);
            for i = 1:size(af.images(:,channel),1)
                imageArray(:,:,i) = af.images(i,channel).image;
            end
            [ind, sx, sy, ccShift] = focusUsingReference(imageArray,Iref);
            af.focusvalue = ccShift;
            af.bestfocus = ind;
            af.bestFocusAbsZ = af.position.af_list_abs_z(ind);
            cont_driftCorrect(af.bestFocusAbsZ,sx,sy);
        else
            % 3. run autofocus on all images. figure out which one is most in focus.
            for i=1:length(af.images)
                af.focusvalue(i)=fmeasure(af.images(i,channel).image,af.algorithm.operator,afRoi);
            end
            [~, af.bestfocus] = max(af.focusvalue);
            af.bestFocusAbsZ = af.position.af_list_abs_z(af.bestfocus);
            %         af.bestFocusedImage = af.images(af.bestfocus,channel).image;
            
            % 4. move to that position and verify the coordinates
            if af.drift.on && ~strcmp(command,'test') % if drift correction is on, set all 3 positions. if not, set just z.
                cont_driftCorrect(af.bestFocusAbsZ);
            else
                motorOrETLMove([af.position.origin_abs(1) af.position.origin_abs(2) af.bestFocusAbsZ],'verify');
            end
        end
        displayAFimages(command);
        
        if lowRes %reinstate old resolution
            changeRes(0);
            afRoi=[];
        end
    end
%%

    function acquiredAF
        if af.params.isAFon
            if ua.drift.useMaxProjection && af.drift.on && multiMode
                %this may be redundant, check later to see if it can be simplified.
                I = getLastAcqImage( channel,1 );
                if ua.zoomedOut %get reference image
                    Iref=dia.hPos.allPositionsDS.refImgZoomOut{dia.hPos.allPositionsDS.posID==posID};
                else
                    Iref=dia.hPos.allPositionsDS.refImg{dia.hPos.allPositionsDS.posID==posID};
                end
                [ shiftx, shifty ] = computeDrift(Iref,I);
                afRoi = [afRoi(1) - shiftx, afRoi(2) - shifty, afRoi(3), afRoi(4)];
            end
            af.focusvalue=[];
            for i=1:size(af.images,1)
                af.focusvalue(i)=fmeasure(af.images(i,af.params.channel).image,af.algorithm.operator,afRoi);
            end
            af.bestfocus=find(af.focusvalue==max(af.focusvalue),1);
            newAbsZ=af.position.af_list_abs_z(af.bestfocus);
        else
            newAbsZ=state.motor.absZPosition;
        end
        if af.drift.on && ~strcmp(command,'AF Once Before Uncaging')% if drift correction is on, set all 3 positions. if not, set just z.
            cont_driftCorrect(newAbsZ);
        else
            if ua.params.fovModeOn
                updateUAposition(posID,newAbsZ,[0,0]);
                if strcmp(command,'AF Once Before Uncaging') %move to new Z if about to uncage
                    motorOrETLMove([state.motor.absXPosition state.motor.absYPosition newAbsZ],'verify');
                end
            else
                motorOrETLMove([state.motor.absXPosition state.motor.absYPosition newAbsZ],'verify');
            end
        end
        displayAFimages('loop',af.images,af.position,afRoi);
        
        %         if dia.init.useOnePos && ua.acq.currentPos==dia.acq.refPosition && ua.params.fovModeOn %update all positions based on changes in this one
        %             for j=1:length(ua.fov.FOVposStruct) %find appropriate index of position in dataset and update scan parameters
%                 if ismember(ua.acq.currentPos,ua.fov.FOVposStruct(j).scanInfoDataset.oldMotorPosition)
%                     ssF=ua.fov.FOVposStruct(j).offset_ssFssS(1);
%                     ssS=ua.fov.FOVposStruct(j).offset_ssFssS(2);
%                     offsetZ=ua.fov.FOVposStruct(j).offsetZ;
%                     for k=1:length(ua.fov.FOVposStruct(j).scanInfoDataset)
%                         oldssF=ua.fov.FOVposStruct(j).scanInfoDataset.scanShiftFast(k,1);
%                         oldssS=ua.fov.FOVposStruct(j).scanInfoDataset.scanShiftSlow(k,1);
%                         %                         oldZ=ua.fov.FOVposStruct(j).motorZ_list(k);
%                         oldZ=ua.fov.FOVposStruct(j).scanInfoDataset.motorZ(k,1);
%                         ua.fov.FOVposStruct(j).scanInfoDataset.scanShiftFast(k,1)=oldssF+ssF;
%                         ua.fov.FOVposStruct(j).scanInfoDataset.scanShiftSlow(k,1)=oldssS+ssS;
%                         ua.fov.FOVposStruct(j).motorZ_list(k)=oldZ+offsetZ;
%                         ua.fov.FOVposStruct(j).scanInfoDataset.motorZ(k,1)=oldZ+offsetZ;
%                     end
%                     disp('Shifted all FOV positions by Z, Shift Fast, Shift Slow:')
%                     disp([num2str(offsetZ), '  ', num2str(ssF), '  ', num2str(ssS)]);
%                     break
%                 end
%             end
%         end
    end
%%
    function [ shiftx, shifty ]  = cont_driftCorrect(newAbsZ,shiftx,shifty)
        if nargin>2
            calcShift=false;
        else
            calcShift=true;
        end
        if calcShift
            if af.params.isAFon && (~ua.drift.useMaxProjection || ~af.params.useAcqForAF)
                try %%TODO - fix this because it's stupid.
                    I=af.images(af.bestfocus,channel).image;
                catch
                    I=af.images(af.bestfocus).image;
                end
                
            elseif af.params.isAFon && ua.drift.useMaxProjection
                I = getLastAcqImage( channel,1 );
            else
                if ua.drift.useMaxProjection
                    I = getLastAcqImage( channel,1 );
                elseif state.acq.averaging
                    I = getLastAcqImage( channel,0 );
                else
                    I=state.acq.acquiredData{2}{channel};
                end
            end
        end
        if multiMode % drift correction using reference images
            if calcShift
                if ua.zoomedOut %get reference image
                    Iref=dia.hPos.allPositionsDS.refImgZoomOut{dia.hPos.allPositionsDS.posID==posID};
                else
                    Iref=dia.hPos.allPositionsDS.refImg{dia.hPos.allPositionsDS.posID==posID};
                end
                [ shiftx, shifty ] = computeDrift(Iref,I);
            end
            if driftMotor
                scale=af.drift.scale;
                af.motorshift.x=(round(shiftx/scale*10))/10;
                af.motorshift.y=(round(shifty/scale*10))/10;
                motorOrETLMove([state.motor.absXPosition+af.motorshift.x state.motor.absYPosition+af.motorshift.y newAbsZ],'verify');
                updateUAposition(posID);
                disp(['Drift (x,y) corrected by: ' num2str(af.motorshift.x) ' , ' num2str(af.motorshift.y)]);
            elseif ua.params.fovModeOn
                if isfield(ua,'zoomscale')
                    zoomscale=ua.zoomscale;
                else
                    zoomscale=1;
                end
                pos=[imsize(2)/2-shiftx, imsize(1)/2-shifty, 0, 0];
                [ssF, ssS, ~, ~, ~, ~]=scanShiftCalc(pos, ua.params.initialZoom/zoomscale, imsize);
%                 if ~dia.init.useOnePos
                    updateUAposition(posID,newAbsZ,[ssF,ssS]);
%                 else
%                     for j=1:length(ua.fov.FOVposStruct) %find appropriate index of position in dataset and update scan parameters
%                         if ismember(posID,ua.fov.FOVposStruct(j).scanInfoDataset.oldMotorPosition)
%                             ua.fov.FOVposStruct(j).offsetZ=newAbsZ-ua.fov.FOVposStruct(j).scanInfoDataset.motorZ(ua.fov.FOVposStruct(j).scanInfoDataset.oldMotorPosition==posID,1); %record change in Z
%                             ua.fov.FOVposStruct(j).offset_ssFssS=[ssF, ssS];
%                         end
%                     end
%                 end
                
                
            end
        elseif ~multiMode %single position mode
            if calcShift
                try
                    Iref=af.drift.Iref; %single reference image
                catch
                    disp('Warning - Reference Image for drift correction not set. Using first acquired image as reference');
                    af.drift.Iref = I;
                    Iref = I;
                end
                [ shiftx, shifty ] = computeDrift(Iref,I);
            end
            if driftMotor
                scale=af.drift.scale;
                af.motorshift.x=(round(shiftx/scale*10))/10;
                af.motorshift.y=(round(shifty/scale*10))/10;
                motorOrETLMove([state.motor.absXPosition+af.motorshift.x state.motor.absYPosition+af.motorshift.y newAbsZ],'verify');
                disp(['Drift (x,y) corrected by: ' num2str(af.motorshift.x) ' , ' num2str(af.motorshift.y)]);
            else %scanShift mode
                pos=[imsize(1)/2-shiftx, imsize(2)/2-shifty, 0, 0];
                [ssF, ssS, ~, ~, ~, ~]=scanShiftCalc(pos, state.acq.zoomFactor, imsize);
                state.acq.scanShiftFast=state.acq.scanShiftFast+ssF;
                state.acq.scanShiftSlow=state.acq.scanShiftSlow+ssS;
                updateGUIByGlobal('state.acq.scanShiftFast');
                updateGUIByGlobal('state.acq.scanShiftSlow');
                setupAOData; %needed to reset scanning shift
                motorOrETLMove([state.motor.absXPosition state.motor.absYPosition newAbsZ],'verify');
            end
        end
    end

    function changeRes(lowerRes)
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
    end
end


