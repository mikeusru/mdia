function [  ] = updateUAposition( posID, newZ, scanShiftOffset,doZRoofOffset )
%updateUAposition( posnID, newZ, scanShift ) updates the XYZ coordinates of the currently selected
%position in the UA window to the current XYZ coordinates.
%
% posID is an optional input, while the default used ua.SelectedPosition
%
% newZ (optinal) inihbits a motorGetPosition and gives the absolute Z
% position
%
% scanShift (optional) is a 2x1 double [scanShiftFast,scanShiftSlow]. If
% newZ is supplied but scanShift isn't, a new scan shift value will not be
% recorded.
%
% doZRoofOffset indicates whether the Z Roof Offset is currently being set

global state ua dia

hPos=dia.hPos;

if nargin<1 || isempty(posID)
    if ~isfield(ua,'SelectedPosition')
        disp('Error - No position selected');
        return
    end
    posID=ua.SelectedPosition;
end

if nargin<2 || isempty(newZ)
    xyzPos = dia.hPos.getMotorAndEtlPosition();
    newZ = xyzPos(3);
    updateZdrift=false;
%     motorGetPosition();
%     
%     if dia.etl.acq.etlOn
%         newZ=state.motor.absZPosition+etlVoltToMotorZCalc;
%     else
%         newZ=state.motor.absZPosition;
%     end
else
    updateZdrift=true;
end

if nargin<3
    scanShiftOffset=[];
end


if nargin==2 %do not update scan shift if only a new Z is provided
    updateScanShift=0;
else
    updateScanShift=1;
end

if nargin<4 || isempty(doZRoofOffset) %only update Z roof offset for uncaging dwell time
    doZRoofOffset=false;
end

if ~doZRoofOffset
    positionStruct=state.hSI.positionDataStructure(posID);
    oldZ = positionStruct.motorZ;
    positionStruct.motorZ=newZ;
end

if doZRoofOffset
    hPos.updateZRoof(posID,newZ);
%     for i=1:length(ua.positions)
%         if posID == ua.positions(i).posnID
%             currentZvalue = ua.positions(i).motorZ;
%             ua.positions(i).zRoofOffset=currentZvalue - newZ;
%         end
%     end
    updateUAgui;
    return
end

ind=hPos.allPositionsDS.posID==posID;

if updateZdrift
    hPos.allPositionsDS.zDrift(ind) = hPos.allPositionsDS.zDrift(ind) + oldZ - newZ;
end

hPos.allPositionsDS.motorZ(ind)=newZ;

if ua.params.fovModeOn && updateScanShift
    if ~isempty(scanShiftOffset) %update drift and scan angles
        hPos.allPositionsDS.scanShiftFastDrift(ind) = hPos.allPositionsDS.scanShiftFastDrift(ind) + scanShiftOffset(1);
        hPos.allPositionsDS.scanShiftSlowDrift(ind) = hPos.allPositionsDS.scanShiftSlowDrift(ind) + scanShiftOffset(2);
        hPos.allPositionsDS.scanShiftFast(ind) = hPos.allPositionsDS.scanShiftFast(ind) + scanShiftOffset(1);
        hPos.allPositionsDS.scanShiftSlow(ind) = hPos.allPositionsDS.scanShiftSlow(ind) + scanShiftOffset(2);
        
    else %update scan angles to current settings
        hPos.allPositionsDS.scanShiftFast(ind) = state.acq.scanShiftFast;
        hPos.allPositionsDS.scanShiftSlow(ind) = state.acq.scanShiftSlow;
    end
    if ~ua.UAmodeON
        disp(['Updated Position ', num2str(posID), ' Z Coordinate and Scan Shift since FOV mode is ON']);
    end
%     try
%         for i=1:length(ua.fov.FOVposStruct) %find appropriate index of position in dataset
%             if ismember(posID,ua.fov.FOVposStruct(i).includedMotorPosns)
%                 if doZRoofOffset
%                     currentZvalue=ua.fov.FOVposStruct(i).scanInfoDataset.motorZ(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1);
%                     ua.fov.FOVposStruct(i).scanInfoDataset.zRoofOffset(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1)=currentZvalue-newZ;
%                 else
%                     ua.fov.FOVposStruct(i).offsetZ=newZ-ua.fov.FOVposStruct(i).scanInfoDataset.motorZ(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1);
%                     ua.fov.FOVposStruct(i).scanInfoDataset.motorZ(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1)=newZ;
%                     ua.fov.FOVposStruct(i).motorZ_list(ua.fov.FOVposStruct(i).includedMotorPosns==posID)=newZ;
%                     if updateScanShift
%                         if ~isempty(scanShiftOffset)
%                             ua.fov.FOVposStruct(i).offset_ssFssS=scanShiftOffset;
%                             oldssF=ua.fov.FOVposStruct(i).scanInfoDataset.scanShiftFast(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1);
%                             oldssS=ua.fov.FOVposStruct(i).scanInfoDataset.scanShiftSlow(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1);
%                             scanShift=[oldssF+scanShiftOffset(1),oldssS+scanShiftOffset(2)];
%                         end
%                         ua.fov.FOVposStruct(i).scanInfoDataset.scanShiftFast(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1)=scanShift(1);
%                         ua.fov.FOVposStruct(i).scanInfoDataset.scanShiftSlow(ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID,1)=scanShift(2);
%                     end
                   
%                 end
%             end
%         end
%     catch err
%         disp(err);
%         disp('Error in updating FOV coordinates');
%     end
else
    positionStruct.motorX=state.motor.absXPosition;
    positionStruct.motorY=state.motor.absYPosition;
    disp(['Updated Position ', num2str(posID), ' Coordinates']);
end

state.hSI.positionDataStructure(posID)=positionStruct;    %update position table
state.hSI.roiUpdatePositionTable();

dia.hPos=hPos;

updateUAgui;
% sortUApositionsByZ;
end

