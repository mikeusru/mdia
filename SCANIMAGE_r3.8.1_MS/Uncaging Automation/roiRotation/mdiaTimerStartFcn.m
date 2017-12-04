function mdiaTimerStartFcn( mTimer,~ )
%mdiaTimerStartFcn runs when a timer starts. it checks if the timer is
%allowed to start and if other timers need to be paused

global dia
dia.acq.jobQueue=[dia.acq.jobQueue,[{@timerQueueStart};{mTimer}]];

end

