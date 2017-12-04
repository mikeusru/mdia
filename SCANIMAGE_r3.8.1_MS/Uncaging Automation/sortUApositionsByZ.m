%this function doesn't work with hPos, and should be taken care of in
%another way. 

function sortUApositionsByZ
%sortUApositionsByZ sorts the saved positions by their Z value.
global ua dia state
return %remove this function after hPos is ready
logActions;

if ua.UAmodeON || ~isfield(ua,'positions') || isempty(fieldnames(ua.positions)) || dia.acq.pauseOn %don't change sorting when UAmode is on
    return
end

if isfield(ua,'positions') && isfield(ua.positions,'roiNum')
    for i=1:length(ua.positions)
        posID=ua.positions(i).posnID;
        positionStruct(i)=state.hSI.positionDataStructure(posID);
        ua.positions(i).motorZ=positionStruct(i).motorZ;
    end
end

[~,ind]=sortrows({ua.positions.motorZ}');
ua.positions=ua.positions(ind);

if isfield(ua,'fov') && isfield(ua.fov,'FOVposStruct')
    for i=1:length(ua.fov.FOVposStruct)
        ds=sortrows(ua.fov.FOVposStruct(i).scanInfoDataset,'motorZ'); % sort positions by Z value
        ua.fov.FOVposStruct(i).scanInfoDataset=ds;
    end
end



end

