function [  ] = UA_startloop(  )
%UA_startloop starts loop imaging
global gh ua state

% Set Period in main controls window and update all relevant info
set(gh.mainControls.etRepeatPeriod,'String',num2str(ua.params.primaryFreq));
genericCallback(gh.mainControls.etRepeatPeriod);
state.internal.secondsCounter=state.acq.repeatPeriod; 
updateGUIByGlobal('state.internal.secondsCounter');

% set savepath
state.files.savePath=ua.filestruct(ua.acq.currentPosInd).savepath;
updateFullFileName;
% Set total repeats in main controls window and update all relevant info
repeats=floor(ua.params.primaryTime*60/ua.params.primaryFreq);
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
% ua.looptimer=timer('TimerFcn', 'UA_done_looping', 'TasksToExecute', 1, 'StartDelay',ua.params.primaryTime*60);
ua.timerval=ua.params.primaryTime*60;

ua.timers.looptimer=timer('TimerFcn',...
    'ua.timerval=ua.timerval-1; updateTminusCounter(ua.timerval)',...
    'TasksToExecute', ua.params.primaryTime*60, 'StopFcn','UA_done_looping',...
    'Period',1,'ExecutionMode','fixedSpacing','Name','UA_Timer');

start(ua.timers.looptimer);

end

