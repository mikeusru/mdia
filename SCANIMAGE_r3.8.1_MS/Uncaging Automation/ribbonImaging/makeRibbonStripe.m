function tempStripe = makeRibbonStripe(stripeFinalData)
% makeRibbonStripe(stripeFinalData) is similar to makeStripe but works for
% ribbon transform data
global dia state
if ~dia.acq.doRibbonTransform
    return
end
% blankImage = zeros(state.internal.storedLinesPerFrame, state.acq.pixelsPerLine * dia.acq.ribbonScale);

%%testing
% dia.testing.stripeFinalData=stripeFinalData;
% return

%Compute start/end columns
% [startColumnForStripeData endColumnForStripeData] = determineAcqColumns();

%determine lines to get
% linesPerStripe=state.acq.linesPerFrame/state.internal.numberOfStripes;
%ydata is beginning and end of stripe rows
% ydata=[(1 + (linesPerStripe*state.internal.stripeCounter)) (linesPerStripe*(1 + state.internal.stripeCounter))];
ydata=[1,size(dia.acq.ribbon.blankCanvas,1)];
%%

inputChannelCounter = 0;
% dia.test.stripeFinalData=stripeFinalData;
% return
tempStripe = cell(state.init.maximumNumberOfInputChannels,1);
% tempStripe2=dia.acq.ribbonStripeShapes(state.internal.stripeCounter+1,:)';
% dL=length(stripeFinalData);
% binFactor=floor(dL/length(dia.acq.ribbon.pixelRef));
% roundBinInd=floor(dL/state.acq.binFactor)*state.acq.binFactor;

% pixelRef=dia.acq.ribbon.pixelRef(dia.acq.ribbon.pockelsIndex,:);


for channelCounter = 1:state.init.maximumNumberOfInputChannels
    if state.internal.abortActionFunctions
        return
    end
    
    if state.acq.acquiringChannel(channelCounter)  % if statement only gets executed when there is a channel to focus.
        if state.acq.(['pmtOffsetAutoSubtractChannel' num2str(channelCounter)])
            offset = state.acq.(sprintf('pmtOffsetChannel%d',channelCounter)); % get PMT offset for channel
        else
            offset=0;
        end
        
        invert = (-1)^state.acq.(['inputVoltageInvert' num2str(channelCounter)]); %VI122309A

        %%%VI102209A: Relocated%%%%%%%
        %linesPerStripe=state.acq.linesPerFrame/state.internal.numberOfStripes;
        %ydata=[(1 + (linesPerStripe*state.internal.stripeCounter)) (linesPerStripe*(1 + state.internal.stripeCounter))];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        inputChannelCounter = inputChannelCounter + 1;
        
        if state.acq.bidirectionalScan
%             temp = reshape(stripeFinalData(:,inputChannelCounter) - offset,2*state.internal.samplesPerLine,linesPerStripe/2); %VI120511A %VI090609B
            temp = stripeFinalData(dia.acq.ribbon.workingPixels,inputChannelCounter)-offset;
            temp = temp(1:dia.acq.ribbon.workingPixelLength);
            temp = invert * sum(reshape(temp,state.acq.binFactor,[]),1)'; %VI062609A %VI090609A %VI122309A
%             temp = temp(dia.acq.ribbon.pockelsIndex);
%             tempStripe{channelCounter}=mat2cell(dia.acq.ribbon.blankCanvas,ones(1,size(dia.acq.ribbon.blankCanvas,1)),ones(1,size(dia.acq.ribbon.blankCanvas,2)));
%             for i=1:length(temp)
%                 if tempStripe{channelCounter}{pixelRef(i,1),pixelRef(i,2)}==0
%                     tempStripe{channelCounter}{pixelRef(i,1),pixelRef(i,2)}=temp(i);
%                 else
%                     tempStripe{channelCounter}{pixelRef(i,1),pixelRef(i,2)}=[tempStripe{channelCounter}{pixelRef(i,1),pixelRef(i,2)},temp(i)];
%                 end
%             end
            tempStripe{channelCounter}=dia.acq.ribbon.blankCanvas;
            tempStripe{channelCounter}(dia.acq.ribbon.pixelIndex)=temp;

%             tempStripe{channelCounter}=round(cellfun(@mean,tempStripe{channelCounter}));
%             temp_top = temp((startColumnForStripeData):(endColumnForStripeData),:);
%             temp_bottom = flipud(temp((startColumnForStripeData+state.internal.samplesPerLine):(endColumnForStripeData+state.internal.samplesPerLine),:)); %VI090609B
            %tempStripe{channelCounter} = reshape([temp_top; temp_bottom],state.acq.samplesAcquiredPerLine,lps)'; %VI062609A
            
            %tempStripe{channelCounter} = add2d(tempStripe{channelCounter},state.acq.binFactor)-offset; %VI062609A
%             
%             if state.internal.averageSamples
%                 tempStripe{channelCounter} = invert * reshape(mean(reshape([temp_top; temp_bottom],state.acq.binFactor,[]),1),state.acq.pixelsPerLine, linesPerStripe)'; %VI062609A %VI090609A %VI122309A
%             else
%                 tempStripe{channelCounter} = invert * reshape(sum(reshape([temp_top; temp_bottom],state.acq.binFactor,[]),1),state.acq.pixelsPerLine, linesPerStripe)'; %VI062609A %VI090609A %VI122309A
%             end
        else
            disp('ribbon imaging currently requires bidirectional scanning');
%             tempStripe{channelCounter} = reshape(stripeFinalData(:, inputChannelCounter) - offset, ... %VI120511A
%                 state.internal.samplesPerLine,linesPerStripe); %Extracts only Channel 1 Data %VI071509A: Don't transpose yet %VI090609B
%             
%             %Bin samples into pixels...
%             %tempStripe{channelCounter} = add2d(tempStripe{channelCounter}(:, startColumnForStripeData:endColumnForStripeData), state.acq.binFactor)-offset; %VI062609A %add2d converts tempStripe to double format
%             
%             if state.internal.averageSamples
%                 tempStripe{channelCounter} = invert * reshape(mean(reshape(tempStripe{channelCounter}(startColumnForStripeData:endColumnForStripeData,:),state.acq.binFactor,[]),1),state.acq.pixelsPerLine, linesPerStripe)'; %VI062609A, VI071509A, VI090609A, VI122309A
%             else
%                 tempStripe{channelCounter} = invert * reshape(sum(reshape(tempStripe{channelCounter}(startColumnForStripeData:endColumnForStripeData,:),state.acq.binFactor,[]),1),state.acq.pixelsPerLine, linesPerStripe)'; %VI062609A, VI071509A, VI090609A, VI122309A
%             end
        end
        
        %reshape to fit ribbon
        
%         nonBlankIndex=(tempStripe2{channelCounter}~=0);
%         dia.testing.ts3=tempStripe{channelCounter}(tempStripe2{channelCounter}(nonBlankIndex));
%         tempStripe2{channelCounter}(nonBlankIndex)=tempStripe{channelCounter}(tempStripe2{channelCounter}(nonBlankIndex));
%         dia.testing.tempStripe2=tempStripe2;
%         dia.testing.tempStripe=tempStripe;
        try
            state.acq.acquiredRibbonData{channelCounter}(ydata(1):ydata(2),:)=tempStripe{channelCounter}; %VI092210A
        catch
            state.acq.acquiredRibbonData{channelCounter}=tempStripe{channelCounter}; %VI092210A
        end
        %%%VI080911A%%%
%         if state.acq.averagingDisplay
%             avgFactor = min(state.acq.numAvgFramesDisplay,length(state.acq.acquiredData));
%             
%             if (state.internal.focusFrameCounter + 1) == 1
%                 state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) = double(tempStripe{channelCounter});
%             elseif (state.internal.focusFrameCounter + 1) <= avgFactor
%                 state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) = ...
%                     (state.internal.focusFrameCounter * state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) + double(tempStripe{channelCounter})) / (state.internal.focusFrameCounter + 1);
%             else
%                 state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) = ...
%                     state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:) + (double(tempStripe{channelCounter}) - double(state.acq.acquiredData{avgFactor+1}{channelCounter}(ydata(1):ydata(2),:))) / avgFactor;
%             end
%         end
    end
end
%%%%%%%%%%%%%%%%%%

%computeTime = toc();
%%%VI091009A%%%%%%%%%%%%%%%%%%
%tic;
return
for channelCounter = 1:state.init.maximumNumberOfInputChannels
    if state.acq.imagingChannel(channelCounter)
%         if state.acq.averagingDisplay
%             set(state.internal.imagehandle(channelCounter), 'CData', state.internal.tempImageDisplay{channelCounter}(ydata(1):ydata(2),:), ...
%                 'YData',ydata);
%         else
%             set(dia.handles.ribbonImage(channelCounter), 'CData', tempStripe{channelCounter}, ...
%                 'YData',ydata);
            set(state.internal.imagehandle(channelCounter), 'CData', tempStripe{channelCounter}, ...
                    'YData',ydata);
%         end
    end
end