function [ret, nLines, acqLines] = PQC_makeFrameByStripes
%% function PQC_makeFrameByStripe
% This is a function to acquire image from PicoQuant card for GRAB mode operation
% ret: return code.
% nLines: requested lines.
% acqLines: acquired lines.
%% CREDITS
%  Created 9/07/2016, by Ryohei Yasuda (Ryohei.Yasuda@mpfi.org)
%  Based on makeStripe wrote by T. Pologruto & V. Iyer
%% ********************************************************
global state gh af spc %misha - add af
ret = 0;
nLines = -1e-6;
acqLines = 0;
streamToDisk = state.files.autoSave && state.acq.framesPerFile && ~state.internal.snapping;  %VI092310A
grabStop = false;
acquiredDataLength = length(state.acq.acquiredData); %VI092210C
%fprintf('%d, stripe %d, frame %d\n', isempty(evnt), state.internal.stripeCounter, state.internal.frameCounter);

%Handle cases of stopped/aborted acq
if state.internal.stopActionFunctions
    return;
end
if state.internal.abortActionFunctions
    abortInActionFunction;
    return
end

%Reset counters, if needed
if state.internal.forceFirst
    state.internal.stripeCounter=0;
    state.internal.forceFirst=0;
end

%Open the shutter if it's time
if state.shutter.shutterOpen==0
    if all(state.shutter.shutterDelayVector==[state.internal.frameCounter state.internal.stripeCounter])
        openShutter;
    end
end

if state.internal.stripeCounter==0    
    %Handle displayed seconds counter, which behaves differently for external/internally triggered cases
    %state.internal.triggerTime=clock(); %NOTE: This was in previous version, but commented out here. It appears like a (mostly harmless) bug, as the variable is computed, and then actually stored to header, in the acquisitionStartedFcn(). This appears to be superfluous, and to corrupt the state variable. -- Vijay Iyer 5/14/10
    if state.internal.looping==1 && ~state.acq.externallyTriggered %count-down timer
        state.internal.secondsCounter=max(round(state.acq.repeatPeriod-etime(clock,state.internal.stackTriggerTime)),0);
    else %count-up timer
        try
            state.internal.secondsCounter=floor(etime(clock,state.internal.stackTriggerTime));
        catch
        end
    end
    
    set(gh.mainControls.secondsCounter,'String',num2str(state.internal.secondsCounter));
end

try
    %Is this the last time through this callback?
    if state.internal.frameCounter == state.acq.numberOfFrames - 1 && state.internal.stripeCounter==state.internal.numberOfStripes-1
        %state.internal.stopActionFunctions = 1; %would this be needed/useful?
        closeShutter;
        grabStop=true;
        af.frameAbsZPosition=state.motor.absZPosition; %Misha 032615 record position of current image for autofocus
        af.frameRelZPosition=state.motor.relZPosition;
    end
    
    if state.internal.abortActionFunctions
        abortInActionFunction;
        return
    end
    
    %Stop acquisition, start motor move, and park scanner, as needed/appropriate
    if grabStop
        stopGrab();
        
        if state.motor.motorOn && state.motor.zStepSize && state.acq.numberOfZSlices > 1 && state.internal.zSliceCounter < (state.acq.numberOfZSlices - 1) %VI080911A
            %Ryohei%%%%%%%%%%%%%%%%%%%%%
            page = 0;
            try
                page = state.internal.usePage;
            end
            if ~page
                
                motorStackStartMove(); %VI060610A
            end
            %Ryohei%%%%%%%%%%%%%%%%%%%%%
            %motorStackStartMove(); %VI060610A
            if state.acq.stackParkBetweenSlices
                scim_parkLaser('soft');
            end
        end
    end
    
    %%%Determine start/stop lines and columns for data to get
    linesPerStripe=state.acq.linesPerFrame/state.internal.numberOfStripes;
    startLine = 1 + state.internal.stripeCounter*linesPerStripe;
    stopLine = startLine+linesPerStripe-1;
    stopLineLoopDiscard = stopLine; %VI073010B - stopLine value to use in handling line-discard cases within loop over channels
    
    %%%Get the data
    [ret, nLines, acqLines] = PQC_acquireImage(0, stopLine);

    %frame = spc.stack.stackF(:,:,:,state.internal.frameCounter+1);
    frame = spc.stack.image1{state.internal.frameCounter+1};

    siz = size(frame);
    for ch = 1:1:state.spc.acq.SPCdata.n_channels
        sum_projection = reshape(sum(frame, 1), siz(2), siz(3));
        y1 = state.acq.linesPerFrame*(ch-1) + 1: state.acq.linesPerFrame*ch;
        image0 = sum_projection(y1, :)*state.spc.datainfo.pv_per_photon;
        image1 = image0(startLine:stopLine, :);
        frameFinalData{ch} = image1;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    lastStripe = (state.internal.stripeCounter == (state.internal.numberOfStripes - 1)); %VI073010A


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Determine value of 'averaging' flags
    averagingSave = state.acq.averaging && state.acq.numberOfFrames > 1;
    averagingDisplay = state.acq.averagingDisplay && state.acq.numberOfFrames > 1;

    if state.internal.abortActionFunctions
        abortInActionFunction;
        return
    end


    if state.spc.internal.showRealtimeImage

        %tic;
        pause(0.02);

        for channelCounter = 1:state.init.maximumNumberOfInputChannels
            if state.acq.acquiringChannel(channelCounter) % if statemetnt only gets executed when there is a channel to acquire.

                state.acq.acquiredData{1}{channelCounter}(startLine:stopLine,:) =  frameFinalData{channelCounter};

                %For averaging case, store rolling sum into double array
                if averagingSave
                    avgCounterSave = mod(state.internal.frameCounter,state.acq.numAvgFramesSave) + 1;
                    if avgCounterSave == 1
                        state.internal.tempImageSave{channelCounter}(startLine:stopLine, :) = double(state.acq.acquiredData{1}{channelCounter}(startLine:stopLine,:)); 
                    else
                        state.internal.tempImageSave{channelCounter}(startLine:stopLine,:) = ((avgCounterSave - 1) * state.internal.tempImageSave{channelCounter}(startLine:stopLine,:) ...
                            + double(state.acq.acquiredData{1}{channelCounter}(startLine:stopLine,:)))/avgCounterSave; 
                    end
                end

                if averagingDisplay
                    avgFactor = min(state.acq.numAvgFramesDisplay,length(state.acq.acquiredData));
                    indices = startLine:stopLine; %stripe indices
                    if (state.internal.frameCounter + 1) == 1

                        state.internal.tempImageDisplay{channelCounter}(indices,:) = double(state.acq.acquiredData{1}{channelCounter}(indices,:));

                    elseif (state.internal.frameCounter + 1) <= avgFactor
                        state.internal.tempImageDisplay{channelCounter}(indices,:) = ...
                            (state.internal.frameCounter * state.internal.tempImageDisplay{channelCounter}(indices,:) ...
                             + double(state.acq.acquiredData{1}{channelCounter}(indices,:))) / (state.internal.frameCounter + 1);
                    else
                        state.internal.tempImageDisplay{channelCounter}(indices,:) = ...
                            state.internal.tempImageDisplay{channelCounter}(indices,:) + (double(state.acq.acquiredData{1}{channelCounter}(indices,:)) - double(state.acq.acquiredData{avgFactor+1}{channelCounter}(indices,:))) / avgFactor;
                    end

                end

            end

        end

        %computeTime = toc();


        %tic;

        %Draw data
        for channelCounter = 1:state.init.maximumNumberOfInputChannels
            if state.acq.imagingChannel(channelCounter)
                if averagingDisplay
%                     set(state.internal.imagehandle(channelCounter), 'CData', ...
%                         state.internal.tempImageDisplay{channelCounter}(startLine:stopLine,:), 'YData', [startLine stopLine]);
                    set(state.internal.imagehandle(channelCounter), 'CData', ...
                        state.internal.tempImageDisplay{channelCounter});

                elseif ~averagingDisplay
%                     set(state.internal.imagehandle(channelCounter), 'CData', ...
%                         state.acq.acquiredData{1}{channelCounter}(startLine:stopLine,:), 'YData', [startLine stopLine]); %VI092210C
                    set(state.internal.imagehandle(channelCounter), 'CData', ...
                        state.acq.acquiredData{1}{channelCounter}); %VI092210C
                end
            end
        end
        %drawTime = toc;

        %tic;
        if state.acq.channelMerge && ~state.acq.mergeFocusOnly
            if averagingDisplay
                makeMergeStripe(state.internal.tempImageDisplay,[startLine stopLine],discardLastLine); %VI102810A %VI092210C
            else
                makeMergeStripe(state.acq.acquiredData{1},[startLine stopLine],discardLastLine); %VI102810A %VI092210C
            end
        end
    end
    %mergeTime = toc;
    %
    %Update figures/GUI status
    setStatusString('Acquiring...');
    
    %Signal stripeAcquired event
    notify(state.hSI,'stripeAcquired'); %VI102610A
    
    %Increment stripeCounter
    state.internal.stripeCounter = state.internal.stripeCounter + 1;
    
    %Handle end of frame (and acquisition), if reached
    if lastStripe %VI073010A %finished a frame!
        state.internal.stripeCounter = 0;
        state.internal.totalFrameCounter = state.internal.totalFrameCounter+1;
        
        % tic;
        if ~notify(state.hSI,'frameAcquired'); %VI100410A
            %disp('q');
            return;
        end
        %disp('c');
        if isfield(af,'params') && ~streamToDisk %add images to autofocus if not streaming to disk.
            try
                if af.params.useAcqForAF && ~state.spc.acq.spc_takeFLIM%MISHA - 1-30-15 - add images to autofocus structure if they are required
                    addToAF();
                end
            end
        end
        
        %Write Data
        if 0 %streamToDisk  %VI092310A %VI092210A
            
            if averagingSave && avgCounterSave == state.acq.numAvgFramesSave
                
                %Check to see if it's time to start a new file (i.e. a new frame chunk)
                frameCount =  (state.internal.frameCounter + 1)/state.acq.numAvgFramesSave + (state.internal.zSliceCounter) * state.acq.numberOfFrames/state.acq.numAvgFramesSave;
                handleFileChunking(frameCount);
                
                for channelCounter = 1:state.init.maximumNumberOfInputChannels % Loop through all the channels
                    if ~isempty(state.internal.tempImageSave{channelCounter}) %VI092210C
                         appendFrame(state.files.tifStream,state.internal.tempImageSave{channelCounter}(1:state.internal.storedLinesPerFrame,:)); %VI092210C %VI111609A
                        if isfield(af,'params') %check if autofocus has been initialized
                            if af.params.useAcqForAF && af.params.channel==channelCounter && ~state.spc.acq.spc_takeFLIM%MISHA - 1-30-15 - add images to autofocus structure if they are required
                                addToAF();
                            end
                        end
                    end
                end
                
                state.internal.storedFrameCounter = state.internal.storedFrameCounter + 1;
                
            elseif ~averagingSave
                
                %Check to see if it's time to start a new file (i.e. a new frame chunk)
                frameCount =  (state.internal.frameCounter + 1) + (state.internal.zSliceCounter) * state.acq.numberOfFrames;
                handleFileChunking(frameCount);
                
                %Append this frame's data to the current stream
                for channelCounter = 1:state.init.maximumNumberOfInputChannels % Loop through all the channels
                    if ~isempty(state.acq.acquiredData{1}{channelCounter}) %VI092210C
                         appendFrame(state.files.tifStream,state.acq.acquiredData{1}{channelCounter}(1:state.internal.storedLinesPerFrame,:)); %VI092210C %VI111609A
                    end
                end
                
                state.internal.storedFrameCounter = state.internal.storedFrameCounter + 1;
            end
        end
        
        % writeTime = toc;
        
        %%%VI092210C: REMOVED %%%%%
        %         %Store recently acquired frame to running data buffer, if in use
        %         if runningDataLength
        %             for chanCount = 1:state.init.maximumNumberOfInputChannels
        %                 state.acq.runningData{1}{chanCount}= state.acq.acquiredData{chanCount}(:,:,acquiredDataIdx);
        %             end
        %         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %         if state.internal.frameCounter == state.acq.numberOfFrames %finished the specified # Frames
        if state.internal.frameCounter == state.acq.numberOfFrames - 1
            set(gh.mainControls.framesDone,'String',num2str(state.internal.frameCounter + 1));
            %DEQ20101222endAcquisition;% ResumeLoop, parkLaser, Close Shutter, appendData, reset counters,...
            
            feval(state.hSI.hEndAcquisition);
        else
            state.internal.frameCounter = state.internal.frameCounter + 1;	% Increments the frameCounter to ensure proper image storage and display
            set(gh.mainControls.framesDone,'String',num2str(state.internal.frameCounter)); %Update frameCounter display (reflects frame count, rather than # frames/done; use 'set' rather than updateGUIByGlobal() to speed performance
            drawnow expose; %VI110409A
        end
        
    end
    
    %Use for profiling
    % fprintf(1,'Total Time=%05.2f \t GetTime=%05.2f \t ComputeTime=%05.2f \t DrawTime=%05.2f \t MergeTime=%05.2f \t WriteTime=%05.2f \n',1000*toc(hTotal),1000*getTime,1000*computeTime, 1000*drawTime,1000*mergeTime, 1000*writeTime);
    % toc(hTotal)
catch ME
    
    if state.internal.abortActionFunctions
        abortInActionFunction;
        return
    else
        setStatusString('Error!');
        fprintf(2,'ERROR in callback function (%s): \t%s\n',mfilename,ME.message);
        most.idioms.reportError(ME);
    end
end
return;

%% HELPER FUNCTIONS

%Handle 'file chunking' dictated by frames/file values
function handleFileChunking(frameCount)
global state

if ~isinf(state.acq.framesPerFile)  && (state.acq.framesPerFile == 1 || mod(frameCount + 1,state.acq.framesPerFile)==1)
    close(state.files.tifStream);
    fileChunkCounter = ceil((frameCount + 1)/state.acq.framesPerFile);
    fileName  = [state.files.fullFileName '_' num2str(fileChunkCounter,'%03d') '.tif'];
    state.files.tifStream = scim_tifStream(fileName,state.acq.pixelsPerLine, state.internal.storedLinesPerFrame, state.headerString); %VI102209A
end

return;

%Paints a stripe of color-merged data based on the imageData at
function makeMergeStripe(imageData,yData,discardLastLine) %VI092210C: Eliminate posn argument

global state

yMask = yData(1):yData(2);

% if ((state.internal.frameCounter == 1 || state.acq.slowDimDiscardFlybackLine) && state.internal.stripeCounter == 0) || discardLastLine %VI010711A %VI102810A
state.internal.mergeStripe = uint8(zeros([length(yMask) size(imageData{find(state.acq.acquiringChannel,1)},2) 3]));
% else
%     state.internal.mergeStripe(:) = 0;
% end

for i=1:state.init.maximumNumberOfInputChannels
    if state.acq.acquiringChannel(i)
        if state.acq.mergeColor(i) <= 4
            chanImage = uint8(((double(imageData{i}(yMask,:))-state.internal.lowPixelValue(i))/(state.internal.highPixelValue(i)-state.internal.lowPixelValue(i)) * 255)); %VI092210C
            if state.acq.mergeColor(i) <= 3
                state.internal.mergeStripe(:,:,state.acq.mergeColor(i)) =  state.internal.mergeStripe(:,:,state.acq.mergeColor(i)) + chanImage;
            elseif state.acq.mergeColor(i) == 4
                state.internal.mergeStripe(:,:,1) = state.internal.mergeStripe(:,:,1) + chanImage;
                state.internal.mergeStripe(:,:,2) = state.internal.mergeStripe(:,:,2) + chanImage;
                state.internal.mergeStripe(:,:,3) = state.internal.mergeStripe(:,:,3) + chanImage;
            end
        end
    end
end

set(state.internal.mergeimage,'CData',state.internal.mergeStripe,'YData',yData);
state.acq.acquiredDataMerged(yMask,:,:) = state.internal.mergeStripe;

return;

function motorStackStartMove() %VI060610A

global state dia

%Update ScanImage position state variables and display to next position, in advance of move completion
%Interrupted moves can lead to X/Y position shifts. So we re-use the initially determined X/Y position in setting each new slice position -- Vijay Iyer 10/16/08
%However, when secondary motor controller is moved - do NOT re-use the initial X/Y positions.
%In this way, only one motor controller (primary or secondary) is ever used for the step to next slice
newZPosn = [];
if ~state.motor.motorZEnable %Move primary motor only. Covers 2 cases: 1) no secondary motor 2)XYZ-Z with motorZEnable=false
    state.motor.absZPosition = state.internal.initialMotorPosition(3) - state.acq.stackCenteredOffset + state.acq.zStepSize * (state.internal.zSliceCounter + 1);
    if state.motor.dimensionsXYZZ
        newZPosn = state.motor.absZPosition;
    else
        state.motor.absXPosition = state.internal.initialMotorPosition(1);
        state.motor.absYPosition = state.internal.initialMotorPosition(2);
    end
    
else %Move secondary motor
    if state.motor.dimensionsXYZZ
        state.motor.absZZPosition = state.internal.initialMotorPosition(4) - state.acq.stackCenteredOffset + state.acq.zStepSize * (state.internal.zSliceCounter + 1);
        newZPosn = state.motor.absZZPosition;
    else %XY-Z case
        state.motor.absZPosition = state.internal.initialMotorPosition(3) - state.acq.stackCenteredOffset + state.acq.zStepSize * (state.internal.zSliceCounter + 1);
        newZPosn = state.motor.absZPosition;
    end
end
motorUpdatePositionDisplay();

try
    if isempty(newZPosn)
        if dia.etl.acq.etlOn % MISHA - Check if ETL will be used for move
            motorOrETLMove([state.motor.absXPosition,state.motor.absYPosition,state.motor.absZPosition],1,1);
        else
            motorStartMove(); %Move primary motor only, in XYZ
        end
        %motorCompleteMove(); %RYOHEI CHANGE 12/15/2014
    else
        if dia.etl.acq.etlOn % MISHA - Check if ETL will be used for move
            motorOrETLMove([state.motor.absXPosition,state.motor.absYPosition,newZPosn],1,1);
        else
            motorStartMove(newZPosn); %Move primary or secondary motor only, in Z only
        end
        %motorCompleteMove(newPosn); %RYOHEICHANGE 12/15/2014
    end
catch ME
    %if moveSecZ
    if state.motor.motorZEnable && state.motor.dimensionsXYZZ
        state.motor.absZZPosition = state.motor.absZZPosition - state.acq.zStepSize; %restore to previous value if move failed to start
    else
        state.motor.absZPosition = state.motor.absZPosition - state.acq.zStepSize; %restore to previous value if move failed to start
    end
    motorUpdatePositionDisplay();
    ME.rethrow();
end

%Scale the power for each beam (if Power vs Z feature is enabled for that beam) -- vectorized operation
if state.init.eom.pockelsOn && state.init.eom.powerVsZEnable
    if state.motor.motorZEnable && state.motor.dimensionsXYZZ
        state.init.eom.stackPowerScaling = exp(state.init.eom.powerVsZEnable .* (state.motor.absZZPosition - state.internal.initialMotorPosition(4))./state.init.eom.powerLzArray); %VI010610A
    else
        state.init.eom.stackPowerScaling = exp(state.init.eom.powerVsZEnable .* (state.motor.absZPosition - state.internal.initialMotorPosition(3))./state.init.eom.powerLzArray); %VI010610A
    end
end


return;

%%%%%%%%%%%%%%%%%%%%
