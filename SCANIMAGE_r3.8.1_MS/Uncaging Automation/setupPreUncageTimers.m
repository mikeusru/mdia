function setupPreUncageTimers
%setupPreUncageTimers sets up and starts the pre-uncaging timers

global ua

% seconds timer to keep track of time and display time remaining
ua.timers.preUncageDisplayFOVtimer=timer('TimerFcn',...
    'preUncageDisplayFOVtimerFun;',...
    'TasksToExecute', ua.timerTasks+60, ... %% the +60 makes sure this timer runs for long enough that it is running when it's time to stop it...
    'Period',1,'ExecutionMode','fixedRate','Name','preUncageDisplayFOVtimer');

% timer for pre-uncage imaging. fixedRate execution mode allows for the
% time period to start as soon as the callback starts.
ua.timers.preUncageActionFOVtimer=timer('TimerFcn',...
    'ua.uncageTasksRemaining=ua.uncageTasksRemaining-1; rotateThroughFOVPositions(''grab'',true,dia.hPos.workingFOV);',...
    'TasksToExecute', ua.uncageTasks, 'Period',ua.params.preUncageFreq,...
    'ExecutionMode','fixedRate','Name','preUncageActionFOVtimer');

start(ua.timers.preUncageDisplayFOVtimer);
start(ua.timers.preUncageActionFOVtimer);


end

