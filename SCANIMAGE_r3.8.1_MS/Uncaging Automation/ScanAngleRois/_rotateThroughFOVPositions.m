function [ elapsedTime ] = rotateThroughFOVPositions( mode,time,fovNum )
%rotateThroughFOVPositions is used to image through the different ROIs in
%the FOV.
%
% mode specifies the imaging mode. Its value is a string and can be
% 'focus','grab','uncage'
%
% time is a boolean value indicating whether the process should be timed.
% the default value is false.
%
% elapsedtime gives the time which it took for the whole thing to run.
global ua af state gh dia

if nargin<1
    mode='focus';
    fovNum=1:length(ua.fov.FOVposStruct);
    time=false;
elseif nargin<2
    fovNum=1:length(ua.fov.FOVposStruct);
    time=false;
elseif nargin<3
    fovNum=1:length(ua.fov.FOVposStruct);
end

dia.acq.pauseWhileRotateThroughFOV=false;

if time
    timerWhole=tic;
end

% if dia.etl.acq.etlOn %make sure Z limit is correct if ETL is on. if not, set it to current position.
%     [absPos,~]=motorGetPosition;
%     if absPos(3)~=dia.etl.acq.absZlimit
%         motorSetPositionAbsolute([absPos(1),absPos(2),dia.etl.acq.absZlimit]);
%         disp('ETL Z limit mismatch - moving motor to etl Z limit');
% %     dia.etl.acq.absZlimit=absPos(3);
% %     set(dia.handles.mdia.etlZLimitEdit,'String',num2str(dia.etl.acq.absZlimit));
% %     disp('ETL Z limit mismatch - Z limit set to current Z motor position');
%     end
% end

channel=af.params.channel;

if strcmp(mode,'focus') || strcmp(mode,'grab') || strcmp(mode,'uncage')

    for i=fovNum
        if strcmp(mode,'focus')
            ua.fov.FOVposStruct(i).images=[]; %get image structure ready for writing
        end
        ds=ua.fov.FOVposStruct(i).scanInfoDataset;
        zrange=range(ds.motorZ);
        poscount=length(ds);
        for j=1:poscount
            if dia.acq.pauseOn
                dia.acq.pauseWhileRotateThroughFOV=true;
%                 if isfield(dia.acq,'pauseFunc') && ~isempty(dia.acq.pauseFunc)
%                     dia.acq.pauseFunc{end+1}=@resumeRotateThroughFOVPositions;
%                 else
%                     dia.acq.pauseFunc{1}=@resumeRotateThroughFOVPositions;
%                 end
                try
                    disp('Paused rotating through FOV positions. Waiting Unpause button press');
                    waitfor(dia.handles.mdia.pausePushButton,'String','Pause');
                catch err
                    disp(err);
                end
                %                 return
            end
            posID=ds.oldMotorPosition(j);
            ua.acq.currentPos=posID;
            if ua.UAmodeON %set savepath
                state.files.savePath=ua.filestruct(j).currentSavepath;
                state.files.fileCounter=ua.filestruct(j).acqNum;
                updateFullFileName;
                ua.filestruct(j).acqNum=ua.filestruct(j).acqNum+1;
%                 if ua.fov.acq.preUncage
%                     state.files.savePath=ua.filestruct(j).pre_uncage_savepath;
%                 elseif ua.fov.acq.postUncage
%                     state.files.savePath=ua.filestruct(j).savepath;
%                 end
            end
            
            ua.fov.acq.currentPos=posID;
            if time
                timerMoveTemp=tic;
            end
            setScanAngleROI( posID, 1 ); %move to position
            if strcmp(mode,'focus')
                I=updateCurrentImage(channel);
                ua.fov.FOVposStruct(i).images{j}=I;
            elseif strcmp(mode,'grab')
                if dia.init.useOnePos && dia.acq.refPosition==posID %set appropriate Z scan parameters if reference position is scanned
                    state.acq.numberOfZSlices=af.params.scancount;
                    state.acq.zStepSize=af.params.zstep;
                    set(gh.motorControls.etNumberOfZSlices,'String',num2str(state.acq.numberOfZSlices));
                elseif dia.init.useOnePos && dia.acq.refPosition~=posID %otherwise set regular Z scanning parameters
                    state.acq.numberOfZSlices=dia.acq.numberOfZSlices;
                    state.acq.zStepSize=dia.acq.zStepSize;
                    set(gh.motorControls.etNumberOfZSlices,'String',num2str(state.acq.numberOfZSlices));
                end
                setupAOData; %needed to reset scanning shift
                if time
                    timerMove(j)=toc(timerMoveTemp);
                    timerImageTemp=tic;
                end
                if strcmp(get(gh.mainControls.grabOneButton,'String'),'GRAB')
                    grabAndWait();
                    for k=1:length(ua.positions)
                        if ua.positions(k).posnID==ua.acq.currentPos
                            af.closestspine.x1=ua.positions(k).roiPosition(1);
                            af.closestspine.y1=ua.positions(k).roiPosition(2);
                            break
                        end
                    end
                    if ~dia.acq.grabAndTimeOn
                        run_AF; %run autofocus and drift correct and append the FOV position struct. This may need to be done at the end of the whole thing instead.
                    end
                end
                if time
                    timerImage(j)=toc(timerImageTemp);
                end
            elseif strcmp(mode,'uncage')
                setupAOData; %needed to reset scanning shift
                showUncagingRois(ua.acq.currentPos,true); %bring up appropriate uncaging ROIs
                zdiff = abs(ds.zRoofOffset(j));
%                 zdiff=abs(ua.params.zRoof-state.motor.absZPosition);
                setUncagingDwell(zdiff);  %set dwell time
                %Start Uncaging
                
                %check if doing page controls mode.
                if ~isfield(ua.params,'pageacq') || ~ua.params.pageacq
                    %automated press of 'start' button in uncaging window
                    ntrain = state.yphys.acq.ntrain(state.yphys.acq.pulseN);
                    finishedString=['Looping: ' num2str(ntrain) '/' num2str(ntrain)];
                    yphys_stimScope('start_Callback',gh.yphys.stimScope.start);
                    try
                    waitfor(gh.yphys.stimScope.counter,'String',finishedString);
                    waitfor(gh.yphys.stimScope.start, 'String', 'Start'); %resume when uncaging button says 'start' again.
                    catch err
                        disp(err.message)
                        UA_Abort;
                        return
                    end
                    disp(['Uncaging at position ' num2str(ua.acq.currentPos) ' done']);
                elseif ua.params.pageacq
                    disp('The page acq button is on. I haven''t written the code for this yet.');
                end
            end
        end
    end
end

if time
    elapsedTime=toc(timerWhole);
    disp(['Rotating through ', num2str(poscount), ' positions took ' num2str(round(elapsedTime)) 's to run in '  mode ' mode with a z range of ' num2str(round(zrange*10)/10) 'µm']);
%     disp([ mode ' mode with a z range of ' num2str(round(zrange*10)/10) 'um and ' num2str(poscount) ' positions']);
    disp(['Inividual imaging times were ' num2str(round(timerImage*100)/100) 's']);
    disp(['Inividual move times were ' num2str(round(timerMove*100)/100) 's']);
else
    elapsedTime=[];
end

if dia.acq.pauseWhileRotateThroughFOV
    dia.acq.pauseWhileRotateThroughFOV=false;
    resumeFromPauseUA;
end

end

