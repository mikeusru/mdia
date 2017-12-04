function [fastFinal, slowFinal, pockelsInd] = rbn_setRibbon( ax,ribbonPoly )
%rbn_setRibbon( ax ) sets up the scanning ribbon

global dia state gh

xsiz = get(ax,'XLim');
ysiz = get(ax,'YLim');
sizeImage = [ysiz(2) xsiz(2)];
% [x, y]=getline(ax);
% [xpt, ypt] = getPointsFromAxes(ax, 'Cursor', 'crosshair', 'nomovegui', 1); %VI071310A
if nargin<2
    axes(ax);
    [~,xpt,ypt] = roipoly;
    dia.acq.ribbon.RelativeRibbonPoly=[xpt/diff(xsiz),ypt/diff(ysiz)];
else
    xpt=ribbonPoly(:,1)*diff(xsiz);
    ypt=ribbonPoly(:,2)*diff(ysiz);
end

rbn_setRibbonXY(xpt,ypt,sizeImage);
% xpt=round(xpt);
% ypt=round(ypt);
% 
% x = state.acq.scanShiftFast + ((state.init.scanAngularRangeReferenceFast * state.acq.scanAngleMultiplierFast)/state.acq.zoomFactor) * (xpt-sizeImage(2)/2) / sizeImage(2); %VI042311A
% y = state.acq.scanShiftSlow + ((state.init.scanAngularRangeReferenceSlow * state.acq.scanAngleMultiplierSlow)/state.acq.zoomFactor) * (ypt-sizeImage(1)/2) / sizeImage(1); %VI042311A
% x=x*state.init.voltsPerOpticalDegree;
% y=y*state.init.voltsPerOpticalDegree;
% 
% %% inpolygon method
% newPoly=extendPoly([x,y],(1-state.acq.fillFraction)*state.internal.scanAmplitudeFast/state.acq.zoomFactor,pi/50); %make way to expand this in more efficient way... currently there's a lot of wasted scanning.
% newPoly=newPoly{1};
% xEx=newPoly(:,1);
% yEx=newPoly(:,2);
% scaledMirrorDataOutput=state.acq.mirrorDataOutput;
% 
% inFull=inpolygon(scaledMirrorDataOutput(1:end-state.internal.lengthOfXData,1),scaledMirrorDataOutput(1:end-state.internal.lengthOfXData,2),xEx,yEx);
% scaledMirrorDataOutput=scaledMirrorDataOutput(inFull,:);
% inSmall=inpolygon(scaledMirrorDataOutput(:,1),scaledMirrorDataOutput(:,2),x,y);
% 
% scaledMirrorDataDiv=diff(scaledMirrorDataOutput(:,1));
% scaledMirrorDataDiv=[0;scaledMirrorDataDiv];
% startPockelsAndImageOffset = round((state.acq.acqDelay) * state.acq.outputRate);
% 
% inSmallShifted=circshift(inSmall,startPockelsAndImageOffset);
% dia.acq.ribbon.inSmall=inSmallShifted;
% 
% dia.acq.ribbon.xy=[x,y];
% dia.acq.ribbon.xExyEx=[xEx,yEx];
% dia.acq.ribbon.mirrorDataOutput=scaledMirrorDataOutput;
% dia.acq.ribbon.inFull=inFull;
% dia.acq.ribbon.blankCanvas=zeros(floor(sizeImage));
% 
% %% pixel reference matrix
% scanToCollectRatio=state.init.hAI.sampClkRate/state.acq.outputRate;
% 
% pixelRef=double(inSmallShifted);
% 
% pixelRef2=repmat(pixelRef',scanToCollectRatio,1); 
% pixelRef2=pixelRef2(:);
% %close tails to avoid errors
% pixelRef2(1)=0;
% pixelRef2(end)=0;
% roundBinInd=floor(length(find(pixelRef2))/state.acq.binFactor)*state.acq.binFactor;
% 
% pixelRef2=logical(pixelRef2);
% 
% lineLabel=1:state.acq.linesPerFrame; 
% lineLabel=repmat(lineLabel,state.internal.lengthOfXData,1); %divided by two because bidirectional
% lineLabel=lineLabel(:);
% lineLabel=lineLabel(inFull);
% lineLabel=repmat(lineLabel',scanToCollectRatio,1); 
% lineLabel=lineLabel(:);
% lineLabel=lineLabel(logical(pixelRef2));
% lineLabel=lineLabel(1:roundBinInd);
% lineLabel=max(reshape(lineLabel,state.acq.binFactor,[]),[],1);
% 
% % pixelsToLines gives the Y reference, also need X reference. then can do
% pixelMirrorRefBeforeShift=double(inSmall);
% pixelMirrorRef2=repmat(pixelMirrorRefBeforeShift',scanToCollectRatio,1); %note - this value may not always be 50... check just in case.
% pixelMirrorRef2=pixelMirrorRef2(:);
% pixelMirrorRef2(1)=0;
% pixelMirrorRef2(end)=0;
% pixelMirrorRef2=logical(pixelMirrorRef2);
% 
% 
% fastMirror=scaledMirrorDataOutput(:,1);
% slowMirror=scaledMirrorDataOutput(:,2);
% fastMirror=repmat(fastMirror',scanToCollectRatio,1);
% slowMirror=repmat(slowMirror',scanToCollectRatio,1);
% fastMirror=fastMirror(:);
% slowMirror=slowMirror(:);
% % disp(length(fastMirror)); %this was necessary to prevent a bug...
% % disp(length(pixelRef2));
% fastMirror=fastMirror(pixelMirrorRef2);
% slowMirror=slowMirror(pixelMirrorRef2);
% fastMirror=fastMirror(1:roundBinInd);
% slowMirror=slowMirror(1:roundBinInd);
% fastMirror=median(reshape(fastMirror,state.acq.binFactor,[]),1);
% slowMirror=median(reshape(slowMirror,state.acq.binFactor,[]),1);
% 
% xPxInd = sizeImage(2)*(fastMirror/state.init.voltsPerOpticalDegree-state.acq.scanShiftFast)/((state.init.scanAngularRangeReferenceFast * state.acq.scanAngleMultiplierFast)/state.acq.zoomFactor) + sizeImage(2)/2; 
% yPxInd = sizeImage(2)*(slowMirror/state.init.voltsPerOpticalDegree-state.acq.scanShiftSlow)/((state.init.scanAngularRangeReferenceSlow * state.acq.scanAngleMultiplierSlow)/state.acq.zoomFactor) + sizeImage(1)/2;
% xPxInd=round(xPxInd);
% yPxInd=round(yPxInd);
% 
% xyPixels=[xPxInd',(lineLabel)'];
% for i=1:max(xyPixels(:,2))
%     ind=xyPixels(:,2)==i;
%     xPixelValues=xyPixels(ind,1);
%     if numel(xPixelValues)>1
%         pixelJump=find(abs(diff(xPixelValues))>2); %in case there are breaks in the line
%         p = polyfit(1:length(xPixelValues),xPixelValues',1);
%     if isempty(pixelJump)
%         newXPixelValues=round(mean(xPixelValues)-length(xPixelValues)/2) : round(mean(xPixelValues)-length(xPixelValues)/2) + length(xPixelValues) -1;
%         if p(1)<0
%             newXPixelValues = fliplr(newXPixelValues);
%         end
%     else
%         xPixelSegment=xPixelValues(1:pixelJump(1));
%         newXsegment=round(mean(xPixelSegment)-length(xPixelSegment)/2) : round(mean(xPixelSegment)-length(xPixelSegment)/2) + length(xPixelSegment) -1;
%         if p(1)<0
%             newXsegment = fliplr(newXsegment);
%         end
%         newXPixelValues=newXsegment;
%         for j=1:length(pixelJump)
%             if j==length(pixelJump)
%                 maxInd=length(xPixelValues);
%             else
%                 maxInd=pixelJump(j+1);
%             end
%             xPixelSegment=xPixelValues(pixelJump(j)+1 : maxInd);
%             newXsegment=round(mean(xPixelSegment)-length(xPixelSegment)/2) : round(mean(xPixelSegment)-length(xPixelSegment)/2) + length(xPixelSegment) -1;
%             if p(1)<0
%                 newXsegment = fliplr(newXsegment);
%             end
%             newXPixelValues=[newXPixelValues,newXsegment];
%         end
%     end
%    xyPixels(ind,1)=newXPixelValues;
%     end
% end
% %correct for pixels out of bounds
% xyPixels(xyPixels(:,1)>floor(sizeImage(1)),1)=floor(sizeImage(1));
% xyPixels(xyPixels(:,1)<1)=1;
% xyPixels(xyPixels(:,2)>floor(sizeImage(2)),2)=floor(sizeImage(2));
% xyPixels(xyPixels(:,2)<1)=1;
% % dia.test.xyPixels=xyPixels;
% 
% dia.acq.ribbon.pixelIndex=sub2ind(floor(sizeImage),xyPixels(:,2),xyPixels(:,1));
% dia.acq.ribbon.xPxInd=xPxInd;
% dia.acq.ribbon.yPxInd=yPxInd;
% dia.acq.ribbon.workingPixels=pixelRef2;
% dia.acq.ribbon.pixelsToLines=lineLabel;
% dia.acq.ribbon.workingPixelLength=roundBinInd;
% dia.acq.ribbon.xyPixels=xyPixels;
% return
%%
%%%%%%%%%%%%%%%%%%%%%%%
% 
% scaledMirrorDataOutput=state.acq.mirrorDataOutput;
% ptDist=pdist2([x,y],scaledMirrorDataOutput);
% [~,tRibbon]=min(ptDist,[],2); %add way to ignore flyback line
% 
% sampleRate = state.init.hAO.sampClkRate;
% samplesPerLine = round(sampleRate * state.acq.msPerLine * 1e-3);
% % samplesPerFrame = state.acq.linesPerFrame * samplesPerLine;
% % newScaledMirrorDataOutput=zeros(size(scaledMirrorDataOutput));
% lineTime=state.acq.msPerLine * 1e-3;
% sampleTime=lineTime/samplesPerLine;
% [fastBase,slopeUp,slopeDown]= makeLineCommandFast(linspace(0, lineTime, samplesPerLine), 0, state.internal.scanAmplitudeFast);
% scanOvershoot=state.internal.scanAmplitudeFast/state.acq.fillFraction*(1-state.acq.fillFraction);
% sampleCounter=min(tRibbon); %start samples from beginning of ribbon
% ribbonLength=max(tRibbon)-min(tRibbon);
% fastFinal=nan(ribbonLength,1);
% pockelsInd=nan(ribbonLength,1);
% ii=1;
% linePosRef=[];
% while sampleCounter < max(tRibbon) %keep working until all samples are complete
%     t1=[sampleCounter; sampleCounter; sampleCounter+samplesPerLine; sampleCounter+samplesPerLine];
%     x1=[-state.internal.scanAmplitudeFast-scanOvershoot; state.internal.scanAmplitudeFast+scanOvershoot;...
%         -state.internal.scanAmplitudeFast-scanOvershoot; state.internal.scanAmplitudeFast+scanOvershoot];
%     [~,y0]=intersections(t1, x1, tRibbon,x);
%     if ~isempty(y0)
%         %         intercept1 = min(y0);
%         fastTemp=fastBase + (max(y0)+min(y0))/2;
%         fastTemp(fastTemp > max(y0)+scanOvershoot)=NaN; %maybe don't need to add a huge scan overshoot for each one? esp the smaller ones? needs testing...
%         fastTemp(fastTemp < min(y0)-scanOvershoot)=NaN;
%         fastTemp=fastTemp(~isnan(fastTemp));
%         intercept1 = min(fastTemp);
%         if ii>1 %make preamble segment
%             if lastIntercept>intercept1
%                 t1=lastIntercept/slopeDown;
%                 t2=intercept1/slopeDown;
%                 t=linspace(0,t2-t1,(t2-t1)/sampleTime);
%                 fastPre = slopeDown*t + lastIntercept;
%             else
%                 %                 t=(intercept1-lastIntercept)/slopeUp;
%                 t1=lastIntercept/slopeUp;
%                 t2=intercept1/slopeUp;
%                 t=linspace(0,t2-t1,(t2-t1)/sampleTime);
%                 fastPre = slopeUp*t + lastIntercept;
%             end
%             if length(fastPre)>2 %cut of beginning and end of preamble
%                 fastPre=fastPre(2:end-1);
%                 fastTemp=[ fastPre'; fastTemp];
%             end
%         end
%         pockelsTemp=zeros(size(fastTemp));
%         pockelsTemp(fastTemp < max(y0) & fastTemp > min(y0))=1;
%         pockelsInd(ii:ii+length(fastTemp)-1)=pockelsTemp;
%         fastFinal(ii:ii+length(fastTemp)-1)=fastTemp;
%         linePosRef=[linePosRef,[ii;sampleCounter]];
%         lastIntercept=intercept1;
%         ii=ii+length(fastTemp);
%         sampleCounter=sampleCounter+samplesPerLine;
%     else %this part may be totally unnecessary...
%         disp('warning - this isn''t supposed to happen');
%         fastTemp=fastBase;
%         fastFinal(ii:ii+length(fastTemp)-1)=fastTemp;
%         ii=ii+length(fastTemp);
%         sampleCounter=sampleCounter+samplesPerLine;
%     end
% end
% %at this point add some empty space to make sure it's a round number that
% %fits with the other stuff..?
% fastFinal=fastFinal(~isnan(fastFinal));
% pockelsInd=pockelsInd(~isnan(pockelsInd));
% % samplesPerFrame = length(fastFinal);
% 
% slowBase = makeFrameCommandSlow(linspace(0,(state.acq.linesPerFrame * state.acq.msPerLine * 1e-3), ...
%     (samplesPerLine * state.acq.linesPerFrame)), 0, state.internal.scanAmplitudeSlow);
% % slowBase=slowBase(min(tRibbon):max(tRibbon));
% % slowStart=min(slowBase);
% % slowEnd=max(slowBase);
% slowFinal=zeros(size(fastFinal));
% for i=1:size(linePosRef,2)-1
%     tempInd=linePosRef(1,i):linePosRef(1,i+1);
%     tempVal=linspace(slowBase(linePosRef(2,i)),slowBase(linePosRef(2,i+1)),length(tempInd));
%     slowFinal(tempInd)=tempVal;
% end
% %make flyback line if there's room
% flybackRoom=length(slowFinal) - linePosRef(1,end);
% if flybackRoom>0
%     slowFinal(linePosRef(1,end)+1:end)=linspace(slowFinal(linePosRef(1,end)),slowFinal(1),flybackRoom)';
% end
% 
% dia.acq.ribbon.fastMirrorOutput=fastFinal;
% dia.acq.ribbon.slowMirrorOutput=slowFinal;
% dia.acq.ribbon.pockelsIndex=logical(pockelsInd);
% dia.acq.ribbon.msPerLine=length(fastFinal)/size(linePosRef,2)/sampleRate/1e-3;
% dia.acq.ribbon.linesPerFrame=size(linePosRef,2);
% 
% %pixel reference for building images
% xPxInd = sizeImage(2)*(fastFinal/state.init.voltsPerOpticalDegree-state.acq.scanShiftFast)/((state.init.scanAngularRangeReferenceFast * state.acq.scanAngleMultiplierFast)/state.acq.zoomFactor) + sizeImage(2)/2; 
% yPxInd = sizeImage(2)*(slowFinal/state.init.voltsPerOpticalDegree-state.acq.scanShiftSlow)/((state.init.scanAngularRangeReferenceSlow * state.acq.scanAngleMultiplierSlow)/state.acq.zoomFactor) + sizeImage(1)/2; 
% dia.acq.ribbon.pixelRef=round([xPxInd,yPxInd]);
% dia.acq.ribbon.blankCanvas=zeros(floor(sizeImage));
% state.acq.linesPerFrame=size(linePosRef,2);
% state.acq.msPerLine=length(fastFinal)/size(linePosRef,2)/sampleRate/1e-3;
% return;
% 
% 
% function slow = makeFrameCommandSlow(t, scanOffset, scanAmplitude)
% % Construct slow scan dimension command for one frame
% 
% global state
% 
% % determine the type of scan and modulate behavior accordingly
% scanType = state.hSI.computeROIType(state.acq.scanAngleMultiplierFast, state.acq.scanAngleMultiplierSlow);
% 
% if strcmp(scanType,'point')
%     slow(1:length(t),1) = state.acq.scanShiftSlow;
% else
%     %Slow dimension flyback command can either be explicitly added, at start of the final line (i.e. if last line is blanked/skipped/ignored)
%     %Or, by default, no flyback command is given and the flyback practically/physically occurs at start of first line (of next frame)
%     if state.acq.slowDimFlybackFinalLine
%         rampLinesPerFrame = state.acq.linesPerFrame - 1;
%     else
%         rampLinesPerFrame = state.acq.linesPerFrame;
%     end
%     
%     slope1 = 2 * scanAmplitude/(1e-3 * state.acq.msPerLine*rampLinesPerFrame); %VI102209A
%     intercept1 = scanOffset - scanAmplitude;
%     
%     if state.acq.slowDimFlybackFinalLine
%         slope2 = -2*scanAmplitude/(1e-3 * state.acq.msPerLine); %VI032911A %flyback in the time it takes for one line
%         intercept2 = scanOffset + scanAmplitude;
%     end
%     
%     numberOfPositiveSlopePoints = rampLinesPerFrame*state.internal.lengthOfXData;
%     
%     slow1 = slope1*t + intercept1;
%     slow2 = [];
%     if ~state.acq.bidirectionalScan
%         if state.acq.slowDimFlybackFinalLine
%             slow2 = slope2*(t-(1e-3*state.acq.msPerLine*rampLinesPerFrame)) + intercept2;
%         end
%     else
%         if state.acq.staircaseSlowDim
%             slow1    = zeros(1,numberOfPositiveSlopePoints);
%             
%             stepVals = scanOffset + linspace(-scanAmplitude, scanAmplitude, rampLinesPerFrame);
%             for i=1:length(stepVals)
%                 slow1(((i-1)*state.internal.lengthOfXData+1):(i*state.internal.lengthOfXData)) = stepVals(i);
%             end
%             
%             %Account for data shift that can arise with long acqDelay values...
%             overage = round((state.acq.acqDelay + state.acq.scanDelay + state.acq.fillFraction * state.acq.msPerLine * 1e-3) ...
%                 * state.acq.outputRate) + 1 - state.internal.lengthOfXData;
%             if overage > 0
%                 slow1 = circshift(slow1,overage);
%             end
%         end
%         
%         if state.acq.slowDimFlybackFinalLine
%             slow2 = slope2*(t-(1e-3*state.acq.msPerLine*rampLinesPerFrame)) + intercept2;
%         end
%     end
%     
%     slow = [slow1(1:numberOfPositiveSlopePoints)'; slow2(numberOfPositiveSlopePoints+1:end)'];
% end
% 
% 
% function [fast,slope1,slope2] = makeLineCommandFast(t, scanOffsetFast, scanAmplitudeFast)
% % Construct fast scan dimension command for one line
% % For sawtooth/unidirectional scans, a cycloid waveform is used for the flyback
% % For bidirectional scans, a simple triangle wave is used for the command
% %
% % NOTE - The scanOffsetFast parameter passed in is, in current usage, always 0. Offset/shift is applied at last step during linTransformMirrorData().
% 
% global state
% 
% % state.internal.lengthOfXData = length(t);
% 
% if ~state.acq.bidirectionalScan
%     %need co calculate ms per line for each line... for this, need to
%     %figure out where slope of scan will intersect with ribbon edges
%     %(polygon)
%     %Key parameters
%     disp('Warning - only Bidirectional Scan supported for ribbon imaging');
%     %     rampTime = state.acq.fillFraction * (1e-3 * state.acq.msPerLine); %The 'true' ramp period, not including the settlingTime 'extension'
%     %     settlingTime = state.acq.scanDelay; %Time added to ramp portion of the waveform, extending the ramp amplitude and hence compensating for scan attenuation
%     %     flybackTime = (1e-3 * state.acq.msPerLine) - rampTime - settlingTime; % The period of the cycloid portion of the waveform
%     %
%     %     fast = zeros(state.internal.lengthOfXData,1);
%     %
%     %     %Ramp waveform portion
%     %     slope1 = 2 * scanAmplitudeFast/(1e-3 * state.acq.msPerLine * state.acq.fillFraction); %VI092610A
%     %     intercept1 = scanOffsetFast -scanAmplitudeFast - slope1 * settlingTime; %VI092610A
%     %     numRampPoints = round(state.internal.lengthOfXData * (rampTime + settlingTime) / (1e-3 * state.acq.msPerLine));
%     %
%     %     fast(1:numRampPoints) = slope1*t(1:numRampPoints) + intercept1;
%     %     %Cycloid waveform portion
%     %     cycloidVelocity = 2*pi/flybackTime;
%     %     cycloidAmplitude = abs(2*scanAmplitudeFast) + abs(slope1) * (settlingTime + flybackTime); %VI092610A %Amplitude adjustments to account for added ramp time and ongoing ramp waveform req'd for initial conditon matching
%     %
%     %     t2 = t(numRampPoints+1:end) - t(numRampPoints);
%     %     fast(numRampPoints+1:end) = fast(numRampPoints) + (-sign(scanAmplitudeFast)) *(cycloidAmplitude/(2*pi)) * (cycloidVelocity*t2 - sin(cycloidVelocity * t2)) + slope1*t2;
%     
% else
%     slope1 = (2*scanAmplitudeFast)/(1e-3*state.acq.msPerLine*state.acq.fillFraction); %VI092610A
%     slope2 = -slope1;
%     
%     intercept1 = scanOffsetFast - (scanAmplitudeFast/state.acq.fillFraction); %VI092610A
%     intercept2 = scanOffsetFast + (scanAmplitudeFast/state.acq.fillFraction); %VI092610A
%     
%     fast1 = slope1*t + intercept1;
%     fast2 = slope2*t + intercept2;
%     
%     fast = [fast1'; fast2'];
% end
% 
% 
% 
% 
% 
% 
% 
% 
% %%
% % %%%%%%%%%%
% % [t,tIdx]=sort(t,'ascend');
% % x=x(tIdx);
% % y=y(tIdx);
% % mirrorCenter=zeros(size(scaledMirrorDataOutput));
% % tspace=diff(t);
% % xy=[x y];
% % for i=1:(length(x)-1)
% %     for j=[1,2]
% %         mirrorCenter(t(i):t(i+1)-1,j)=linspace(xy(i,j),xy(i+1,j),tspace(i));
% %     end
% % end
% % 
% % 
% % [Maxima1,MaxIdx1] = findpeaks(scaledMirrorDataOutput(:,1));
% % if isempty(Maxima1)
% %     [Maxima1,MaxIdx1] = max(scaledMirrorDataOutput(:,1));
% % end
% % DataInv = 1.01*max(scaledMirrorDataOutput(:,1)) - scaledMirrorDataOutput(:,1);
% % [~,MinIdx1] = findpeaks(DataInv);
% % if isempty(MinIdx1)
% %     [~,MinIdx1]=max(DataInv);
% % end
% % Minima1 = scaledMirrorDataOutput(MinIdx1,1);
% % 
% % [Maxima2,MaxIdx2] = findpeaks(scaledMirrorDataOutput(:,2));
% % if isempty(Maxima2)
% %     [Maxima2,MaxIdx2] = max(scaledMirrorDataOutput(:,2));
% % end
% % DataInv = 1.01*max(scaledMirrorDataOutput(:,2)) - scaledMirrorDataOutput(:,2);
% % [~,MinIdx2] = findpeaks(DataInv);
% % if isempty(MinIdx2)
% %     [~,MinIdx2]=max(DataInv);
% % end
% % Minima2 = scaledMirrorDataOutput(MinIdx2,2);
% % for i = 1:length(x)
% %     [~,ptMaxInd]=sort(abs(MaxIdx1-t(i)),'ascend');
% %     if numel(Maxima1)==1 || Maxima1(ptMaxInd(1))>Maxima1(ptMaxInd(2)) %correct for false minima/maxima
% %         ptMaxima(i,1)=Maxima1(ptMaxInd(1));
% %     else
% %         ptMaxima(i,1)=Maxima1(ptMaxInd(2));
% %     end
% %     [~,ptMinInd]=sort(abs(MinIdx1-t(i)),'ascend');
% %     if numel(Minima1)==1 || Minima1(ptMaxInd(1))<Minima1(ptMaxInd(2)) %correct for false minima/maxima
% %         ptMinima(i,1)=Minima1(ptMinInd(1));
% %     else
% %         ptMinima(i,1)=Minima1(ptMinInd(2));
% %     end
% %     [~,ptMaxInd]=sort(abs(MaxIdx2-t(i)),'ascend');
% %     
% %     if numel(Maxima2)==1 || Maxima2(ptMaxInd(1))>Maxima2(ptMaxInd(2)) %correct for false minima/maxima
% %         ptMaxima(i,2)=Maxima2(ptMaxInd(1));
% %     else
% %         ptMaxima(i,2)=Maxima2(ptMaxInd(2));
% %     end
% %     [~,ptMinInd]=sort(abs(MinIdx2-t(i)),'ascend');
% %     if numel(Minima2)==1 || Minima2(ptMinInd(1))<Minima2(ptMinInd(2)) %correct for false minima/maxima
% %         ptMinima(i,2)=Minima2(ptMinInd(1));
% %     else
% %         ptMinima(i,2)=Minima2(ptMinInd(2));
% %     end
% %     ptCenter(i,:)=(ptMaxima(i,:)-ptMinima(i,:))/2+ptMinima(i,:);
% % end
% % ptOffset=ptCenter-[x,y];
% % mirrorOffset=zeros(size(scaledMirrorDataOutput));
% % tspace=diff(t);
% % for i=1:(length(x)-1)
% %     for j=[1,2]
% %         mirrorOffset(t(i):t(i+1)-1,j)=linspace(ptOffset(i,j),ptOffset(i+1,j),tspace(i));
% %     end
% % end
% % 
% % %set up for ribbon striping matrix
% % linesPerStripe=state.acq.linesPerFrame/state.internal.numberOfStripes;
% % stripeShapes=cell(state.internal.numberOfStripes,length(state.acq.acquiringChannel));
% % pxOffset=repmat(sizeImage/2,length(xpt),1)-[xpt,ypt];
% % pixelOffset=zeros(state.acq.pixelsPerLine,state.acq.linesPerFrame);
% % ypt=ypt(tIdx);
% % xpt=xpt(tIdx);
% % xPt=xpt/(sizeImage(2)-.5);
% % yPt=ypt/(sizeImage(1)-.5);
% % yptdiff=round(diff(ypt));
% % for i=1 : (size(pxOffset,1)-1)
% %     pixelOffset(round(ypt(i):ypt(i+1)-1),1) = linspace(pxOffset(i,1),pxOffset(i+1,1),yptdiff(i));
% % end
% 
% 
% % 
% % for i=1:size(stripeShapes,1)
% %     for j=1:size(stripeShapes,2)
% %         if state.acq.acquiringChannel(i)
% %             counter=1;
% %             for k=1:linesPerStripe
% %                 stripeShapes{j,i}(k,:)=[zeros(1,32), ones(1,64), zeros(1,32)];
% %                 counter=counter+64;
% %             end
% %             stripeShapes{j,i}(stripeShapes{j,i}==1)=1:2048;
% %         end
% %     end
% % end
% % 
% % dia.acq.ribbonStripeShapes=stripeShapes;
% % dia.acq.ribbon.mirrorOffset=mirrorOffset;
% % dia.acq.ribbon.x=x;
% % dia.acq.ribbon.y=y;
% 


