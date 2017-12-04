function [ output_args ] = runExclusiveUAStagger( fovNum )
%runExclusiveUAStagger runs the pre-uncaging, uncaging, and post-uncaging for one position.
global dia ua state
persistent ds poscount

if ~ua.UAmodeON %check if process has been aborted
    return
end

posNum=dia.acq.staggerRunCount;

if posNum==1 %if this is the first uncaging call
    ds=ua.fov.FOVposStruct(fovNum).scanInfoDataset;
    poscount=length(ds);
end

if posNum>poscount %when done with all staggered recording, begin general post-uncage imaging
    FOVuaPostUncage;
    return
end

%Set appropriate directory and filename
ua.filestruct(posNum).currentSavepath=ua.filestruct(posNum).exclusive_savepath;
state.files.savePath=ua.filestruct(posNum).exclusive_savepath;
updateFullFileName;
%Move to appropriate position
posID=ds.oldMotorPosition(posNum);
ua.acq.currentPos=posID;
ua.fov.acq.currentPos=posID;
setScanAngleROI( posID, 1 );
setupAOData; %needed to reset scanning shift
dia.acq.staggerModeRunning=true;
dia.acq.exclusiveTaskCounter=1;


dia.acq.exclusiveSteps=[dia.acq.preUncageExclusiveTime>0, 1, dia.acq.postUncageExclusiveTime>0]; %reference for which exclusive steps are taken

while ~dia.acq.exclusiveSteps(dia.acq.exclusiveTaskCounter)
    dia.acq.exclusiveTaskCounter=dia.acq.exclusiveTaskCounter+1;
    if dia.acq.exclusiveTaskCounter>length(dia.acq.exclusiveSteps)
        finishExclusiveUAStagger;
        return
    end
end


setExclusiveUAParams;

% defineExclusiveUATimers;
% 
% start(dia.acq.exclusiveTimer);
% start(dia.acq.exclusiveActionTimer);

% dia.acq.exclusiveTaskCounter=dia.acq.exclusiveTaskCounter+1;

end

