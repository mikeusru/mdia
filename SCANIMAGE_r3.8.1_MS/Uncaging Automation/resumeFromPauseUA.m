function resumeFromPauseUA
%resumeFromPauseUA resumes the uncaging automation after the unpause button
%has been hit

global dia ua

%finish rotating through FOV positions first, then resume timers
if dia.acq.pauseWhileRotateThroughFOV
    return
end


if ~ua.UAmodeON %this is only the function for resuming after a pause in automated uncaging mode... otherwise it's not necessary
    return
end

epTime=etime(clock,dia.acq.pauseClock);
ua.totalTime=ua.totalTime+epTime; %set total time to previous total time + time spent in paused state;
ua.timerTasks=floor(ua.timerval);
if ua.uncageTasksRemaining>=0
    ua.uncageTasks=ua.uncageTasksRemaining;
else
    ua.uncageTasks=0;
end

for i=1:length(dia.acq.pauseFunc)
    feval(dia.acq.pauseFunc{i});
end

dia.acq.pauseFunc=[];
dia.acq.pauseOn=false;

end

