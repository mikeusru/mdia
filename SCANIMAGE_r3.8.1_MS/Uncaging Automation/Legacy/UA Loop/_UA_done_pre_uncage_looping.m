function [  ] = UA_done_pre_uncage_looping(  )
%UA_done_looping is called when the timer set in UA_done_uncaging hits. It
%is used to turn off loop mode.
global ua gh state

if ~ua.UAmodeON %check if process has been aborted
    return
end

% if loop button is on, turn it off
if strcmp(get(gh.mainControls.startLoopButton,'String'),'ABORT')
    mainControls('focusButton_Callback',gh.mainControls.focusButton);
end

try
    stop(ua.timers.pre_uncagelooptimer);
    delete(ua.timers.pre_uncagelooptimer);
end

% Drift Correctin again
if ua.drift.driftON
    UA_Fixdrift(ua.acq.currentPos,1,true);
    % Update ROI display
    GoToCallback(ua.acq.currentPos);
end

if ~ua.UAmodeON %check if process has been aborted
    return
end


% set appropriate dwell time for uncaging position


zdiff=abs(ua.params.zRoof-state.motor.absZPosition);
setUncagingDwell(zdiff);
        
        
%Start Uncaging

%check if doing page controls mode.
if ~isfield(ua.params,'pageacq') || ~ua.params.pageacq
    %automated press of 'start' button in uncaging window
    yphys_stimScope('start_Callback',gh.yphys.stimScope.start);
elseif ua.params.pageacq
    disp('The page acq button is on. I haven''t written the code for this yet.');
end
end

