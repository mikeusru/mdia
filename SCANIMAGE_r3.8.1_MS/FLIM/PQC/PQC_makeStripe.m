function [ret, nLines, acqLines] = PQC_makeStripe
%% function makeStripe
% This is a function to acquire image from PicoQuant card for FOCUS mode operation
% Takes data from data acquisition engine and formats it into a proper intensity image.
% ret: return code.
% nLines: requested lines.
% acqLines: acquired lines.

%% CREDITS
%  Created 9/07/2016, by Ryohei Yasuda (Ryohei.Yasuda@mpfi.org)
%  Based on makeStripe wrote by T. Pologruto & V. Iyer
%% ********************************************************

global state gh af spc
ret = 0;
nLines = -1e6;
acqLines = 0;
if state.internal.abortActionFunctions  || state.internal.stopActionFunctions %VI090409B
    stop(state.spc.internal.focusTimer);
    %delete(state.spc.internal.focusTimer);
    return
end

if state.internal.forceFirst
    state.internal.stripeCounter=0;
    state.internal.forceFirst=0;
end

try
    %[computeTime, drawTime] = deal(0);
    wrapWarning = false;
    
    %Start of frame actions
    if state.internal.stripeCounter==0
        
        %Update timer
        if state.internal.looping==1
            if state.cycle.cycling
                countdownPeriod = state.cycle.iterationDelay;
            else
                countdownPeriod = state.acq.repeatPeriod;
            end
            state.internal.secondsCounter=floor(countdownPeriod-etime(clock,state.internal.triggerTime));
            updateGUIByGlobal('state.internal.secondsCounter');
        end
        
        %First frame actions
        if state.internal.focusFrameCounter == 0
            
            %Initialize averaging buffer
            %if state.acq.averagingDisplay
                state.internal.tempImageDisplay = cell(1, state.init.maximumNumberOfInputChannels);
                for i=1:state.init.maximumNumberOfInputChannels
                    state.internal.tempImageDisplay{i} = zeros(size(state.acq.acquiredData{1}{i})); %VI092310A
                end
            %end
        end
        
        %%%VI092310A%%%%%%
        % Do circular permutation of state.acq.acquiredData - first cell always contains most-recent frame data
        acquiredDataLength = length(state.acq.acquiredData);
        state.acq.acquiredData = [state.acq.acquiredData(acquiredDataLength); state.acq.acquiredData(1:(acquiredDataLength-1))];
        %%%%%%%%%%%%%%%%%%
        
        
    end
         
    
    %Compute start/end columns
     
    %%%VI102209A: Determine lines to get%%%%
    linesPerStripe=state.acq.linesPerFrame/state.internal.numberOfStripes;
    ydata=[(1 + (linesPerStripe*state.internal.stripeCounter)) (linesPerStripe*(1 + state.internal.stripeCounter))];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    %tic;
    %stripeFinalData = uint16(getdata(state.init.aiFUDD, state.internal.samplesPerStripe)); % VI083109A %VI052109A %VI050509A % Gets enough data for one stripe from the DAQ engine for all channels present
    %stripeFinalData = uint16(stripeFinalData); %VI052109A
    %[ns,stripeFinalData] = state.init.hAIF.readAnalogData(state.internal.samplesPerStripe, state.internal.samplesPerStripe, 'native',1);
    %[ns,stripeFinalData] = state.init.hAI.readAnalogData(state.internal.samplesPerStripe,'native'); %VI090710A
    

    % PQC acquisition
    %disp([state.internal.stripeCounter, state.internal.frameCounter]);
    
    nCh = state.spc.acq.SPCdata.n_channels;

    startLine = ydata(1);
    stopLine = ydata(2);
    
    nFrame = state.internal.frameCounter + 1; %ceil(startLine1 / (state.acq.linesPerFrame));
    oddframe = mod(nFrame, 2) == 1;
%     if oddframe %odd
%         startLine0 = startLine;
%         stopLine0 = stopLine;
%     else
%         startLine0 = state.acq.linesPerFrame + startLine;
%         stopLine0 = state.acq.linesPerFrame + stopLine;
%     end

    [ret, nLines, acqLines] = PQC_acquireImage(1, stopLine);
    %
    if oddframe
        frame = spc.stack.image1F{1};
%        frame = spc.stack.stackF(:,:,:,1);
    else
        frame = spc.stack.image1F{1};
%        frame = spc.stack.stackF(:,:,:,2);
    end
    siz = size(frame);
    for ch = 1:state.spc.acq.SPCdata.n_channels
        sum_projection = reshape(sum(frame, 1), siz(2), siz(3));
        y1 = state.acq.linesPerFrame*(ch-1) + 1: state.acq.linesPerFrame*ch;
        image0 = sum_projection(y1, :)*state.spc.datainfo.pv_per_photon;
        image1 = image0(startLine:stopLine, :);
        stripeFinalData{ch} = image1;
    end
    ydata = [startLine, stopLine];


    if state.internal.stripeCounter == state.internal.numberOfStripes - 1
        state.internal.frameCounter = state.internal.frameCounter + 1;
    end


    if ~isempty(stripeFinalData{1})
        state.acq.previousStripe=stripeFinalData; %misha - backup previous stripe in case there's no data in the next one for some reason;
    elseif isempty(stripeFinalData) && ~isempty(state.acq.previousStripe) %use previous stripe if this one's empty to avoid getting an error and jumbling data
        stripeFinalData=state.acq.previousStripe;
%         disp('Warning - makeStripe.m called without any data. using previous stripe to avoid errors');
    else %if there is no previous stripe or current stripe, create an error.
        error('Error during readAnalogData(): \t%s\n',evnt.errorMessage);
    end
        %%%%%%%%%%%%%%%%%%%%
        %getTime = toc;
    
    %tic;

    setStatusString('Focusing...'); %VI102409A: Moved from below
    set(gh.configurationControls.etAcqDelay,'BackgroundColor',[1 1 1]); %VI102409A


    if size(stripeFinalData{1}(:)) < state.acq.pixelsPerLine * state.acq.linesPerFrame / state.internal.numberOfStripes %VI090609B
        fprintf(2, 'WARNING: Data acquisition underrun. Expected to acquire %s samples, only found %s samples in the buffer.', ...
            num2str(state.acq.pixelsPerLine * state.acq.linesPerFrame / state.internal.numberOfStripes), ... %VI090609B
            num2str(size(stripeFinalData{1}(:), 1)));
    end

    
    %%%VI102209A: Discard last line if indicated %%%%%%
    discardLineAfterReshape = false;
    discardLastLine =  state.acq.slowDimDiscardFlybackLine && (state.internal.stripeCounter + 1) == state.internal.numberOfStripes; %VI102810B
    
    if discardLastLine %VI102810B
        ydata(2) = ydata(2)-1;
        discardLineAfterReshape = ~mod(state.acq.linesPerFrame,2); %For even # of lines - discard line after reshape
        if ~discardLineAfterReshape %For odd # of lines - discard line now, before reshape
            linesPerStripe = linesPerStripe - 1;
            for ch = 1:nCh
                stripeFinalData{ch}(end,:) = [];
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    inputChannelCounter = 0;
    
    tempStripe = cell(state.init.maximumNumberOfInputChannels,1);
    

    %tic;
    for channelCounter = 1:nCh %state.init.maximumNumberOfInputChannels
        if state.internal.abortActionFunctions
            abortFocus;
            return;
        end
        
        if state.acq.acquiringChannel(channelCounter)  % if statement only gets executed when there is a channel to focus.
                tempStripe{channelCounter} = stripeFinalData{channelCounter};

    
            %%%VI09109A: Relocated below %%%%%%%%
            %             % Displays the current images on the screen as they are acquired.
            %             set(state.internal.imagehandle(channelCounter), 'CData', tempStripe{channelCounter}, ...
            %                 'YData',ydata);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%VI102209B: Discard last line if indicated %%%%%%
            if discardLineAfterReshape
                tempStripe{channelCounter}(end,:) = [];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            state.acq.acquiredData{1}{channelCounter}(ydata(1):ydata(2),:) = tempStripe{channelCounter}; %VI092210A
            
            %%%VI080911A%%%
            if state.acq.averagingDisplay
                avgFactor = min(state.acq.numAvgFramesDisplay,length(state.acq.acquiredData));
                
                if (state.internal.focusFrameCounter + 1) == 1
                    state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) = double(tempStripe{channelCounter});
                elseif (state.internal.focusFrameCounter + 1) <= avgFactor
                    state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) = ...
                        (state.internal.focusFrameCounter * state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) + double(tempStripe{channelCounter})) / (state.internal.focusFrameCounter + 1);
                else
                    state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) = ...
                        state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) + (double(tempStripe{channelCounter}) - double(state.acq.acquiredData{avgFactor+1}{channelCounter}(ydata(1):ydata(2),:))) / avgFactor;
                end
            else
                 state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) = double(tempStripe{channelCounter});
            end
        end
    end
    %%%%%%%%%%%%%%%%%%
    
    %computeTime = toc();
    
    %%%VI091009A%%%%%%%%%%%%%%%%%%
    %tic;
    for channelCounter = 1:state.init.maximumNumberOfInputChannels
        if state.acq.imagingChannel(channelCounter)
            set(state.internal.imagehandle(channelCounter), 'CData', state.internal.tempImageDisplay{channelCounter}); %Less than 1 ms.
%             if state.acq.averagingDisplay
%                 set(state.internal.imagehandle(channelCounter), 'CData', state.internal.tempImageDisplay{channelCounter});
% 
%             else
%                 set(state.internal.imagehandle(channelCounter), 'CData', state.acq.acquiredData{1}{channelCounter});
%             end
        end
    end
    %drawTime = toc;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Merge window update
    %tic;
    if state.acq.channelMerge
        %         if ((state.internal.focusFrameCounter == 1 || state.acq.slowDimDiscardFlybackLine) && state.internal.stripeCounter == 0) || discardLastLine %VI102810B %VI011109B
        state.internal.mergeStripe = uint8(zeros([size(tempStripe{find(state.acq.acquiringChannel,1)}) 3])); %VI111108A
        %         else
        %             state.internal.mergeStripe(:) = 0;
        %         end
        
        for i=1:state.init.maximumNumberOfInputChannels
            if state.acq.acquiringChannel(i)
                
                if state.acq.mergeColor(i) <=4 %Ensure that color is specified for this channel
                    if state.acq.averagingDisplay
                        chanImage = uint8((state.internal.tempImageDisplay{i}(ydata(1):ydata(2),:)-state.internal.lowPixelValue(i))/(state.internal.highPixelValue(i)-state.internal.lowPixelValue(i)) * 255);
                    else
                        chanImage = uint8((tempStripe{i}-state.internal.lowPixelValue(i))/(state.internal.highPixelValue(i)-state.internal.lowPixelValue(i)) * 255);
                    end
                    if state.acq.mergeColor(i) <= 3 %Red, green, or blue
                        state.internal.mergeStripe(:,:,state.acq.mergeColor(i)) = state.internal.mergeStripe(:,:,state.acq.mergeColor(i)) + chanImage;
                    elseif state.acq.mergeColor(i) == 4 %Grey
                        
                        state.internal.mergeStripe(:,:,1) = state.internal.mergeStripe(:,:,1) + chanImage;
                        state.internal.mergeStripe(:,:,2) = state.internal.mergeStripe(:,:,2) + chanImage;
                        state.internal.mergeStripe(:,:,3) = state.internal.mergeStripe(:,:,3) + chanImage;
                    end
                end
            end
        end
        
        %set(state.internal.mergeimage,'CData',state.internal.mergeStripe,'YData',ydata);
        state.acq.acquiredDataMerged(ydata(1):ydata(2),:,:) = state.internal.mergeStripe;
        set(state.internal.mergeimage,'CData',state.acq.acquiredDataMerged);
    end
    %mergeTime = toc;
    
    %tic;
    %drawnow; %VI091309A
    %displayTime = toc;
    
    if ~wrapWarning
        setStatusString('Focusing...');
    end
    
    if state.internal.abortActionFunctions
        state.internal.stripeCounter=0;
        abortFocus;
        return;
    else
        notify(state.hSI,'stripeAcquired'); %VI102610A
        state.internal.stripeCounter = state.internal.stripeCounter + 1; % increments the stripecounter to ensure proper image displays
    end
    
    if  state.internal.stripeCounter == state.internal.numberOfStripes
        notify(state.hSI,'frameAcquired'); %VI100410A
        state.internal.stripeCounter = 0;
        state.internal.focusFrameCounter = state.internal.focusFrameCounter + 1;
        if isfield(af,'oneFrameAcq') && ((af.oneFrameAcq.doGetSingleFrame && state.internal.focusFrameCounter==1) || af.oneFrameAcq.doGetMultipleETLframes || af.oneFrameAcq.doSetETLswing)% MISHA 042215 - notify listener if only 1 frame is needed
            af.oneFrameAcq.frameAcqTrigger;
        end
    end
    
    if state.internal.focusFrameCounter == (state.internal.numberOfFocusFrames + 1) && ~state.acq.infiniteFocus  %VI090409A: Fix off-by-1 error
        state.internal.stripeCounter=0;
        state.internal.stopActionFunctions=1; %VI090409B
        endFocus;
    end
    if state.internal.abortActionFunctions
        state.internal.stripeCounter=0;
        abortFocus;
        return;
    end
    
    %Use for profiling
    %fprintf(1,'Total Time=%05.2f \t GetTime=%05.2f \t WrapFixTime=%05.2f \t ComputeTime=%05.2f \t DrawTime=%05.2f \t MergeTime=%05.2f \n',1000*toc(hTotal),1000*getTime,1000*wrapFixTime,1000*computeTime,1000*drawTime,1000*mergeTime);
catch ME
    if state.internal.abortActionFunctions
        return
    else
        setStatusString('Error!');
        fprintf(2,'ERROR in callback function (%s): \t%s\n',mfilename,ME.message);
        most.idioms.reportError(ME);
    end
end


%VI032409A: Add as subfunction, rather than nested function, to avoid any performance issues
function acqDelayWarnFigDeleteFcn(hObject,eventdata)
global state;
state.internal.acqDelayWarnFig = [];
return;
