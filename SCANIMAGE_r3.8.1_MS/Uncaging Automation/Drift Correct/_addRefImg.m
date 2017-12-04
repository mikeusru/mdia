%% translated to dia.hPos.addRefImg

function [ output_args ] = addRefImg( posID )
%addRefImg adds a reference image to the ua position structure

global ua state dia af

channel=af.params.channel;

if ua.drift.useMaxProjection
    I=updateCurrentImage(channel,2);
else
    if state.acq.averagingDisplay %check if can use average display
        I=state.internal.tempImageDisplay{channel};
    else
        I=state.acq.acquiredData{2}{channel};
    end
end

ua.drift.refImg{posID}=I;

%% zoom out and save zoomed out image
initialzoom=ua.params.initialZoom;
hasRefZoomOut=false;

if ua.drift.zoomOutDrift
    newzoom=ua.drift.zoomfactor;
    setZoomValue(newzoom);
    setScanProps(dia.handles.mdia.defineUncagingROIpushbutton);
    ua.zoomedOut=true;
    if ua.drift.useMaxProjection
        I2=updateCurrentImage(channel,2);
    else
        I2=updateCurrentImage(channel,1);
    end
    setZoomValue(initialzoom);
    ua.zoomedOut=false;
    ua.drift.refImgZoomOut{posID}=I2;
    hasRefZoomOut=true;
end


for i=1:length(ua.positions) %update position info structure
    if ua.positions(i).posnID==posID
        ua.positions(i).hasRef=true;
        ua.positions(i).hasRefZoomOut=hasRefZoomOut;
    end
end

end

