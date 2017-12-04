function jobQueuePicker(~,~)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
global dia
try
    t2=clock;
    et=etime(t2,dia.acq.startTime);
    et=round(datevec(datenum(0,0,0,0,0,et)));
    et=[num2str(et(4)),'h ', num2str(et(5)),'m ',num2str(et(6)),'s'];
    set(dia.handles.mdia.elapsedTimeTxt,'String',et);
    if ~dia.acq.busy && ~isempty(dia.acq.jobQueue)
%         disp(dia.acq.jobQueue{1,1});
%         disp(dia.acq.jobQueue{2,1});
%         drawnow;
        feval(dia.acq.jobQueue{1,1},dia.acq.jobQueue{2,1});
        dia.acq.jobQueue(:,1) = [];
    elseif ~dia.acq.busy && dia.acq.grabAndTimeOn && isempty(dia.acq.jobQueue)
        set(dia.handles.mdia.timeFOVGrabPushbutton,'String','Grab and Time Positions Once');
    end
catch ME
    disp(getReport(ME));
end


end

