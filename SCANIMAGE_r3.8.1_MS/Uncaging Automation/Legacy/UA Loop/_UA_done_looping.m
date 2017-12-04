function [  ] = UA_done_looping(  )
%UA_done_looping is called when the timer set in UA_done_uncaging hits. It
%is used to turn off loop mode.
global ua gh state

if ~ua.UAmodeON %if aborted, stop everything
    return
end

% if loop button is on, turn it off
if strcmp(get(gh.mainControls.startLoopButton,'String'),'ABORT')
    mainControls('focusButton_Callback',gh.mainControls.focusButton);
end

try
    stop(ua.timers.looptimer);
    delete(ua.timers.looptimer);
end

%% check if finished. If not, move onto next position and start next iteration

if ~(ua.acq.currentPosInd==length(ua.uniquePosns)) %if cycling is not done
    %set next position and position index
    ua.acq.currentPosInd=ua.acq.currentPosInd+1;
    ua.acq.currentPos=ua.uniquePosns(ua.acq.currentPosInd);
    % set savepath
    state.files.savePath=ua.filestruct(ua.acq.currentPosInd).savepath;
    updateFullFileName;
    % Start next iteration;
    startUA;
else
    disp('Finished Final Loop');
    UA_Abort;
end
end

