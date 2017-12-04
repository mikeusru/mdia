function preUncageDisplayFOVtimerFun
global ua dia

if dia.acq.pauseOn
    if isfield(dia.acq,'pauseFunc') && ~isempty(dia.acq.pauseFunc)
        if ua.fov.acq.initialImaging
            dia.acq.pauseFunc{end+1}=@setupInitialImagingTimers;
        else
            dia.acq.pauseFunc{end+1}=@setupPreUncageTimers;
        end
    else
        if ua.fov.acq.initialImaging
            dia.acq.pauseFunc{end+1}=@setupInitialImagingTimers;
        else
            dia.acq.pauseFunc{1}=@setupPreUncageTimers;
        end
    end
    stop(ua.timers.preUncageDisplayFOVtimer);
    stop(ua.timers.preUncageActionFOVtimer);
    dia.acq.pauseClock=clock;
end

ua.timerval=etime(clock,ua.clk);
updateTminusCounter(ua.totalTime-ua.timerval);
if ua.timerval>=ua.totalTime
    if ua.fov.acq.initialImaging
        finishInitialImaging;
    else
        FOVuaPreuncageDone;
    end
end

    function finishInitialImaging
        
        if ~ua.UAmodeON %check if process has been aborted
            return
        end
        stop(ua.timers.preUncageDisplayFOVtimer);
        stop(ua.timers.preUncageActionFOVtimer);
        try
            delete(ua.timers.preUncageDisplayFOVtimer);
            delete(ua.timers.preUncageActionFOVtimer);
        catch err
            disp(err.message);
        end
        %initialize pre-uncaging mode
        ua.fov.acq.initialImaging=false;
        FOVuaPreuncage;
    end
end