function FLIM_Measurement(eventName, eventData)
%%%
%%%Should be called from User Functions "Acquisition Started"
%%%
global state gh gui spc
% disp(['Running User Fnc: FLIM_', eventName]); %% To see when the function is called.

%Run AF/Drift Correct system (Misha)
if strfind(eventName, 'motor')
    return;
end
MDIA_Measurement(eventName,eventData);

if strcmp(get(gh.mainControls.focusButton, 'String'), 'ABORT')
    focus = 1;
else
    focus = 0;
end
try
    if state.spc.acq.spc_takeFLIM || strcmp(state.spc.init.dllname, 'TH260lib') %&& (~focus)
        switch eventName
            case 'acquisitionStarting'
                if strcmp(eventData, 'LOOP')
                    disp('Loop starting...');
                else
                    if strcmp(state.spc.init.dllname, 'TH260lib')
                        spc.stack.image1 = {};
                        state.spc.internal.ifstart = 1;
                        PQ_startMeasurement(0);
                    else
                        FLIM_acquisitionStarting;
                    end
                end
            case 'focusDone'
                if strcmp(state.spc.init.dllname, 'TH260lib')
                    stop(state.spc.internal.grabTimer);
                    stop(state.spc.internal.focusTimer);
                end
                try
                    yphys_recoverRoi
                end
                if strcmp(state.spc.init.dllname, 'TH260lib')
                    PQ_dispFLIM(1, 1);
                    state.spc.internal.ifstart = 0;
                    state.files.autoSave = 1;
                end
            case 'acquisitionDone'
                if strcmp(state.spc.init.dllname, 'TH260lib')
                    stop(state.spc.internal.grabTimer);
                    stop(state.spc.internal.focusTimer);
                    PQ_acquisitionDone;
                    state.spc.internal.ifstart = 0;
                    state.files.autoSave = 1;
                else
                    FLIM_acquisitionDone;
                end
                try
                    yphys_recoverRoi
                end
                
            case 'sliceDone'
                if strcmp(state.spc.init.dllname, 'TH260lib')
                    PQ_acquisitionDone;
                else
                    FLIM_sliceDone;
                end

            case 'frameAcquired'
                if strcmp(state.spc.init.dllname, 'TH260lib')
%                     if focus    
%                         PQ_dispFLIM(1,1);
%                     end
                else
                    if ~focus
                        FLIM_frameAcquired;
                    end
                end

            case 'abortAcquisitionEnd'
                stop(state.spc.internal.grabTimer);
                stop(state.spc.internal.focusTimer);
                FLIM_abortAcquisitionEnd;
            case 'startTriggerReceived'
                FLIM_startTriggerReceived;
            case 'stripeAcquired'
                if strcmp(state.spc.init.dllname, 'TH260lib')
                    %PQ_acquireImage;
                else
                    FLIM_stripeAcquired;
                end
            case 'focusStart'
                if strcmp(state.spc.init.dllname, 'TH260lib')
                    PQ_startMeasurement(1);
                end
            otherwise
        end
    end
catch ME
    disp(['****************************************']);
    disp(['ERROR ', ME.message]);
    for i=1:length(ME.stack)
       disp(['    in ', ME.stack(i).name, '(Line: ', num2str(ME.stack(i).line), ')']);       
    end
    disp(['****************************************']);
end

%%
function FLIM_stripeAcquired


%%
function FLIM_frameAcquired
 global state spc gui
% %
if (~state.spc.acq.spc_average && state.spc.init.infinite_Nframes)
    if mod(state.internal.frameCounter,  state.spc.init.numSlicesPerFrames) == 0
        FLIM_pauseMeasurement;
        FLIM_imageAcq(0, 0);  %12 ms;
        FLIM_restartMeasurement;

    %else
        currentN = round((state.internal.frameCounter)/state.spc.init.numSlicesPerFrames)+1;
        
        spc.stack.stackF(:, :, :, currentN) = spc.imageMod;
        if currentN == 1
            img1 = spc.stack.stackF(:, :, :, 1);
        else
            img1 = spc.stack.stackF(:, :, :, currentN) - spc.stack.stackF(:, :, :, currentN-1);
        end
        
        e_time = toc(PQ_setParameters(1));
        time1 = (state.internal.frameCounter+2)*state.acq.msPerLine*state.acq.linesPerFrame/1000;
        r_time = time1 - e_time;
        %fprintf('%f\n', r_time*1000);
         if r_time > 0.025 || state.internal.frameCounter == 0
             if state.spc.init.spc_showImages
                if state.internal.frameCounter == 0
                    set(gui.spc.figure.projectAxes, 'CLimMode', 'Auto');
                else
                    set(gui.spc.figure.projectAxes, 'CLimMode', 'Manual');
                end
                set(gui.spc.figure.projectImage, 'CData', reshape(sum(img1,1), size(img1, 2), size(img1, 3)));
             end
         else
             if r_time < 0.001
                 fprintf('***********Busy: frame %d***********\n', state.internal.frameCounter/state.spc.init.numSlicesPerFrames);
             end
         end
    end
end

%%
function FLIM_sliceDone
global state spc gui gh

%disp('Begin FLIM_sliceDone function');
[armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
if armed
    FLIM_StopMeasurement;
    while armed
        pause(0.05);
        [armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
    end
    if state.spc.init.spc_dualB && state.internal.usePage 
        FLIM_getParameters;
        state.spc.acq.SPCdata.mem_bank = ~state.spc.acq.SPCdata.mem_bank;
        FLIM_setParameters;
    end
end
    
if state.internal.usePage
    closeShutter;
    binPage = floor((state.internal.zSliceCounter)/state.acq.numberOfBinPages);  

    framing = 0;
    framingPlusOne = 0;
    if ~isempty(state.yphys.acq.frame_scanning)
        %binPage = floor((state.internal.zSliceCounter)/state.acq.numberOfBinPages); 
        res = state.internal.zSliceCounter - binPage*state.acq.numberOfBinPages;
                %%%Putting new parameters.
                if (state.yphys.acq.frame_scanning(1)-1 == binPage) && (res == 0)
                    if ~state.spc.internal.frameDone
                        framing = 1;
                    else
                        framingPlusOne = 1;
                    end
                end
    end    

    if ~framingPlusOne
        if state.spc.init.infinite_Npages
            %s = tic;
            FLIM_imageAcq(0, 0);
            if state.internal.zSliceCounter == 1
                state.spc.internal.sumSpc = (zeros(size(spc.imageMod)));
            end
            if max(spc.imageMod(:))==2^16
                error('********ERROR******BOARD IS SATURATED!!**DECREASE #PAGES*********');
            end
            spc.imageMod = (spc.imageMod) - (state.spc.internal.sumSpc);
            spc_redrawSetting(0,1);
            if state.internal.zSliceCounter == (binPage)*state.acq.numberOfBinPages;
                fprintf('Finished acquisition. Saving ave page: %d (Slice: %d) into memory\n', binPage, state.internal.zSliceCounter);
                spc.stack.stackA(:, :, :, binPage) = spc.imageMod;
                state.spc.internal.sumSpc = state.spc.internal.sumSpc + spc.imageMod; %sum(spc.stack.stackA(:, :, :, 1:binPage), 4);
                %disp(size(state.spc.internal.sumSpc))
            end
            %toc(s);
        else
            FLIM_SetPage(binPage);
            state.spc.acq.page = binPage;
            fprintf('Ave page set to %d\n', binPage);
        end
    else
        state.spc.internal.sumSpc = zeros(size(spc.imageMod)); %Reset the summation at framing.
    end
    
    if sum(state.yphys.acq.uncagePage == state.internal.zSliceCounter) && isempty(state.yphys.acq.frame_scanning)
        %set etl to position where ROI overlaps with ribbon (Misha)
        rbn_setEtlForUncaging;
        yphys_uncage(1);
        uncaged = 1;
        flushAOData;
    else
        uncaged = 0;
    end
    
    %%
    if ~isempty(state.yphys.acq.frame_scanning)
                    if framing
                        state.acq.numberOfFrames = str2double(get(gh.mainControls.framesTotal, 'String'));
                        %state.acq.numberOfZSlices = str2num(get(gh.mainControls.slicesTotal, 'String'));
                        state.acq.numAvgFramesSave = 1; %state.acq.framesPerPage;
                        state.acq.numAvgFramesDisplay = 1; %state.acq.framesPerPage;
                        state.acq.averagingDisplay = 0;
                        state.acq.averaging = 0;
                        %state.acq.zStepSize = str2double(get(gh.motorControls.etZStepPerSlice, 'String')); 
                        %state.acq.numAvgFramesSave = 1;
                        %state.acq.numberOfZSlices = 1;
                        %state.acq.averagingDisplay = 0;
                        %state.acq.averaging = 0;
                        state.spc.acq.spc_average = 0;
                        state.spc.internal.frameDone = 1;        %%%%Framing will start!                
                        state.internal.zSliceCounter = state.internal.zSliceCounter - 1;
                        
                        spc_makeMirrorOutput();
                        linTransformMirrorData();
                        flushAOData;
                        
                    elseif framingPlusOne
                        %First frame after the frame.
                        state.acq.numberOfFrames = state.acq.framesPerPage;
                        %state.acq.numberOfZSlices = state.acq.numberOfPages;
                        state.acq.numAvgFramesSave = state.acq.framesPerPage;
                        state.acq.numAvgFramesDisplay = state.acq.framesPerPage;
                        state.acq.averagingDisplay = 1;
                        state.acq.averaging = 1;
                        %state.acq.zStepSize = 0;
                        state.acq.averagingDisplay = 0;
                        state.acq.averaging = 0;
                        state.spc.acq.spc_average = 1;
                        
                        
                        makeMirrorDataOutput();
                        linTransformMirrorData();
                        flushAOData;                        
                    end
                


                %size(state.acq.mirrorDataOutput)
                if framing || framingPlusOne
                    FLIM_setupScanning(0); %Setting up all parameters. This replace FLIM_setupParameters.
                    FLIM_ConfigureMemory; 
                    [armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);

                    %Sequencer setting
                    if state.spc.acq.SPCModInfo.module_type == 140 % || state.spc.acq.SPCModInfo.module_type == 150
                        FLIM_enable_sequencer (0);
                    elseif state.spc.acq.SPCModInfo.module_type == 150
                        FLIM_enable_sequencer (0);
                    elseif state.spc.acq.SPCModInfo.module_type == 730
                        FLIM_enable_sequencer (1);
                    end
                    %
                    FLIM_get_sequencer_state; %This is required for some reason.
                    FLIM_SetPage (0);
                %
                
                
                    FLIM_FillMemory(0);  %-1 is for all page!
                    [armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
                    if ~filled
                        pause(0.1);
                    end
                end
                %%%% 

                if state.spc.acq.spc_average
                    exportClocks();
                else
                    figure(gui.spc.figure.project);
                    exportClocks(-1, 1);
                end
                

                
    end
    %%
    
    %pause(0.05);
    tocData = toc(state.internal.pageTicID);
    %waitT = state.acq.pageInterval*state.internal.zSliceCounter-tocData;
    %if framing
        %waitT = state.acq.pageInterval - (tocData - st ate.spc.acq.timing(state.internal.zSliceCounter+1));
    %else
        waitT = state.acq.pageInterval - (tocData - state.spc.acq.timing(state.internal.zSliceCounter+state.spc.internal.frameDone));
    %end
    
    fprintf('tocData: %f\n', tocData);
    fprintf('frame: %f\n', state.internal.zSliceCounter+state.spc.internal.frameDone);
    fprintf('waitT: %f\n', waitT);
    
    if waitT > 0
       pause(waitT);
    end
    tocData = toc(state.internal.pageTicID);
    if ~framing
        if framingPlusOne
            fprintf('Done\n');
        end
        if uncaged
            fprintf('Page=%d, Ave page=%d time=%0.2f s (Dt=%0.2f s)  ***Uncaged***\n', state.internal.zSliceCounter, binPage, tocData, tocData - state.spc.acq.timing(state.internal.zSliceCounter+state.spc.internal.frameDone));
        else
            fprintf('Page=%d, Ave page=%d time=%0.2f s (Dt=%0.2f s)\n', state.internal.zSliceCounter, binPage, tocData, tocData - state.spc.acq.timing(state.internal.zSliceCounter+state.spc.internal.frameDone));
        end
                
    elseif framing
        fprintf('Frame acquisition started .....');

    end
    
    state.spc.acq.timing(state.internal.zSliceCounter+1+state.spc.internal.frameDone) = tocData;
    
    
else %If use page
    FLIM_imageAcq(0, 0);
    FLIM_FillMemory;
    spc_writeData(0);
    spc_maxProc_offLine;
    spc_redrawSetting;
end %If use page
%

[armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
%
FLIM_StartMeasurement;
%
[armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
%
if armed && ~measure && wait && ~timerout && filled
else
    fprintf('***ERROR: Page %d / %d, FLIM_StartMeasurement did not work correctly**\n', state.internal.zSliceCounter, binPage);
    FLIM_decode_test_state(0, 1);
    FLIM_StopMeasurement;
    FLIM_StartMeasurement;
end
%disp('End FLIM_sliceDone function');


%%
function FLIM_acquisitionDone
global state spc gui gh

state.spc.internal.ifstart = 0;
pause(0.05);
[armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
if armed
    FLIM_StopMeasurement;
    while armed
        pause(0.05);
        [armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
    end
    if state.spc.init.spc_dualB && state.internal.usePage 
        FLIM_getParameters;
        state.spc.acq.SPCdata.mem_bank = ~state.spc.acq.SPCdata.mem_bank;
        FLIM_setParameters;
    end
end

%%
state.files.fileCounter = state.files.fileCounter - 1;
updateFullFileName(0);
if state.internal.usePage && state.spc.acq.spc_average %Frame scanning has previrage.
        totalBinPages = floor(state.acq.numberOfZSlices / state.acq.numberOfBinPages);
        if state.spc.init.infinite_Npages
            fprintf('Saving ave page: %d (Page: %d)\n', totalBinPages, state.internal.zSliceCounter);
            FLIM_imageAcq(0, 0);       
            spc.stack.stackA(:, :, :, totalBinPages) = spc.imageMod - state.spc.internal.sumSpc;
            spc.imageMod = spc.stack.stackA(:, :, :, totalBinPages);
            spc_redrawSetting(0,1);
        end

        im1 = genericOpenTif(state.files.tifStreamFileName); %%%%Opening streamed file. 
        size(im1)
        %%
        saveFileCounter = state.files.fileCounter;
        for i=1:totalBinPages
          %Read and average scan image data 
            slicesPerPage = state.acq.numberOfBinPages*state.acq.numberOfChannelsImage;
            
            addFraming = 0;
            if ~isempty(state.yphys.acq.frame_scanning)
                addFraming = sum(i>=state.yphys.acq.frame_scanning(1))*str2double(get(gh.mainControls.framesTotal, 'String')) / state.spc.init.numSlicesPerFrames;
            end          
            
            im2 = im1(:,:,(i-1)*slicesPerPage+1+addFraming : i*slicesPerPage+addFraming);
            
            addTiming = 0;
            if ~isempty(state.yphys.acq.frame_scanning)
                if (i >= state.yphys.acq.frame_scanning(1))
                    addTiming = 1;
                end
            end
            
            state.internal.triggerTimeString = state.spc.internal.triggerTimeArray{(i-1)*state.acq.numberOfBinPages+1+addTiming}(1:end-1);
            display(state.internal.triggerTimeString);
            updateTriggerTime; %Updating header file.
            
          %%%%%Saving scanimage image
            first = 1;
            channelCounter2=1;
            for channelCounter = 1:state.init.maximumNumberOfInputChannels
                if getfield(state.acq, ['imagingChannel' num2str(channelCounter)]) ...	% if image is on
                        && getfield(state.acq, ['savingChannel' num2str(channelCounter)])	% and channel is saved
                    im3 = im2(:, :, channelCounter2:state.acq.numberOfChannelsImage:end);
                    im4 = mean(im3, 3);
                    if first
                        fileName = [state.files.fullFileName '.tif'];
                        imwrite(uint16(im4), fileName,  'WriteMode', 'overwrite', ...
                            'Compression', 'none', 'Description', state.headerString);	
                        first = 0;
                    else
                        imwrite(uint16(im4), fileName,  'WriteMode', 'append', ...
                            'Compression', 'none', 'Description', state.headerString);	
                    end
                    channelCounter2 = channelCounter2+1;
                end	
            end
            
          %%%%%%%FLIM reading begin
            state.spc.acq.page = i-1;
            slicesPerPage = state.acq.numberOfBinPages;
            if state.spc.init.infinite_Npages
                spc.imageMod = spc.stack.stackA(:, :, :, i);
                spc_redrawSetting(0,1);

            else
                disp(['page=', num2str(state.spc.acq.page)]);
                state.spc.acq.page = i-1;
                FLIM_imageAcq(1, 0);
            end
                        
            
            spc.scanHeader.internal.triggerTimeString = state.internal.triggerTimeString;
            spc.datainfo.triggerTime = state.internal.triggerTimeString;
            spc.datainfo.multiPages.page = state.spc.acq.page;
            
            try
                spc_auto(0);  %%%%%%%%%%%%%%%%ANALYSIS
            end
            spc_writeData(~(i==1))
          %%%%%%%FLIM reading end

            state.files.fileCounter = state.files.fileCounter + 1; %%%%%%%%%%%File Counter;
            
            if ~isempty(state.yphys.acq.frame_scanning)  %%%Add one for frame scanning
                if i == state.yphys.acq.frame_scanning(1)-1
                    state.files.fileCounter = state.files.fileCounter + 1;
                end
            end
            
            updateFullFileName(0);
            updateGUIByGlobal('state.files.fileCounter');
            
        end %i=1:totalBinPages
                
        
        %%%%%%When Frame is inserted...
        if ~isempty(state.yphys.acq.frame_scanning)
            saveFileCounter1 = state.files.fileCounter;
            state.files.fileCounter = saveFileCounter + state.yphys.acq.frame_scanning(1)-1;
            updateFullFileName(0);
            
           %%%%%Saving scanimage image
            numFrames = str2double(get(gh.mainControls.framesTotal, 'String')) / state.spc.init.numSlicesPerFrames;
            im2 = im1(:,:,(state.yphys.acq.frame_scanning(1)-1)*slicesPerPage + 1 : (state.yphys.acq.frame_scanning(1)-1)*slicesPerPage + numFrames);
            state.internal.triggerTimeString = state.spc.internal.triggerTimeArray{(state.yphys.acq.frame_scanning(1)-1)*state.acq.numberOfBinPages+1}(1:end-1);
            
            first = 1;
            for frame=1:numFrames
                channelCounter2=1;
                for channelCounter = 1:state.init.maximumNumberOfInputChannels
                    if getfield(state.acq, ['imagingChannel' num2str(channelCounter)]) ...	% if image is on
                            && getfield(state.acq, ['savingChannel' num2str(channelCounter)])	% and channel is saved
                        im3 = im2(:, :, channelCounter2:state.acq.numberOfChannelsImage:end);
                        im4 = mean(im3, 3);
                        if first
                            fileName = [state.files.fullFileName '.tif'];
                            imwrite(uint16(im4), fileName,  'WriteMode', 'overwrite', ...
                                'Compression', 'none', 'Description', state.headerString);	
                            first = 0;
                        else
                            imwrite(uint16(im4), fileName,  'WriteMode', 'append', ...
                                'Compression', 'none', 'Description', state.headerString);	
                        end
                        channelCounter2 = channelCounter2+1;
                    end	
                end           
            end
            %%%%%%%%%%%%%
            
            %%%Saving FLIM
            FLIM_saveFrameScanning;
            %state.files.fileCounter = state.files.fileCounter + 1;
            state.files.fileCounter = saveFileCounter1;
            updateFullFileName(0);
            updateGUIByGlobal('state.files.fileCounter');
            makeMirrorDataOutput(); %Clean up the mess.
            state.internal.updatedZoomOrRot = 1;
            state.spc.init.taskA.control('DAQmx_Val_Task_Unreserve'); %Clean up
            spc_redrawSetting(0, 1);

        end
            
%%   
elseif ~state.spc.acq.spc_average % Frame scanning
        
        
        FLIM_saveFrameScanning;
        
        state.files.fileCounter = state.files.fileCounter + 1;
        updateFullFileName(0);
        updateGUIByGlobal('state.files.fileCounter');
        makeMirrorDataOutput(); %Clean up the mess.
        state.internal.updatedZoomOrRot = 1;
        state.spc.init.taskA.control('DAQmx_Val_Task_Unreserve'); %Clean up
        spc_redrawSetting(0, 1);
        
%%
else % NOT Page
        FLIM_get_colTime;
        FLIM_StopMeasurement;
        FLIM_decode_test_state(0);
        if state.spc.init.spc_dualB
            %disp(['memory bank = ', num2str(state.spc.acq.SPCdata.mem_bank)])
        end
        error1 = FLIM_imageAcq(1, 0); %%Acq: 0.3s, Redrawing: 0.1 sec; Saving one file: 0.25 sec; Fastsaving: 0.015 sec
        if error1
                disp('ERROR in image acq');
        end
        spc_writeData(0);
        if state.acq.numberOfZSlices > 1
            spc_maxProc_offLine;
            spc_saveAsTiff(state.spc.files.maxfullFileName, 0, 0);
        end
        %
        state.files.fileCounter = state.files.fileCounter + 1;
        updateFullFileName(0);
        updateGUIByGlobal('state.files.fileCounter');
end

try
    spc_auto(0);
end

%%
function FLIM_acquisitionStarting
global state gh spc gui dia

%% Initializing parameters
state.spc.internal.ifstart = 1;
state.internal.pageCounter = 0;
state.internal.binPageCounter = 0;
state.spc.acq.page = 0;
state.spc.acq.timing = 0;
spc.stack.stackA = [];
spc.stack.stackF = [];
state.spc.internal.sumSpc = [];
state.acq.stackParkBetweenSlices = 0;
state.spc.internal.frameDone = 0;
state.spc.internal.triggerTimeArray = {};

if state.internal.usePage
    state.acq.numberOfFrames = state.acq.framesPerPage;
    state.acq.numberOfZSlices = state.acq.numberOfPages;
    state.acq.numAvgFramesSave = state.acq.framesPerPage;
    state.acq.numAvgFramesDisplay = state.acq.framesPerPage;
    state.acq.averagingDisplay = 1;
    state.acq.averaging = 1;
    state.acq.zStepSize = 0;
else
    state.acq.numberOfFrames = str2double(get(gh.mainControls.framesTotal, 'String'));
    state.acq.numberOfZSlices = str2num(get(gh.mainControls.slicesTotal, 'String'));
    state.acq.numAvgFramesSave = state.acq.framesPerPage;
    state.acq.numAvgFramesDisplay = state.acq.framesPerPage;
    state.acq.averagingDisplay = 1;
    state.acq.averaging = 1;
    state.acq.zStepSize = str2double(get(gh.motorControls.etZStepPerSlice, 'String'));
end
if ~state.spc.acq.spc_average
    state.acq.numAvgFramesSave = 1;
    state.acq.numberOfZSlices = 1;
    state.acq.averagingDisplay = 0;
    state.acq.averaging = 0;
end
if state.acq.numberOfFrames == 1
    state.acq.averagingDisplay = 0;
    state.acq.averaging = 0;
end


%%

FLIM_setupScanning(0); %Setting up all parameters. This replace FLIM_setupParameters.

if ~strcmp(state.spc.init.dllname, 'TH260lib')
    FLIM_ConfigureMemory; 
    [armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
    %Sequencer setting
    if state.spc.acq.SPCModInfo.module_type == 140 % || state.spc.acq.SPCModInfo.module_type == 150
        FLIM_enable_sequencer (0);
    elseif state.spc.acq.SPCModInfo.module_type == 150
        FLIM_enable_sequencer (0);
    elseif state.spc.acq.SPCModInfo.module_type == 730
        FLIM_enable_sequencer (1);
    end
    %
    FLIM_get_sequencer_state; %This is required for some reason.
    FLIM_SetPage (0);
%
    FLIM_FillMemory(-1);  %-1 is for all pages
    [armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
    if ~filled
        pause(0.1);
    end
end
%
scan_size_y = state.spc.acq.SPCdata.scan_size_y;
scan_size_x = state.spc.acq.SPCdata.scan_size_x;
if dia.acq.doRibbonTransform %misha
    scan_size_y = state.acq.linesPerFrame;
    scan_size_x = state.acq.pixelsPerLine;
end
res = 2^state.spc.acq.SPCdata.adc_resolution;
frames_per_page = state.spc.acq.SPCdata.scan_rout_x;
scan_size_x = scan_size_x*frames_per_page;
%
if state.internal.usePage
%    
    spc.stack.stackA = zeros(res, scan_size_x, scan_size_y, state.acq.numberOfBinPages);
    if ~isempty(state.yphys.acq.frame_scanning)
        nFrames = str2double(get(gh.mainControls.framesTotal, 'String'));
        nFrames = nFrames/state.spc.init.numSlicesPerFrames;
        spc.stack.stackF  = zeros(res, scan_size_x, scan_size_y, nFrames);
    end
    disp('Page=0, Ave page=0 time=0.00 s (Timer started)');
    state.internal.pageTicID = tic; 
%
elseif ~state.spc.acq.spc_average
    spc.stack.stackF = zeros(res, scan_size_x, scan_size_y/state.spc.init.numSlicesPerFrames, floor(state.acq.numberOfFrames/state.spc.init.numSlicesPerFrames));
else
    spc.stack.stackA = zeros(res, scan_size_x, scan_size_y, 1);
end

if state.spc.acq.spc_average
    exportClocks();
else
    figure(gui.spc.figure.project);
    exportClocks(-1, 1);
end
%

[armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);

if armed
    FLIM_StopMeasurement; %Is this required?
end

if ~strcmp(state.spc.init.dllname, 'TH260lib')
    FLIM_decode_test_state(0, 0);
end

FLIM_StartMeasurement;
%
if ~strcmp(state.spc.init.dllname, 'TH260lib')
    [armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0, 0);
    if armed && ~measure && wait && ~timerout && filled
        %disp('FLIM started');
    else
        disp(['***ERROR: FLIM_StartMeasurement did not work correctly**\n']);
        FLIM_decode_test_state(0, 1);
        FLIM_StopMeasurement;
        FLIM_StartMeasurement;
        FLIM_decode_test_state(0, 1);
    end
else
end

%%
function FLIM_abortAcquisitionEnd
global state

FLIM_StopMeasurement;
if ~state.spc.acq.spc_average
    state.spc.init.taskA.control('DAQmx_Val_Task_Unreserve');
end

%%
function FLIM_startTriggerReceived
global state spc
time1 = datestr(now, 'YYYY/mm/dd HH:MM:SS.FFF');
%fprintf('*****************Trigger receved: %s ********************\n', time1);
if state.internal.zSliceCounter == 0
    state.spc.acq.triggerTime = time1;
end
if state.internal.usePage
    state.spc.internal.triggerTimeArray{state.internal.zSliceCounter+1+state.spc.internal.frameDone} = time1;    
end
if ~state.spc.acq.spc_average
    state.spc.internal.tic1 = tic;
end

%This causes some strange images sometimes. Only for bug fixing.
% FLIM_get_scan_clk_state;
% pause(0.05);
% [armed, measure, wait, timerout] = FLIM_decode_test_state (0, 1);
% if measure
%     disp(['Measurement in progress']);
% else
%     i = 1;
%     while ~measure && i < 5
%         [armed, measure, wait, timerout] = FLIM_decode_test_state (0, 0);
%         i=i+1;
%     end
%     if i > 5
%         FLIM_get_scan_clk_state;
%         disp(['****Measurement may NOT be started****Line289']);
%         [armed, measure, wait, timerout] = FLIM_decode_test_state (0, 1);
%     end
% end
%
%pause(0.05);

%disp('END FLIM_startTriggerReceived');


%%
function updateTriggerTime
global state

changingStr = {'state.internal.triggerTimeString'};
strStr = [1];

for i=1:length(changingStr)
    line1 = strfind(state.headerString, [changingStr{i}, ' = ']);
    line2 = strfind(state.headerString(line1:min(line1+100, length(state.headerString))), ';');
    
    if length(line2) > 0
        line2 = line1 + line2(1) - 2;
        lineStr = state.headerString(line1:line2);
        if strStr(i)
            str1 = eval(changingStr{i});
            str1 = [str1, '        '];
            length1 = length(spc.headerstr(line1+ length(changingStr{i})+ 3 + 1 : line2 - 1));
            state.headerString(line1+ length(changingStr{i})+ 3 + 1 : line2 - 1) = str1(1:length1);
        else
            str2 = num2str(eval(changingStr{i}));
            str2 = [str2, '        '];
            length2 = length(spc.headerstr(line1+ length(changingStr{i})+ 3  : line2));
            %str2(1:length2)
            state.headerString(line1+ length(changingStr{i})+ 3 : line2) = str2(1:length2);
        end
    end
    %% + 1, -1 is for ''
end

%%
function FLIM_saveFrameScanning
global state spc gui

h1 = waitbar(0, 'Saving files: 0', 'Name', 'Saving files', 'WindowStyle', 'modal', 'Pointer', 'watch');  
if state.spc.init.infinite_Nframes
    %FLIM_imageAcq(0, 0); %Last figure
    %spc.stack.images{state.acq.numberOfFrames} = spc.imageMod;
    %numFrames = floor(state.acq.numberOfFrames / state.spc.init.numSlicesPerFrames);
    numFrames = size(spc.stack.stackF, 4);
else
    numFrames = state.acq.numberOfFrames;
end
for frameCounter = 1: numFrames
    state.spc.acq.page = frameCounter-1;
    if ~state.spc.init.infinite_Nframes
        FLIM_imageAcq(0, 0);
    else
        if frameCounter == 1
            spc.imageMod = spc.stack.stackF(:, :, :, 1); %images{1};
        else
            spc.imageMod = spc.stack.stackF(:, :, :, frameCounter)-spc.stack.stackF(:, :, :, frameCounter-1);
        end
    end
    if frameCounter == 1
        spc_writeData(0);
    else
        spc_saveAsTiff(state.spc.files.fullFileName, 1, 0);
    end
    %if mod(frameCounter, 10) == 0 
        img1 = spc.imageMod;
        set(gui.spc.figure.projectImage, 'CData', reshape(sum(img1,1), size(img1, 2), size(img1, 3)));
        waitbar(frameCounter/numFrames, h1, sprintf('Saving frame %d', frameCounter));
        pause(0.001);
    %end  
end
close(h1);
