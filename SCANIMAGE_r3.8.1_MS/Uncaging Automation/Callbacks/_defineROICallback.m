%% translated to dia.hPos.defineROI

function [  ] = defineROICallback(  )
%defineROICallback runs when the Define Uncaging ROI button is pressed in
%the uncaging automation GUI.

%The current stage position is added to the position list, and the
%corresponding ROI is added to the ROI list. If the position exists, it is
%not added. ua is the uncaging automation structure.

global state gh ua dia

%% figure out current position and coordinates

zoomVal=state.acq.zoomFactor;
if zoomVal~=ua.params.initialZoom
    errString=['Imaging Zoom value (' num2str(ua.params.initialZoom) ') and current Zoom value (' num2str(zoomVal) ') must be equal.'];
   errordlg(errString);
   return
end

if ua.params.fovModeOn
    choice=questdlg('Add ROI in FOV mode? Original XY motor values will be incorrect.','Add in FOV mode?','OK','Cancel','Cancel');
    if strcmp(choice,'Cancel')
        return
    end
end

motorGetPosition();

if dia.etl.acq.etlOn
    state.motor.absZPosition=state.motor.absZPosition+etlVoltToMotorZCalc;
end
position = [state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition];
posnID=state.hSI.zprvPosn2PositionID(position); %compare current coordinates to find closest position.
if posnID==0 %if position does not yet exist, add it and record new position #
    state.hSI.roiAddPosition(position); %same as clicking 'add' in the motor controls GUI. possibly. need to check.
    posnID=state.hSI.zprvPosn2PositionID(position);
elseif ua.params.fovModeOn
    errString='ERROR - Scanimage already has a position saved with these motor coordinates. Try changing them slightly.';
   errordlg(errString,'FOV Mode ADD ROI failed');
   return
end

% %% Delete any current ROIs from other positions
% if isfield(ua,'positions') && isfield(ua.positions, 'posnID') && isinteger(ua.positions(1).posnID)
%     for i=1:length(ua.positions)
%         if ua.positions(i).posnID~=posnID
%             if ishandle(gh.yphys.figure.yphys_roi(ua.positions(i).roiNum))
%                 a=findobj('Tag', num2str(ua.positions(i).roiNum));
%                 delete(a);
%             end
%         end
%     end
% end

%% Delete all current ROIs
for i=1:length(gh.yphys.figure.yphys_roi)
    if ishandle(gh.yphys.figure.yphys_roi(i))
        a=findobj('Tag', num2str(i));
        delete(a);
    end
end
%% define new ROI

if isfield(ua,'roiTotal') && ua.roiTotal>0
    roiNum=ua.roiTotal+1;
else
    roiNum=1;
end

yphys_makeRoi(roiNum); %define new ROI


%% record info to structure

if isfield(ua,'positions') && isfield(ua.positions, 'posnID') && ~isempty(ua.positions) && isinteger(ua.positions(1).posnID)
    i=length(ua.positions)+1;
else
    i=1;
end
ua.positions(i).posnID=posnID;
ua.positions(i).roiNum=roiNum;
ua.positions(i).roiPosition=get(gh.yphys.figure.yphys_roi(roiNum), 'Position');
ua.positions(i).hasRef=false;
ua.positions(i).hasRefZoomOut=false;
ua.positions(i).zoomVal=zoomVal;
ua.positions(i).zRoofOffset=state.motor.absZPosition-ua.params.zRoof;
ua.roiTotal=roiNum;

if ua.params.fovModeOn %add position to FOV structure
    disp('Adding position to FOV #1');
    ua.fov.uniqueMotorPosns(end+1)=posnID;
    ua.fov.FOVposStruct(1).includedMotorPosns(end+1)=posnID;
    ua.fov.FOVposStruct(1).motorZ_list(end+1)=state.motor.absZPosition;
    ds=dataset;
    ds.scanShiftFast=state.acq.scanShiftFast;
    ds.scanShiftSlow=state.acq.scanShiftSlow;
    ds.scanRotation=state.acq.scanRotation;
    ds.scanAngleMultiplierFast=state.acq.scanAngleMultiplierFast;
    ds.scanAngleMultiplierSlow=state.acq.scanAngleMultiplierSlow;
    ds.newZoomFactor=state.acq.zoomFactor;
    ds.oldMotorPosition=posnID;
    ds.motorZ=state.motor.absZPosition;
    ua.fov.FOVposStruct(1).scanInfoDataset=[ua.fov.FOVposStruct(1).scanInfoDataset;ds];
end
%% show ROIs in current position

for j=1:length(ua.positions)
    if ua.positions(j).posnID==posnID
        yphys_roi=ua.positions(j).roiPosition;
        i=ua.positions(j).roiNum;
        axes(state.internal.axis(1));
        gh.yphys.figure.yphys_roi(i) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
        gh.yphys.figure.yphys_roiText(i) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
        set(gh.yphys.figure.yphys_roiText(i), 'Color', 'Red');
        
        axes(state.internal.axis(2));
        gh.yphys.figure.yphys_roi2(i) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
        gh.yphys.figure.yphys_roiText2(i) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
        set(gh.yphys.figure.yphys_roiText2(i), 'Color', 'Red');
        
        axes(state.internal.maxaxis(2));
        gh.yphys.figure.yphys_roi3(i) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
        gh.yphys.figure.yphys_roiText3(i) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
        set(gh.yphys.figure.yphys_roiText3(i), 'Color', 'Red');
    end
end

updateUAgui;

if ua.params.autoAddRefImg %add reference image
    addRefImg(posnID);
end

updateUAgui;

end

