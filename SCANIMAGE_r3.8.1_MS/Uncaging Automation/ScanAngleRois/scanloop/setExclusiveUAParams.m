function setExclusiveUAParams
%setExclusiveUAParams sets the parameters for the exclusive UA timers

global ua dia gh state af

if ~ua.UAmodeON %check if process has been aborted
    return
end

posNum=dia.acq.staggerRunCount;

switch dia.acq.exclusiveTaskCounter
    case 1
        %% run exclusive pre-uncaging imaging
        disp(['Starting Exclusive Pre-uncaging Imaging at Position', num2str(ua.acq.currentPos)]);
        dia.acq.totalTime=dia.acq.preUncageExclusiveTime*60;
        updateUAgui('currentStepText','Exclusive Pre-Uncaging');
        dia.acq.staggerStep=1; %pre-uncaging
        dia.acq.exclusiveClk=clock;
        dia.acq.exclusivePeriod=dia.acq.preUncageExclusivePeriod;
        defineExclusiveUATimers;
    case 2 %uncaging
        saveUncagingInfo;
        disp(['Starting Exclusive Uncaging at Position', num2str(ua.acq.currentPos)]);
        dia.acq.staggerStep=2;
        if dia.acq.correctRois
            %Collect image before correcting for ROIs. this avoids having
            %to do it multiple times when multiple ROIs are taken.
            channel=af.params.channel;
            if ua.drift.useMaxProjection
                I=updateCurrentImage(channel,2);
            else
                I=updateCurrentImage(channel,1);
            end
            runDriftCorrect('ShiftZPosition',true); %run autofocus and move to new Z position
            for j=1:length(ua.positions)
                if ua.positions(j).posnID==ua.acq.currentPos
                    roiPos=ua.positions(j).roiPosition;
                    %Correct ROI position;
                    ua.positions(j).roiPosition=correctRoi(roiPos,1,I);
                end
            end
        end
        showUncagingRois(ua.acq.currentPos,true); %bring up appropriate uncaging ROIs
        zdiff = abs(ua.fov.FOVposStruct(dia.hPos.workingFOV).scanInfoDataset.zRoofOffset(posNum));
%         zdiff=abs(ua.params.zRoof-state.motor.absZPosition);
        setUncagingDwell(zdiff);  %set dwell time
        if dia.acq.pageAcqOn
            ua.filestruct(posNum).currentSavepath=ua.filestruct(dia.acq.staggerRunCount).pageAcq_savepath;
            state.files.savePath=ua.filestruct(posNum).pageAcq_savepath;
            updateFullFileName;
            disp('Page Scanning is ON');
            set(gh.spc.FLIMimage.pageScan,'Value',1);
            FLIMimage('pageScan_Callback',gh.spc.FLIMimage.pageScan,[],gh.spc.FLIMimage);
            state.acq.zStepSize=0;
            updateCurrentImage(1,2,1); %this hits the grab button and waits for it to finish, therefore doing the page controls mode and uncaging
            disp('Page Scanning turned back off');
            set(gh.spc.FLIMimage.pageScan,'Value',0);
            FLIMimage('pageScan_Callback',gh.spc.FLIMimage.pageScan,[],gh.spc.FLIMimage);
            state.acq.zStepSize=str2double(get(gh.motorControls.etZStepPerSlice,'String'));
            exclusiveActionNextStep;
        else
            yphys_stimScope('start_Callback',gh.yphys.stimScope.start); %Run uncaging cycle
        end
    case 3
        ua.filestruct(posNum).currentSavepath=ua.filestruct(posNum).exclusive_savepath;
        state.files.savePath=ua.filestruct(posNum).exclusive_savepath;
        updateFullFileName;
        disp(['Starting Exclusive Post-uncaging Imaging at Position', num2str(ua.acq.currentPos)]);
        dia.acq.totalTime=dia.acq.postUncageExclusiveTime*60;
        updateUAgui('currentStepText','Exclusive Post-Uncaging');
        dia.acq.staggerStep=3; %pre-uncaging
        dia.acq.exclusiveClk=clock;
        dia.acq.exclusivePeriod=dia.acq.postUncageExclusivePeriod;
        setupAOData; %reset imaging data
        defineExclusiveUATimers;
end


end

