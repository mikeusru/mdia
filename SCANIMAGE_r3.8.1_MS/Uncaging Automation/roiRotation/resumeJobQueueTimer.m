function resumeJobQueueTimer(tAction)

global dia
if ~strcmp(tAction,'Uncaging') && ~dia.acq.pauseOn
    setJobQueueTimer(1);
end
