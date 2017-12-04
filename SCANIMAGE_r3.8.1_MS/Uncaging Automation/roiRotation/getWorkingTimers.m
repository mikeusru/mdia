function stopPositions = getWorkingTimers(posID,running)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%running=true means that only the timers which are currently on will be
%returned
global dia

if nargin<2
    running=false; 
end

stopPositions = [dia.hPos.imagingTimers.posID];
if running
    t = [dia.hPos.imagingTimers.timer];
    ind = strfind(t.running,'on');
    ind = ~cellfun(@isempty,ind);
    ind = reshape(ind,length(dia.hPos.timelineSetup),[]);
    ind = max(ind,[],1);
    stopPositions=stopPositions(ind);
end
stopPositions = stopPositions(stopPositions~=posID);
Lia = ismember(stopPositions,dia.hPos.workingPositions);
stopPositions = stopPositions(Lia);

end

