function pauseOrResumeTimers(posID,stopIt,stopPositions)
%pauseOrResumeTimersForExclusiveImaging(posID,startStop) pauses or resumes all the
%timers for positions which are not posID
%
% set posID to 0 to pause all positions

%this function should probably be called by startFcn and stopFcn in a
%timer... if the timer is exclusive, run it. 
global dia

%get working positions which are not the current position
if nargin<3
    stopPositions = getWorkingTimers(posID);
end
% stopTimers=dia.hPos.imagingTimers(Lia);
timerInd = find(ismember([dia.hPos.imagingTimers.posID],stopPositions));

for i=timerInd
    ind=dia.hPos.imagingTimers(i).activeTimerInd;
    if stopIt %stop timers
        dia.acq.allowTimerStart=false; % to make sure other timers don't start... if they try, add them to a que or something
%         ind=strcmp('on',dia.hPos.imagingTimers(i).timer.running);
        stop(dia.hPos.imagingTimers(i).timer(ind));
%         dia.hPos.imagingTimers(i).activeTimerInd=ind;
    else %resume timers
        dia.acq.allowTimerStart=true;
%         if dia.hPos.imagingTimers(i).stepCountdown(ind) < 1 %if no tasks remain, run the timer's StopFcn
%             feval(dia.hPos.imagingTimers(i).timer(ind).StopFcn,dia.hPos.imagingTimers(i).timer(ind)); %this protects against cases where the pause was called as the timer finished, but its stop function was blocked
        if dia.hPos.imagingTimers(i).stepCountdown(ind) > 0
            dia.hPos.imagingTimers(i).timer(ind).TasksToExecute = dia.hPos.imagingTimers(i).stepCountdown(ind); %update timer's counter
            start(dia.hPos.imagingTimers(i).timer(ind));
        end
    end
end

end

