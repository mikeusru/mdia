function defineExclusiveUATimers
%defineExclusiveUATimers defines the timers for exclusive staggered imaging
global ua dia

if ~ua.UAmodeON %check if process has been aborted
    return
end
dia.acq.exclusiveTotalSteps=floor(dia.acq.totalTime*60/dia.acq.exclusivePeriod);

% seconds timer to keep track of time and display time remaining and
% signal when next step should start
dia.acq.exclusiveTimer=timer('TimerFcn',...
    'exclusiveTimerFun;',...
    'TasksToExecute', dia.acq.totalTime, ...
    'Period',1,'ExecutionMode','fixedRate','Name','exclusiveTimer');

% timer for pre-uncage imaging. fixedRate execution mode allows for the
% time period to start as soon as the callback starts.
dia.acq.exclusiveActionTimer=timer('TimerFcn',...
    'exclusiveActionTimerFun;',...
    'TasksToExecute', dia.acq.exclusiveTotalSteps, 'Period',dia.acq.exclusivePeriod,...
    'ExecutionMode','fixedRate','Name','exclusiveActionTimer');


start(dia.acq.exclusiveTimer);
start(dia.acq.exclusiveActionTimer);
end

