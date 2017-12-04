function setupPostUncageTimers
%setupPostUncageTimers sets up and starts the post-uncaging timers

global ua

% seconds timer to keep track of time and display time remaining
ua.timers.postUncageDisplayFOVtimer=timer('TimerFcn',...
    'postUncageDisplayFOVtimerFun;',...
    'TasksToExecute', ua.timerTasks, ...
    'Period',1,'ExecutionMode','fixedRate','Name','postUncageDisplayFOVtimer');

    

% timer for pre-uncage imaging. fixedRate execution mode allows for the
% time period to start as soon as the callback starts.
ua.timers.postUncageActionFOVtimer=timer('TimerFcn',...
    'ua.uncageTasksRemaining=ua.uncageTasksRemaining-1; rotateThroughFOVPositions(''grab'',false,dia.hPos.workingFOV);',...
    'TasksToExecute', ua.uncageTasks, 'Period',ua.params.primaryFreq,...
    'ExecutionMode','fixedRate','Name','postUncageActionFOVtimer');

start(ua.timers.postUncageDisplayFOVtimer);
start(ua.timers.postUncageActionFOVtimer);

end

