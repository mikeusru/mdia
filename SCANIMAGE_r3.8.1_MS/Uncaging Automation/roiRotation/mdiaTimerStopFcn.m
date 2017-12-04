function mdiaTimerStopFcn( mTimer,~ )
%mdiaTimerStopFcn runs when a timer stops. It moves on to the next event
%and checks if other timers need to be resumed

global dia
dia.acq.jobQueue=[dia.acq.jobQueue,[{@timerQueueStop};{mTimer}]];




end

