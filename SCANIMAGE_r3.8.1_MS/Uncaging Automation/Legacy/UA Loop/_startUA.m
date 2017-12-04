function [ ] = startUA( )
%startUA is initiated after the startbuttoncallback function referring to
%the uncaging automation control, or after a post-uncage looping cycle is complete.

global gh state af ua dia

if ~ua.UAmodeON %check if process has been aborted
    return
end

% move to appropriate position and show spines
disp(['Moving to Position ' num2str(ua.acq.currentPos)]);
set(dia.handles.mdia.currentPosText,'String',num2str(ua.acq.currentPos));
GoToCallback(ua.acq.currentPos);



% set AF spine coordinates to coordinates for first ROI in this postion

for i=1:length(ua.positions)
    if ua.positions(i).posnID==ua.acq.currentPos
        af.closestspine.x1=ua.positions(i).roiPosition(1);
        af.closestspine.y1=ua.positions(i).roiPosition(2);
        break
    end
end

if ~ua.UAmodeON %check if process has been aborted
    return
end

%zoom out
initialzoom=ua.params.initialZoom;
if ua.drift.zoomOutDrift
    newzoom=ua.drift.zoomfactor;
    setZoomValue(newzoom);
    zoomscale=initialzoom/newzoom;
    ua.zoomedOut=true;
else
    zoomscale=1;
end

if ~ua.UAmodeON %check if process has been aborted
    return
end

if initialzoom>10 && ua.drift.zoomOutDrift %Autofocus and update Z (zoomed out)
    run_AF('beforeUA');
    shiftAllPosns(ua.acq.currentPos,'xyz');
    
    if ~ua.UAmodeON %check if process has been aborted
        return
    end
    
    % Drift Correction (zoomed out)
    if ua.drift.driftON
        UA_Fixdrift(ua.acq.currentPos,zoomscale);
        % Update ROI display
        GoToCallback(ua.acq.currentPos);
    end
    
    if ~ua.UAmodeON %check if process has been aborted
        return
    end
    
    %zoom back in
    setZoomValue(initialzoom);
    ua.zoomedOut=false;
    zoomscale=1;
end

if ~ua.UAmodeON %check if process has been aborted
    return
end
%Autofocus and update Z with originally zoomed in image

run_AF('beforeUA');
shiftAllPosns(ua.acq.currentPos,'xyz');

if ~ua.UAmodeON %check if process has been aborted
    return
end

% Drift Correctin
if ua.drift.driftON
    UA_Fixdrift(ua.acq.currentPos,zoomscale);
    % Update ROI display
    GoToCallback(ua.acq.currentPos);
end

%% Start Pre-uncaging imaging

UA_startloop_Pre_uncaging;


end

