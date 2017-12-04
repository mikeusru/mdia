%% replaced by moveToNewScanAngle in hPos

function [ changedParams ] = setScanAngleROI( oldMotorPosition, setZoom )
%setScanAngleROI sets the scanning ROI to the one associated with the old
%motor position
% the output is a cell array showing which parameters were changed (in
% addition to the zoom)
% setZoom is a boolean value. if true, the zoom will be set. Default value
% is false.

global state ua

logActions;

if nargin<2
    setZoom=false;
end

scanParams = {'scanShiftFast' 'scanShiftSlow' 'scanRotation' 'scanAngleMultiplierFast' 'scanAngleMultiplierSlow'};
changedParams = {};

% find the appropriate params
ds=[];
for i=1:length(ua.fov.FOVposStruct)
    if ismember(oldMotorPosition,ua.fov.FOVposStruct(i).includedMotorPosns)
        ds=ua.fov.FOVposStruct(i).scanInfoDataset(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==oldMotorPosition,:);
%         motorZ=ua.fov.FOVposStruct(i).motorZ_list(ua.fov.FOVposStruct(i).includedMotorPosns==oldMotorPosition);
        motorZ=ua.fov.FOVposStruct(i).scanInfoDataset.motorZ(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==oldMotorPosition,1);
        %set motor position
        motorOrETLMove([ua.fov.FOVposStruct(i).motorX,ua.fov.FOVposStruct(i).motorY,motorZ],1);
%         motorSetPositionAbsolute([ua.fov.FOVposStruct(i).motorX,ua.fov.FOVposStruct(i).motorY,motorZ]);
        break
    end
end

% move to the appropriate position


% update scanning params
if setZoom
    setZoomValue(ds.newZoomFactor);
end

if ~isempty(ds)
    for i=1:length(scanParams)
        paramName = scanParams{i};
        
        if state.acq.(paramName) ~= ds.(paramName)
            changedParams{end+1} = paramName;
        end
        state.acq.(paramName) = ds.(paramName);
        updateGUIByGlobal(['state.acq.' paramName]);
    end
end

if ismember('scanAngleMultiplierFast',changedParams) %not sure if this part works or is necessary. hopefully the scan angle miltiplier doesn't need to change...?
    updateScanAngleMultiplier();
elseif ismember('scanAngleMultiplierSlow',changedParams)
    updateScanAngleMultiplierSlow();
end

end

