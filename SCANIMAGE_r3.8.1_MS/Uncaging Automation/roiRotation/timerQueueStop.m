function timerQueueStop( mTimer )

global dia

try
    timerInfo = mTimer.UserData;
    i = timerInfo.timerIndex;
    j = timerInfo.timelineIndex;
    posID = timerInfo.posID;
    
    
    if ... (~dia.acq.allowTimerStart && ~dia.hPos.timelineSetup(j).exclusive) || ...
            timerInfo.singleRun ... %if stop is being called for/during a pause, stop here because it will be called again later
            || dia.hPos.imagingTimers(i).stepCountdown(j) > 0 %if timer is not finished
        return
    end
    
    if j<length(dia.hPos.timelineSetup) && dia.hPos.timelineSetup(j+1).exclusive
        if ~dia.hPos.timelineSetup(j).exclusive  %if the next timer is exclusive unlike this one, stop the other timers
            pauseOrResumeTimers(posID,1);
        end
    elseif dia.hPos.timelineSetup(j).exclusive %if this was an exclusive timer but the next one isn't, resume the other timers
        pauseOrResumeTimers(posID,0);
    end
    
    
    
    % if dia.hPos.imagingTimers(i).stepCountdown(j) > 0 %if timer is stopped due to some error, don't move on to the next one..?
    %     return
    % end
    
    dia.hPos.imagingTimers(i).activeTimerInd = [];
    
    if j < length(dia.hPos.timelineSetup) %if more timeline steps are left...
        start(dia.hPos.imagingTimers(i).timer(j+1));
    else % if no timeline steps are left, mark this position as finished
        dia.hPos.finishedPositions=[dia.hPos.finishedPositions , posID];
        ind = dia.hPos.workingPositions == posID;
        dia.hPos.workingPositions(ind)=[];
        disp(['Finished Position ',num2str(posID)]);
        %and move on to another position
        newPos = dia.hPos.setWorkingPositions;
        if ~isempty(newPos)
            dia.hPos.staggerAndStartInitialPositions(newPos);
        end
        if isempty(dia.hPos.workingPositions)
            disp('Imaging Done');
            UA_Abort;
        end
    end
catch ME
    disp(getReport(ME));
end


end

