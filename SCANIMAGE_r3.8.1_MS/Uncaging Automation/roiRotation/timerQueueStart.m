function timerQueueStart( mTimer )

global dia
setJobQueueTimer(0);
try
    timerInfo = mTimer.UserData;
    i = timerInfo.timerIndex;
    j = timerInfo.timelineIndex;
    posID = timerInfo.posID;
    if dia.hPos.imagingTimers(i).stepCountdown(j) <1
        stop(mTimer);
        setJobQueueTimer(1);
        return
    end
    dia.hPos.imagingTimers(i).activeTimerInd=j;
    
%     if ~dia.acq.allowTimerStart %this should stop timers from starting when a pause is on
%         return
%     end

    if dia.hPos.timelineSetup(j).exclusive && dia.acq.allowTimerStart %if this is an exclusive timer and timers aren't already paused, stop the other timers
        pauseOrResumeTimers(posID,1);
    end
    if dia.hPos.imagingTimers(i).startLater
        locateNewPosition(posID,1); %run to find coordinates for a position which has likely drifted far from its original coordinates
        dia.hPos.imagingTimers(i).startLater = false;
    end
    updateUAgui;
catch ME
    disp(getReport(ME));
    dia.test.imagingTimers=dia.hPos.imagingTimers;
end

setJobQueueTimer(1);
end

