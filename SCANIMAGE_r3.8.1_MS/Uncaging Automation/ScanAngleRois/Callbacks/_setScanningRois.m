% this will be completely replaced by hPos

function setScanningRois
%setScanningRois translates the motor positions to scan angle ROIs, but
%keeps the Z value and stuff intact. 
global ua state dia

%First, it may be a good idea to backup all the previous motor positions
%because they are gonna be messed with.

% ua.fov.oldPositionDataStructure=state.hSI.positionDataStructure;
% if dia.etl.acq.etlOn
%     choice=questdlg('Update ETL Motor Z Limit to lowest ROI position minus 4µm?','Update ETL Z limit','OK','Cancel','Cancel');
%     if strcmp(choice,'OK')
%         updateEtlZlimit=1;
%     else updateEtlZlimit=0;
%     end
% else
%     updateEtlZlimit=0;
% end
if ~isfield(ua,'fov') || isempty(ua.fov) || isempty(ua.fov.positions)
    error('ERROR - ADD AND SAVE FOV FIRST');
end

%%
fovwidth=ua.fov.fovwidth;
fovheight=ua.fov.fovheight;
imzoom=ua.fov.imzoom;
scanShiftDataNames={'scanShiftFast', 'scanShiftSlow', 'scanRotation', 'scanAngleMultiplierFast', 'scanAngleMultiplierSlow', 'newZoomFactor','oldMotorPosition','motorZ','zRoofOffset'};

%first, define the position structure and set the X and Y values. The Z
%values will be unique to each scanning field and therefore will get put in
%later
FOVposStruct=struct;
j=1;
if isfield(ua.fov,'positions')
    for i=1:size(ua.fov.positions,1)
        if ua.fov.positions(i,4)~=0
            FOVposStruct(j).motorX=ua.fov.positions(i,1)+fovwidth/2;
            FOVposStruct(j).motorY=ua.fov.positions(i,2)+fovheight/2;
            FOVposStruct(j).Xvertices=[ua.fov.positions(i,1), ua.fov.positions(i,1), ua.fov.positions(i,1)+fovwidth, ua.fov.positions(i,1)+fovwidth, ua.fov.positions(i,1)];
            FOVposStruct(j).Yvertices=[ua.fov.positions(i,2), ua.fov.positions(i,2)+fovheight, ua.fov.positions(i,2)+fovheight, ua.fov.positions(i,2), ua.fov.positions(i,2)];
            j=j+1;
        end
    end
end

%Next, need to add Z to each. Eventually, each position will have its own
%structure with the X, Y, and a list of all the Zs and information
%necessary to set up the scan angle values.

%calculate included motor positions
posns=getUniqueUApositions;
unusedP=true(size(posns)); %used in order to prevent duplicate imaging of positions in overlapping fields of view


for i=1:length(FOVposStruct)
    in=inpolygon(ua.fov.originalMotorPositionsXYZ(:,1),ua.fov.originalMotorPositionsXYZ(:,2),FOVposStruct(i).Xvertices,FOVposStruct(i).Yvertices);
    in=in';
    incPosInd=(unusedP & in);
    FOVposStruct(i).includedMotorPosns=posns(incPosInd);
    FOVposStruct(i).motorZ_list=ua.fov.originalMotorPositionsXYZ(incPosInd,3);
    FOVposStruct(i).scanInfoDataset=cell2dataset(scanShiftDataNames);
    incPosInd2=find(incPosInd);
    for j=1:length(incPosInd2) %add scan shift info for each position by creating a dataset
        posX=FOVposStruct(i).motorX-fovwidth/2-ua.fov.originalMotorPositionsXYZ(incPosInd2(j),1)+fovwidth/imzoom/2; % scanshift is inverse to X direction
        posY=FOVposStruct(i).motorY-fovheight/2-ua.fov.originalMotorPositionsXYZ(incPosInd2(j),2)+fovheight/imzoom/2;
        pos=[-posX -posY fovwidth/imzoom fovheight/imzoom];
        [ scanShiftFast, scanShiftSlow, scanRotation, scanAngleMultiplierFast, scanAngleMultiplierSlow, newZoomFactor] = scanShiftCalc( pos );
        for k=1:length(ua.positions)
            if posns(incPosInd2(j))==ua.positions(k).posnID
                zRoofOffset=ua.positions(k).zRoofOffset;
            end
        end
        ds=cell2dataset({scanShiftDataNames{1:end}; -scanShiftFast, -scanShiftSlow, scanRotation, scanAngleMultiplierFast, scanAngleMultiplierSlow, newZoomFactor, posns(incPosInd2(j)), ua.fov.originalMotorPositionsXYZ(incPosInd2(j),3),zRoofOffset});
        FOVposStruct(i).scanInfoDataset=vertcat(FOVposStruct(i).scanInfoDataset,ds);
    end
    unusedP(in)=false;
end

% update ua position struct with FOV field number

for i=1:length(ua.positions)
    for j=1:length(FOVposStruct)
        if ismember(ua.positions(i).posnID,FOVposStruct(j).includedMotorPosns)
            ua.positions(i).FOVnum=j;
        end
    end
end

% if updateEtlZlimit
%    dia.etl.acq.absZlimit=min(FOVposStruct(1).motorZ_list)-2;
% end
ua.fov.FOVposStruct=FOVposStruct;


updateUAgui;
disp('Positions Set to FOV');

