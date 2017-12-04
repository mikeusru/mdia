function timerQueueHit( mTimer )
global dia af state ua gh

setJobQueueTimer(0);

try
    timerInfo = mTimer.UserData;
    i = timerInfo.timerIndex;
    j = timerInfo.timelineIndex;
    tAction = dia.hPos.timelineSetup(j).action;
    finishup = onCleanup(@() resumeJobQueueTimer(tAction));
    posID = timerInfo.posID;
%     disp(['timerQueueHit',num2str(posID)]);
    updateUAgui('currentPosText',num2str(posID));
    if dia.hPos.imagingTimers(i).stepCountdown(j) <1
        stop(mTimer);
        disp('stopped short');
        return
    end
    if timerInfo.singleRun %if GrabAndTime mode
        dia.hPos.moveToNewScanAngle(posID,1); %move to position
        grabAndAF(posID,1);
        return
    end
    
    if strcmp(tAction,'Imaging')
        mdiaImagingStep(posID,i,j,dia.hPos.timelineSetup(j).exclusive,dia.hPos.timelineSetup(j).steps,dia.hPos.imagingTimers(i).stepCountdown(j));
    elseif strcmp(tAction,'Uncaging')
        mdiaUncagingStep(posID,i,j);
    end
    dia.hPos.imagingTimers(i).stepCountdown(j)=dia.hPos.imagingTimers(i).stepCountdown(j)-1; %step countdown
catch ME
    disp(getReport(ME));
end

    
    function mdiaImagingStep(posID, i, j, excl,totalSteps,stepCountdown)
        state.files.savePath=dia.hPos.imagingTimers(i).savePath{j}; %set appropriate directory and filename
        state.files.fileCounter=dia.hPos.imagingTimers(i).acqNum;
        updateFullFileName;
        dia.hPos.imagingTimers(i).acqNum=dia.hPos.imagingTimers(i).acqNum+1;
        dia.hPos.moveToNewScanAngle(posID,1); %move to position to account for af/drift
        grabAndAF(posID);
    end

    function mdiaUncagingStep(posID, i, j)
        dia.hPos.moveToNewScanAngle(posID,1); %move to position
        state.files.savePath=dia.hPos.imagingTimers(i).savePath{j}; %set appropriate directory and filename
        state.files.fileCounter=dia.hPos.imagingTimers(i).acqNum;
        updateFullFileName;
        if dia.acq.correctRois %update ROI position
            %Collect image before correcting for ROIs. this avoids having
            %to do it multiple times when multiple ROIs are taken.
            channel=af.params.channel;
            if ua.drift.useMaxProjection
                I=updateCurrentImage(channel,2);
            else
                I=updateCurrentImage(channel,1);
            end
            runDriftCorrect('ShiftZPosition',true,'PosID',posID); %run autofocus and move to new Z position
            roiPos = dia.hPos.allPositionsDS.roiPosition{dia.hPos.allPositionsDS.posID==posID};
            dia.hPos.allPositionsDS.roiPosition{dia.hPos.allPositionsDS.posID==posID} = correctRoi(roiPos,1,I);
        end
        
        saveUncagingInfo;
        showUncagingRois(posID,true); %show uncaging ROIs
        zdiff = dia.hPos.allPositionsDS.zRoofOffset(dia.hPos.allPositionsDS.posID==posID);
        setUncagingDwell(zdiff);  %set dwell time
        if dia.hPos.timelineSetup(j).pageAcq %page acq mode
            dia.acq.pageAcqOn = true;
            dia.hPos.imagingTimers(i).acqNum=dia.hPos.imagingTimers(i).acqNum+1;
            disp('Page Scanning is ON');
            set(gh.spc.FLIMimage.pageScan,'Value',1);
            FLIMimage('pageScan_Callback',gh.spc.FLIMimage.pageScan,[],gh.spc.FLIMimage);
            state.acq.zStepSize=0;
            updateCurrentImage(1,2,1); %this hits the grab button and waits for it to finish, thus doing the page controls mode and uncaging
            disp('Page Scanning turned back off');
            set(gh.spc.FLIMimage.pageScan,'Value',0);
            FLIMimage('pageScan_Callback',gh.spc.FLIMimage.pageScan,[],gh.spc.FLIMimage);
            state.acq.zStepSize=str2double(get(gh.motorControls.etZStepPerSlice,'String'));
            dia.acq.pageAcqOn = false;
            setJobQueueTimer(1);
        else
            %automated press of 'start' button in uncaging window
            %             ntrain = state.yphys.acq.ntrain(state.yphys.acq.pulseN);
            % %             finishedString=['Looping: ' num2str(ntrain) '/' num2str(ntrain)];
            yphys_stimScope('start_Callback',gh.yphys.stimScope.start);
%             try
%                 %                 waitfor(gh.yphys.stimScope.counter,'String',finishedString);
%                 waitfor(gh.yphys.stimScope.start, 'String', 'Start'); %resume when uncaging button says 'start' again.
%             catch err
%                 disp(err.message)
%                 UA_Abort;
%                 return
%             end
%             disp(['Uncaging at position ' num2str(posID) ' done']);
        end
    end

    function grabAndAF(posID, singleRun) %grab image, set AF position, and run autofocus
        if nargin<2
            singleRun=false;
        end
        if strcmp(get(gh.mainControls.grabOneButton,'String'),'GRAB')
            grabAndWait();
            if ~singleRun
                %set AF ROI location
                af.closestspine.x1 = dia.hPos.allPositionsDS.roiPosition{dia.hPos.allPositionsDS.posID==posID}(1);
                af.closestspine.y1 = dia.hPos.allPositionsDS.roiPosition{dia.hPos.allPositionsDS.posID==posID}(2);
                runDriftCorrect('PosID',posID); %run autofocus and move to new Z position
            else
                t2=clock;
                disp(['Position ', num2str(posID), ' finished after ', num2str(round(etime(t2,dia.acq.startTime))),' s']);
                
            end
        end
    end

end

