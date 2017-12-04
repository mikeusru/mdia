function locateNewPosition(allPosIDs,meanDrift)
%locateNewPosition(posID) is called when a new position needs to be focused
%and drift-corrected more than usual.
%
% meanDrift is a boolean, indicating whether the mean previous drift should
% be accounted for. this is applicable when a position is being started
% after not being imaged in a while. 

global ua af dia state

if nargin<2
    meanDrift = false;
end

if nargin<1
    dia.hPos.setWorkingPositions;
    allPosIDs = dia.hPos.workingPositions;
end

ds = dia.hPos.allPositionsDS;
if meanDrift %take median drift of other positions and apply them here
    ind = ~ismember(ds.posID,allPosIDs);
    if ~isempty(find(ind,1))
        ds.zDrift(~ind) = median(ds.zDrift(ind));
        ds.scanShiftFastDrift(~ind) = median(ds.scanShiftFastDrift(ind));
        ds.scanShiftSlowDrift(~ind) = median(ds.scanShiftSlowDrift(ind));
        ds.scanShiftFast(~ind) = ds.scanShiftFast(~ind) + ds.scanShiftFastDrift(~ind);
        ds.scanShiftSlow(~ind) = ds.scanShiftSlow(~ind) + ds.scanShiftSlowDrift(~ind);
        for i=1:length(allPosIDs)
            n = find(~ind);
            positionStruct=state.hSI.positionDataStructure(allPosIDs(i));
            positionStruct.motorZ = positionStruct.motorZ + ds.zDrift(n(i));
            state.hSI.positionDataStructure(allPosIDs(i))=positionStruct;    %update position table
            state.hSI.roiUpdatePositionTable();
        end
    end
end

dia.hPos.allPositionsDS = ds;

for i=1:length(allPosIDs)
    posID=allPosIDs(i);
    dia.hPos.moveToNewScanAngle(posID);
    af.closestspine.x1=ds(ds.posID==posID,:).roiPosition{1}(1);
    af.closestspine.y1=ds(ds.posID==posID,:).roiPosition{1}(2);
    %zoom out
    initialzoom=ua.params.initialZoom;
    if ua.drift.zoomOutDrift % Optional initial autofocus and drift correction on zoomed out image
        newzoom=ua.drift.zoomfactor;
        setZoomValue(newzoom);
        setScanProps;
        zoomscale=initialzoom/newzoom;
        ua.zoomscale=zoomscale;
        ua.zoomedOut=true;
        runDriftCorrect('BeforeUA',true,'PosID',posID);
        dia.hPos.moveToNewScanAngle(posID);

        setZoomValue(initialzoom);
        setScanProps;
        ua.zoomedOut=false;
        zoomscale=1;
        ua.zoomscale=1;
    else
        zoomscale=1;
        ua.zoomscale=1;
    end
    runDriftCorrect('BeforeUA',true,'PosID',posID);
end


end





