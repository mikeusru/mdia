function endAcquisition
%% function endAcquisition
%%
% Function called at the end of the acquistion that will park the laser, close the shutter,
% write the data to disk, reset the counters (internal), reset the currentMode, and make the 
% Grab One and Loop buttons visible.
%
% Written By: Thomas Pologruto and Bernardo Sabatini
% Cold Spring Harbor Labs
% March 2, 2001
% 
%% MODIFICATIONS
% VI031108A Vijay Iyer 3/11/08 - Don't auto-save if data's been saved during acquisition
% VI082208A Vijay Ieyr 8/22/08 - Close tifstream for saveDuringAcquisition mode
% VI093008A Vijay Iyer 9/30/08 - Abort stack collection if movement failed
% VI100608A Vijay Iyer 10/06/08 - Handle MP-285 error conditions smartly 
% VI101008A Vijay Iyer 10/10/08 - Handle MP-285 failure to return home
% VI101508A Vijay Iyer 10/15/08 - Use new MP285RobustAction for executeGoHome and MP285FinishMove actions
% RY092909E Ryohei Yasuda 9/29/09 - Add FLIM and Page support. standard.ini and executeGrabOneCallback was modified too. Search for "Ryohei"
%
%% ******************************************************************
global state gh

% if user has aborted, then return
if state.internal.abortActionFunctions
    abortInActionFunction;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate MAx projections if necessary%%%%%%%%%%%%%%%%%%
%%TPMOD for roiCycles....7/21/03 % Code for displaying Max Projections
calculateMaxProjections;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Ryohei Begin%RY092909E%%%Check for FLIM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state.init.spc_on
        if state.spc.internal.ifstart && state.spc.acq.spc_takeFLIM
            acqFLIM = 1;
        end
    else
        acqFLIM = 0;
        state.spc.acq.spc_average = 1;
    end

    if acqFLIM
        FLIM_StopMeasurement;
        spc_stopGrab;
    else
        stopGrab;
    end

    scim_parkLaser;

    %%%%%%%%%%%%%%%%%%%%%%%Page Controls%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state.internal.usePage && state.acq.numberOfPages > 1
        %%Timing
        if state.internal.pageCounter == 0
            tic
            state.internal.pageTiming(1) = 0;
        else
            state.internal.pageTiming(state.internal.pageCounter+1) = toc;
        end
        %%Timing
        if state.internal.pageCounter + 1 == state.acq.numberOfPages
            %%%Finishing page
            state.internal.pageCounter = state.internal.pageCounter + 1;
            updateGUIByGlobal('state.internal.pageCounter');
            nextPage = floor(state.internal.pageCounter / state.acq.numberOfBinPages);

            state.pages.image{nextPage}=state.acq.acquiredData;
            if state.acq.numberOfBinPages == 1
                state.pages.internal{nextPage}=state.internal;
            end
             if acqFLIM
                 state.pages.triggerTime{state.internal.pageCounter} = state.spc.acq.triggerTime;
             else
                 state.pages.triggerTime{state.internal.pageCounter} = state.internal.dioTriggerTime;
             end
            if acqFLIM
               if strcmp(get(gh.spc.FLIMimage.loop, 'String'), 'LOOP')
                    set(gh.spc.FLIMimage.focus, 'Visible', 'on');
                    set(gh.spc.FLIMimage.grab, 'Visible', 'on');
                    stop(state.spc.acq.mt);
                    delete(state.spc.acq.mt);
               end
            end
            state.spc.acq.timing = state.internal.pageTiming;
            nPage = ceil(state.acq.numberOfPages / state.acq.numberOfBinPages);
            for i=0:nPage-1
                if acqFLIM
                    state.spc.acq.page = i;
                    state.spc.acq.triggerTime = state.pages.triggerTime{i*state.acq.numberOfBinPages+1};
                else
                    state.acq.triggerTime = state.pages.triggerTime{i*state.acq.numberOfBinPages+1};
                end
                infoPage = i + 1;
                state.acq.acquiredData = state.pages.image{infoPage};
                state.internal = state.pages.internal{infoPage};           
                doneAcquisition(i == nPage-1, acqFLIM);
            end
            state.internal.pageCounter = 0;
        else
            state.internal.pageCounter = state.internal.pageCounter + 1;
            if isfield(state, 'yphys')
                if state.yphys.acq.depolarize
                    if sum(state.internal.pageCounter == state.yphys.acq.startDep)
                        % depolarization voltage 65 = 0mV 85 = +20mV
    %                     putsample(state.yphys.init.phys_patch, 65/state.yphys.acq.commandSensV);
                        putsample(state.yphys.init.phys_patch, 75/state.yphys.acq.commandSensV)
                    elseif sum(state.internal.pageCounter == state.yphys.acq.stopDep)
                         putsample(state.yphys.init.phys_patch, 0);  
    %                    putsample(state.yphys.init.phys_patch, 65/state.yphys.acq.commandSensV)
                    end
                end
               %state.internal.pageCounter
               %state.yphys.acq.uncagePage
                if sum(state.internal.pageCounter == state.yphys.acq.uncagePage)
                    %disp('Stimlation');
                    %disp(state.internal.pageCounter);
                    uncageOnce;
                    pause(0.01);
                else
                    stim = get(gh.yphys.stimScope.Stim, 'value');
                    if stim
                        pause(0.15);
                    else
                        param = state.yphys.acq.pulse{3,state.yphys.acq.pulseN};
                        pause(param.sLength/1000 + 0.11);
                    end

                end
                closeShutter;
                scim_parkLaser;
    %             if acqFLIM
    %                 spc_stopGrab;
    %             else
    %                 stopGrab;
    %             end
            end
            state.internal.frameCounter = 1;
            updateGUIByGlobal('state.internal.frameCounter');
            updateGUIByGlobal('state.internal.pageCounter');

            nextPage = floor(state.internal.pageCounter / state.acq.numberOfBinPages);
            state.internal.binPageCounter = state.internal.pageCounter - nextPage * state.acq.numberOfBinPages;
            if state.acq.numberOfBinPages == 1
                state.pages.internal{state.internal.pageCounter} = state.internal;
            end
            if state.internal.binPageCounter == 1
                state.pages.internal{nextPage+1} = state.internal;
            end
            if state.internal.binPageCounter == 0  %LAST BIN;
                state.pages.image{nextPage} = state.acq.acquiredData;
            end
            if acqFLIM
                state.pages.triggerTime{state.internal.pageCounter} = state.spc.acq.triggerTime;
                if state.spc.acq.spc_image
                    setStatusString('Acquiring...');
                end
                state.spc.acq.page = nextPage;
                spc_putData(1);
                FLIM_SetPage (0);
                FLIM_SetPage (nextPage);
                FLIM_StartMeasurement;
                spc_startGrab;
                openShutter;
                spc_diotrigger;
            else
                state.pages.triggerTime{state.internal.pageCounter} = state.internal.dioTriggerTime;
                setStatusString('Acquiring...');
                putDataGrab;
                startGrab;
                openShutter;
                pause(0.2);
                dioTrigger;
            end
        end
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%END Page Controls%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%FRAME acquisition!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if acqFLIM
        if ~state.spc.acq.spc_average && ~state.internal.usePage
               if strcmp(get(gh.spc.FLIMimage.loop, 'String'), 'LOOP')
                    set(gh.spc.FLIMimage.focus, 'Visible', 'on');
                    set(gh.spc.FLIMimage.grab, 'Visible', 'on');
                    stop(state.spc.acq.mt);
                    delete(state.spc.acq.mt);
               end
                alldata = state.acq.acquiredData;
                state.spc.acq.SPCdata.scan_size_y = state.spc.acq.SPCdata.scan_size_y / state.acq.numberOfFrames;
                saveTriggerTime = state.spc.acq.triggerTime;
                for i=0:state.acq.numberOfFrames-1
                    if acqFLIM
                        state.spc.acq.page = i;
                        a1 = datenum(saveTriggerTime) + state.acq.msPerLine * state.acq.linesPerFrame * i/60/60/24;
                        state.spc.acq.triggerTime = datestr(a1);
                    else
                        a1 = datenum(saveTriggerTime) + state.acq.msPerLine * state.acq.linesPerFrame * i/60/60/24;
                        state.spc.acq.triggerTime = datestr(a1);
                    end
                    for j=find(state.acq.acquiringChannel)
                        state.acq.acquiredData{j} = alldata{j}(:,:,i+1);
                    end
                    doneAcquisition(i == state.acq.numberOfFrames-1, acqFLIM);
                end
                state.spc.acq.page = 0;
                state.internal.pageCounter = 0;
                state.spc.acq.SPCdata.scan_size_y = state.spc.acq.SPCdata.scan_size_y * state.acq.numberOfFrames;
                return;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Ryohei End%RY092909E%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now setup for another pass if possible....
if state.internal.zSliceCounter + 1 == state.acq.numberOfZSlices    
    doneAcquisition (1, acqFLIM);
elseif state.internal.zSliceCounter < state.acq.numberOfZSlices - 1
    % Between Acquisitions or ZSlices
    setStatusString('Next Slice...');
    if state.files.autoSave		% BSMOD - Check status of autoSave option
        setStatusString('Writing data...');
        writeData;
    end
    
    %TO051804a
    callUserFunction;
    
    state.internal.zSliceCounter = state.internal.zSliceCounter + 1;
    updateGUIByGlobal('state.internal.zSliceCounter');
    
    state.internal.frameCounter = 1;
    updateGUIByGlobal('state.internal.frameCounter');
    
    setStatusString('Acquiring...');
    
    putDataGrab;
    
    if MP285FinishMove(0)	% check that movement completed (e.g. a CR was sent back), but don't verify position. This proved too unreliable so far -- Vijay Iyer 10/06/08
        abortCurrent;  %VI093008A   
        return;
    end
        
    if (strcmp(get(gh.mainControls.grabOneButton, 'String'), 'GRAB') ...
            && strcmp(get(gh.mainControls.grabOneButton, 'Visible'),'on'))
        set(gh.mainControls.grabOneButton, 'enable', 'off');
        set(gh.mainControls.grabOneButton, 'enable', 'on');
    elseif (strcmp(get(gh.mainControls.startLoopButton, 'String'), 'LOOP') ...
            && strcmp(get(gh.mainControls.startLoopButton, 'Visible'),'on'))
        set(gh.mainControls.startLoopButton, 'enable', 'off');
        state.internal.abort=1;
        set(gh.mainControls.startLoopButton, 'enable', 'on');
    else
%%%%RY092909E Ryohei 9/29/09%%%%        
%         try; startGrab; catch; end
%         openShutter;
%         dioTrigger;
        if acqFLIM
            if state.spc.acq.spc_takeFLIM
                %spc_setupPixelClockDAQ_Specific;
                FLIM_FillMemory(0);
                FLIM_StartMeasurement;
            end
            spc_putData (0);
            spc_startGrab;
        else
            startGrab; 
        end
        openShutter;
        if acqFLIM && state.internal.zSliceCounter == 1
            spc_diotrigger;
        else
            dioTrigger;
        end
 %%%%%%
    end
end

%TO051804a - Call user function after saving data to a file.
%            Also, wrap with a try/catch.
function callUserFunction
global state;
%%%%%%%%%%%%%%%%%%User Function Call%%%%%%%%%%%%%%%%% TPMOD
try
    if state.userFcnGUI.UserFcnOn
        if (state.internal.snapping && state.acq.execUserFcnOnSnap) || ~state.internal.snapping
            executeUserFcn;
        end        
    end
catch
    disp('Error executing UserFunction: %s', lasterr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RY092909E Ryohei 9/29/09%%%%%%%%%%%%%%%%%%%%%%%
%%% Removed from the code inside
%%% if state.internal.zSliceCounter + 1 ==state.acq.numberOfZSlices
%%% else
function doneAcquisition (last_frame, acqFLIM)
global state;
global gh;

    % Done Acquisition since there are no more stacks....
    stopGrab;
    
    %TPMOD for SnapShot Mode....6/2/03
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state.internal.snapping
        doSnapShot;
        return
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Save the data to disk....
    if state.files.autoSave && ~state.acq.saveDuringAcquisition	% BSMOD - Check status of autoSave option  % VI031108A
        status=state.internal.statusString;
        setStatusString('Writing data...');
%%Ryohei Begin%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~state.spc.acq.spc_average
            saveNFrames = state.acq.numberOfFrames;
            state.acq.numberOfFrames = 1;
        end
%%Ryohei End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        writeData;
%%Ryohei Begin%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        if ~state.spc.acq.spc_average
            state.acq.numberOfFrames = saveNFrames;
        end
%%Ryohei End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        writeMaxData;
        setStatusString(status);
        state.files.fileCounter=state.files.fileCounter+1;
        updateGUIByGlobal('state.files.fileCounter');
        updateFullFileName(0);
    elseif state.acq.saveDuringAcquisition && ~isempty(state.init.tifStream) %VI031108A, VI082208A
        try
            close(state.init.tifStream);
            state.init.tifStream = [];
            state.files.fileCounter=state.files.fileCounter+1;
            updateGUIByGlobal('state.files.fileCounter');
            updateFullFileName(0);
        catch
            delete(state.init.tifStream,'leaveFile');
            errordlg('Failed to close an open TIF stream. A file may be corrupted.');
            state.init.tifStream = [];
        end
    end
    
    %TO051804a
    callUserFunction;
 
 %%%Ryohei Begin%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
 %%%Ryohei Begin%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isfield(state, 'yphys')
        if isfield(state.yphys, 'matchfile')
           %cd([state.files.savePath, 'spc']);
           if exist([state.files.savePath, 'spc'], 'file')
               fileNM = [state.files.baseName, '_match'];
               evalc ([fileNM '= state.yphys.matchfile']);
               filename1 = [state.files.savePath, 'spc', fileNM, '.mat'];
               save(filename1, fileNM);
           end
        end
    end
    if acqFLIM
            if state.spc.acq.spc_takeFLIM
                    state.files.fileCounter = state.files.fileCounter - 1;
                    updateFullFileName(0);
                    FLIM_imageAcq(1); %%Acq: 0.3s, Redrawing: 0.3 sec; Saving one file: 0.5 sec; Fastsaving: 0.015 sec
                    if state.internal.usePage || ~state.spc.acq.spc_average
                            if state.spc.acq.page == 0
                                spc_writeData(0);  %Fastheader = 1.
                            else
                                spc_writeData(1);
                            end
                    else
                            spc_writeData(0);
                    end
                    if state.acq.numberOfZSlices > 1
                            spc_maxProc;
                    end
                    spc_saveAsTiff(state.spc.files.maxfullFileName, 0, 0);
                    state.files.fileCounter = state.files.fileCounter + 1;
                    updateFullFileName(0);  
            end

            if last_frame
                    set(gh.spc.FLIMimage.grab, 'String', 'GRAB');
                    looping = strcmp(get(gh.spc.FLIMimage.loop, 'String'), 'STOP'); 
                    if ~looping
                            try
                                stop(state.spc.acq.mt);
                                delete(state.spc.acq.mt);
                            catch
                            end
                            set(gh.spc.FLIMimage.focus, 'Visible', 'on');
                            set(gh.spc.FLIMimage.grab, 'Visible', 'on');
                    else
                            set(gh.spc.FLIMimage.focus, 'Visible', 'off');
                            set(gh.spc.FLIMimage.grab, 'Visible', 'off');
                    end
                    %flushAOData;
                    set(gh.spc.FLIMimage.focus,'Enable','On');
                    set(gh.spc.FLIMimage.grab,'Enable','On');
                    set(gh.spc.FLIMimage.loop,'Enable','On');
            end
            if state.spc.acq.spc_takeFLIM
            %state.files.fileCounter = state.files.fileCounter - 1;
            try
                    spc_auto(1, ~last_frame);
            catch
                    disp('SPC_auto failed in ''endAcquisition.m''');
            end
            %state.files.fileCounter = state.files.fileCounter+1;
            end
    end %If acqFLIM
%%%Ryohei End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%Ryohei End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       

    if last_frame  %%Added by Ryohei RY092909E
        %TPMOD for roiCycles....7/10/03
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if state.internal.roiCycleExecuting % Doing user defined cycle... 
            loopROICycle;
            return
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

        scim_parkLaser;
        putDataGrab;

        state.internal.zSliceCounter = state.internal.zSliceCounter + 1;
        updateGUIByGlobal('state.internal.zSliceCounter');
        if state.acq.numberOfZSlices > 1   
            if MP285FinishMove(1)
                MP285Recover; %Interrupt the move..and get the position
                if state.motor.errorCond
                    fprintf(2,'ERROR (%s): Unable to verify correct completion of stack motion', mfilename);
                else
                    MP285FinishMove(1); %check the position and flag if it's not as expected
                end
            end

            if MP285RobustAction(@executeGoHome, 'return home upon stack completion', mfilename) %VI101508A
                abortCurrent; %VI101008A
                return;
            end
        end				

        if state.internal.looping==1
            setStatusString('Resuming Loop....');
            resumeLoop;
        else
            setStatusString('Ending Grab...');
            set(gh.mainControls.focusButton, 'Visible', 'On');
            set(gh.mainControls.startLoopButton, 'Visible', 'On');
            set(gh.mainControls.grabOneButton, 'String', 'GRAB');
            set(gh.mainControls.grabOneButton, 'Visible', 'On');
            turnOnMenus;
            setStatusString('');
        end
    end  %Added by Ryohei RY092909E

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RY092909E Ryohei begin 9/29/09%%%%%%%%%%%%%%%%%%%%%%%

function uncageOnce
%dwell in milisecond.

    global state;
    global gh;

        stop(state.yphys.init.scan_ao);
        stop(state.yphys.init.pockels_ao);

    stim = get(gh.yphys.stimScope.Stim, 'value');

    if stim
        yphys_sendStim;
        param = state.yphys.acq.pulse{2,state.yphys.acq.pulseN};
        disp('Stimulated from electrode!');
    else
        yphys_uncage(1);
        param = state.yphys.acq.pulse{3,state.yphys.acq.pulseN};
    end

%     rate = param.freq;
%     nstim = param.nstim;
%     dwell = param.dwell;
%     ampc = param.amp;
%     delay = param.delay;
    sLength = param.sLength;

    if stim
        pause(0.15);
    else
        pause(sLength/1000+0.1);
    end
    return;
    
%%%%%%%%Ryohei End