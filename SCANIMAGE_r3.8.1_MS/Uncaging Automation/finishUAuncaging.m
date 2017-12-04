function finishUAuncaging
%% finishUAuncaging
%runs when uncaging is complete and is used to decide whether there is a
%next step which should be taken in the automation sequence

global dia

if ~isfield(dia.acq,'pageAcqOn') || ~dia.acq.pageAcqOn
    setJobQueueTimer(1);
end
% 
% try
%     if isfield(ua,'UAmodeON') && ua.UAmodeON && ~ua.params.fovModeOn %% Misha - 03022015 - check if auto uncaging mode is on, send a signal that uncaging is finished.
%         UA_done_uncaging;
%     elseif isfield(ua,'UAmodeON') && ua.UAmodeON && ua.params.fovModeOn && ua.fov.acq.Uncage && (~dia.init.staggerOn || ~dia.acq.staggerModeRunning)
%         rotateAndUncageFOV(dia.hPos.workingFOV);
%     elseif isfield(ua,'UAmodeON') && ua.UAmodeON && ua.params.fovModeOn && dia.init.staggerOn && dia.acq.staggerModeRunning && ~dia.acq.pageAcqOn
%         exclusiveActionNextStep;
%     end
% end