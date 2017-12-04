function [  ] = UA_Fixdrift( posID,zoomscale,shiftRoi,motorShift,updateAll )
%UA_Fixdrift corrects the drift for the given position in posID
%autofocus should probably done before calling this.
%
% zoomscale is an optional parameter and reflects the inverse fraction of
% the original zoom, used to calculate the change in the um to pixels scale
% or the scan shift parameters
%
% shiftRoi is optional and indicates that the ROIs need to be shifted along
% with the drift. this should occur right before uncaging.
%
% motorShift is a boolean operator indicating, if true, that the XY shift
% should be done using the motor as opposed to the scanning angle. It is on
% by default. If motorShift is off, other positions will not be
%
% updateAll indicates whether all positions should be updated or not. it is
% ON by default if motorShift is ON, and OFF by default if motorShift is
% OFF.
% Note - drift correction may likely not work when the scan field is
% rotated.

global ua state af

if ~ua.drift.driftON
    return
end

if nargin<4
    motorShift=true;
end

if nargin<5 && ~motorShift
    updateAll=false;
elseif nargin<5 && motorShift
    updateAll=true;
end

% get drift correction factor

ua.drift.scale=af.drift.scale;
if nargin<3
    shiftRoi=false;
end

if nargin>1 && zoomscale~=1
    scale=ua.drift.scale/zoomscale;
    Iref=ua.drift.refImgZoomOut{posID};
    pixel_limit=3;
else
    scale=ua.drift.scale;
   Iref=ua.drift.refImg{posID};
    pixel_limit=4;
    zoomscale=1;
end

if motorShift
    disp(['Scale: ', num2str(scale), ' pixels per micron']);
    motorGetPosition();
    currentposition = [state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition];
    currentposID=state.hSI.zprvPosn2PositionID(currentposition);
    if currentposID==0 || currentposID~=posID %check to make sure motor is at correct position
        motorPositionGoto(posID); %if not, go to given position
    end
elseif ~motorShift
    setScanAngleROI( posID ); %make sure position and scan angle are correct
end

channel=af.params.channel;
if ua.drift.useMaxProjection
    I=updateCurrentImage(channel,2);
else
    I=updateCurrentImage(channel,1);
end
imsize=size(I);

% calculate drift
[shiftx, shifty] = computeDrift( Iref, I);

disp(['X,Y Drift(pixels)= [' , num2str(shiftx), ',', num2str(shifty), ']']); %display pixel drift values

%% run drift correction loop for a max 5 iterations
if motorShift
    i=0;
    while (abs(shiftx)>pixel_limit || abs(shifty)>pixel_limit) && i<5; %repeat drift correction until both x and y shift is less than 3 pixels OR drift correction has been done 5 times.
        coordinates = motorGetPosition;
        newpos=[coordinates(1)+(round(shiftx/scale*10))/10, coordinates(2)+(round(shifty/scale*10))/10, coordinates(3)];
        motorSetPositionAbsolute(newpos,'verify');
        if ua.drift.useMaxProjection
            I=updateCurrentImage(channel,2);
        else
            I=updateCurrentImage(channel,1);
        end
        [shiftx, shifty] = computeDrift( Iref, I); %compute drift in pixels
        i=i+1;
        disp(['X,Y Drift(pixels)= [' , num2str(shiftx), ',', num2str(shifty), ']']); %display pixel drift values
        
    end
    
    disp('Done Drift Correction');
    
    %shift this and all other positions
    if (abs(shiftx)<=pixel_limit && abs(shifty)<=pixel_limit) && updateAll
        shiftAllPosns(posID,'xy');
    elseif ~updateAll && (abs(shiftx)<=pixel_limit && abs(shifty)<=pixel_limit)
        updateUAposition( posID )
    else
        disp('Shift still too strong. Position(s) will not be updated in case of possible error');
    end
    
end

%% Scan angle drift correction
if ~motorShift
    
    i=0;
    while (abs(shiftx)>pixel_limit || abs(shifty)>pixel_limit) && i<5; %repeat drift correction until both x and y shift is less than 3 pixels OR drift correction has been done 5 times.
        pos=[imsize(1)/2-shiftx, imsize(2)/2-shifty, 0, 0];
        [ssF, ssS, ~, ~, ~, ~]=scanShiftCalc(pos, ua.fov.imzoom/zoomscale, imsize);
        state.acq.scanShiftFast=state.acq.scanShiftFast+ssF;
        state.acq.scanShiftSlow=state.acq.scanShiftSlow+ssS;
        updateGUIByGlobal('state.acq.scanShiftFast');
        updateGUIByGlobal('state.acq.scanShiftSlow');
        setupAOData;
        if ua.drift.useMaxProjection
            I=updateCurrentImage(channel,2);
        else
            I=updateCurrentImage(channel,1);
        end
        [shiftx, shifty] = computeDrift( Iref, I); %compute drift in pixels
        i=i+1;
        disp(['X,Y Drift(pixels)= [' , num2str(shiftx), ',', num2str(shifty), ']']); %display pixel drift values
    end
    for i=1:length(ua.fov.FOVposStruct) %find appropriate index of position in dataset
        if ismember(posID,ua.fov.FOVposStruct(i).includedMotorPosns)
            ua.fov.FOVposStruct(i).scanInfoDataset.scanShiftFast(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1)=state.acq.scanShiftFast;
            ua.fov.FOVposStruct(i).scanInfoDataset.scanShiftSlow(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1)=state.acq.scanShiftSlow;
            break
        end
    end
    disp(['Done Drift Correction for Position ' num2str(posID)]);
    
end

% update rois just for this position
%final drift calculated values used for ROI shift.
if zoomscale==1 && shiftRoi
    for i=1:length(ua.positions)
        if ua.positions(i).posnID==posID
            r=ua.positions(i).roiPosition;
            ua.positions(i).roiPosition=[r(1)-shiftx,r(2)-shifty,r(3),r(4)];
        end
    end
end

end
