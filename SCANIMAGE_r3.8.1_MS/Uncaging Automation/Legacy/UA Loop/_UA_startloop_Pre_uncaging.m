function [  ] = UA_startloop_Pre_uncaging(  )
%UA_startloop starts loop imaging before uncaging
global gh ua state

if ~ua.UAmodeON %check if process has been aborted
    return
end

% Set Period in main controls window and update all relevant info
set(gh.mainControls.etRepeatPeriod,'String',num2str(ua.params.preUncageFreq));
genericCallback(gh.mainControls.etRepeatPeriod);
state.internal.secondsCounter=state.acq.repeatPeriod; 
updateGUIByGlobal('state.internal.secondsCounter');

% set savepath
state.files.savePath=ua.filestruct(ua.acq.currentPosInd).pre_uncage_savepath;
updateFullFileName;
% Set total repeats in main controls window and update all relevant info
repeats=floor(ua.params.preUncageTime*60/ua.params.preUncageFreq);
set(gh.mainControls.repeatsTotal,'String',num2str(repeats));
genericCallback(gh.mainControls.repeatsTotal);

% turning the focus on and off before looping is a workaround for an error
% which occurs when the loop button is pressed by itself.
mainControls('focusButton_Callback',gh.mainControls.focusButton);
pause(1)
mainControls('focusButton_Callback',gh.mainControls.focusButton);

%Start LOOP mode
mainControls('startLoopButton_Callback',gh.mainControls.startLoopButton);

%Set a timer to turn off looping after the set amount of time has passed.
ua.timerval=ua.params.preUncageTime*60;

ua.timers.pre_uncagelooptimer=timer('TimerFcn',...
    'ua.timerval=ua.timerval-1; updateTminusCounter(ua.timerval)',...
    'TasksToExecute', ua.params.preUncageTime*60, 'StopFcn','UA_done_pre_uncage_looping',...
    'Period',1,'ExecutionMode','fixedSpacing','Name','UA_PreUncage_Timer');

start(ua.timers.pre_uncagelooptimer);

end

