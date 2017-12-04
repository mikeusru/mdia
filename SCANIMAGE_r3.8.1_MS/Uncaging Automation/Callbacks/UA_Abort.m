function [  ] = UA_Abort( grabAndTime )
%UA_Abort runs when the ABORT button is hit.
global state ua dia gh

if nargin<1
    grabAndTime=false;
end
dia.acq.allowTimerStart = false;
setJobQueueTimer(0);
allTimers = [dia.hPos.imagingTimers.timer];
allTimers = allTimers(isvalid(allTimers));
stop(allTimers);
delete(allTimers);
for i=1:length(dia.hPos.imagingTimers)
    dia.hPos.imagingTimers(i).activeTimerInd=[];
end

if isfield(dia.acq,'jobQueueTimer')
    delete(dia.acq.jobQueueTimer);
end
ua.UAmodeON=false;

takeStackOfEntireFOV;

if isfield(dia.acq,'returnHome')
    state.acq.returnHome=dia.acq.returnHome;
    if dia.acq.returnHome %turn off 'Return Home' to speed up imaging
        set(gh.motorControls.cbReturnHome,'Value',1);
        genericCallback(gh.motorControls.cbReturnHome);
    end
end

if grabAndTime
    return
end

set(dia.handles.mdia.startPushbutton, 'String', 'Start', 'FontWeight', 'normal', 'ForegroundColor', 'black');

setZoomValue(ua.params.initialZoom);

state.files.savePath=dia.originalSavePath;
dia.hPos.setWorkingPositions(1); %reset working positions

updateUAgui;