function exclusiveTimerFun
global ua dia

if ~ua.UAmodeON %check if process has been aborted
    return
end

elapsedTime=etime(clock,dia.acq.exclusiveClk);

updateTminusCounter(dia.acq.totalTime-elapsedTime);
% set(dia.handles.mdia.tminusText,'String',num2str(round(dia.acq.totalTime-elapsedTime)));

%when timer is complete...
if elapsedTime>=dia.acq.totalTime
    
    try
        stop(dia.acq.exclusiveTimer);
        stop(dia.acq.exclusiveActionTimer);
    catch err
        disp(err);
    end
    
    exclusiveActionNextStep;
    
end
end