function [ output_args ] = alignFOVpositions( allPosIDs )
%alignFOVpositions is a callback function from the FOVgui window. it is
%used to align all of the FOV positions to their images taken from
%UA_DriftCorrect
%FOVnum is an optional parameter which dictates the FOV which will be
%aligned. if there is no input, all FOVs will be aligned
% global ua af dia
% 
% if nargin<1
%     dia.hPos.setWorkingPositions;
%     allPosIDs = dia.hPos.workingPositions;
% end
% 
% ds = dia.hPos.allPositionsDS;
% for i=1:length(allPosIDs)
%     posID=allPosIDs(i);
%     dia.hPos.moveToNewScanAngle(posID);
%     af.closestspine.x1=ds(ds.posID==posID,:).roiPosition{1}(1);
%     af.closestspine.y1=ds(ds.posID==posID,:).roiPosition{1}(2);
%     %zoom out
%     initialzoom=ua.params.initialZoom;
%     if ua.drift.zoomOutDrift % Optional initial autofocus and drift correction on zoomed out image
%         newzoom=ua.drift.zoomfactor;
%         setZoomValue(newzoom);
%         setScanProps;
%         zoomscale=initialzoom/newzoom;
%         ua.zoomscale=zoomscale;
%         ua.zoomedOut=true;
%         run_AF('beforeUA',0,posID);
%         dia.hPos.moveToNewScanAngle(posID);
% 
%         setZoomValue(initialzoom);
%         setScanProps;
%         ua.zoomedOut=false;
%         zoomscale=1;
%         ua.zoomscale=1;
%     else
%         zoomscale=1;
%         ua.zoomscale=1;
%     end
%     run_AF('beforeUA',0,posID);
% end
% 
% 
% end

