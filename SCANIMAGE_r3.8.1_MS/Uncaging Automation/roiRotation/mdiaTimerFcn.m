function mdiaTimerFcn(mTimer,~)

global dia
dia.acq.jobQueue=[dia.acq.jobQueue,[{@timerQueueHit};{mTimer}]];


end