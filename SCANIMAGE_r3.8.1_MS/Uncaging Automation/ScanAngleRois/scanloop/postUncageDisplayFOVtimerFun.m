function postUncageDisplayFOVtimerFun

global ua dia


if dia.acq.pauseOn
    if isfield(dia.acq,'pauseFunc') && ~isempty(dia.acq.pauseFunc)
        dia.acq.pauseFunc{end+1}=@setupPostUncageTimers;
    else
        dia.acq.pauseFunc{1}=@setupPostUncageTimers;
    end
    stop(ua.timers.postUncageDisplayFOVtimer);
    stop(ua.timers.postUncageActionFOVtimer);
    dia.acq.pauseClock=clock;
end


ua.timerval=etime(clock,ua.clk);
updateTminusCounter(ua.totalTime-ua.timerval);
if ua.timerval>=ua.totalTime
    FOVuaPostUncageDone;
end
end