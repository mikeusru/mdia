function setJobQueueTimer(on)
global dia


try
    if on
        dia.acq.busy = false; %false if not uncaging, otherwise set in finishUAuncaging
        start(dia.acq.jobQueueTimer);
    else
        dia.acq.busy = true; %false if not uncaging, otherwise set in finishUAuncaging
        stop(dia.acq.jobQueueTimer);
    end
catch ME
    disp(getReport(ME));
end