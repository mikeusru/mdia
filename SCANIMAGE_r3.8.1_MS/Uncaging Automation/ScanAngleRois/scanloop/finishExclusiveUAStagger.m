function finishExclusiveUAStagger
%finishExclusiveUAStagger runs when an exclusive uncaging/imaging session
%is complete for a single position, allowing a return to either general
%imaging or the next exclusive imaging round.
global dia ua gh state


dia.acq.staggerModeRunning=false;
disp(['Stagger mode finished for position ' num2str(ua.acq.currentPos)]);
try
    delete(dia.acq.exclusiveTimer);
    delete(dia.acq.exclusiveActionTimer);
catch err
%     disp(err);
end
ua.filestruct(dia.acq.staggerRunCount).currentSavepath=ua.filestruct(dia.acq.staggerRunCount).savepath;

dia.acq.staggerRunCount=dia.acq.staggerRunCount+1; %update counter for how many positions have been done

if ~ua.UAmodeON %check if process has been aborted
    return
end

% if dia.acq.pageAcqOn
%     disp('Page Scanning turned back off');
%     set(gh.spc.FLIMimage.pageScan,'Value',0);
%     FLIMimage('pageScan_Callback',gh.spc.FLIMimage.pageScan,[],gh.spc.FLIMimage);
%     state.acq.zStepSize=str2double(get(gh.motorControls.etZStepPerSlice,'String'));
% end

if dia.acq.staggerRunCount<=size(ua.fov.FOVposStruct(dia.hPos.workingFOV).scanInfoDataset,1)
    %run pre-uncaging again on all positions
    FOVuaPreuncage;
else 
    %if stagger imaging is done for all positions, move onto post-uncaging
    %imaging
    FOVuaPostUncage;
end
    





end

