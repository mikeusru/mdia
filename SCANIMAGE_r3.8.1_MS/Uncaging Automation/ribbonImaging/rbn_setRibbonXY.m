function [ output_args ] = rbn_setRibbonXY( xpt,ypt,sizeImage )
%rbn_setRibbonXY( xpt,ypt ) sets the ribbon in X and Y
global dia state
xpt=round(xpt);
ypt=round(ypt);

x = state.acq.scanShiftFast + ((state.init.scanAngularRangeReferenceFast * state.acq.scanAngleMultiplierFast)/state.acq.zoomFactor) * (xpt-sizeImage(2)/2) / sizeImage(2); %VI042311A
y = state.acq.scanShiftSlow + ((state.init.scanAngularRangeReferenceSlow * state.acq.scanAngleMultiplierSlow)/state.acq.zoomFactor) * (ypt-sizeImage(1)/2) / sizeImage(1); %VI042311A
x=x*state.init.voltsPerOpticalDegree;
y=y*state.init.voltsPerOpticalDegree;

res = 2^state.spc.acq.SPCdata.adc_resolution;


%% inpolygon method
newPoly=extendPoly([x,y],(1-state.acq.fillFraction)*state.internal.scanAmplitudeFast/state.acq.zoomFactor,pi/50); %make way to expand this in more efficient way... currently there's a lot of wasted scanning.
newPoly=newPoly{1};
xEx=newPoly(:,1);
yEx=newPoly(:,2);
scaledMirrorDataOutput=state.acq.mirrorDataOutput;

inFull=inpolygon(scaledMirrorDataOutput(1:end-state.internal.lengthOfXData,1),scaledMirrorDataOutput(1:end-state.internal.lengthOfXData,2),xEx,yEx);
%make sure size of scan mirror path divides easily into bin factor. this
%fixes problems with FLIM.
roundedUp=ceil(length(find(inFull))/res)*res;
sizeDiff=roundedUp-length(find(inFull));
if sizeDiff>0
    inFull(find(~inFull,sizeDiff))=1;
end
scaledMirrorDataOutput=scaledMirrorDataOutput(inFull,:);
inSmall=inpolygon(scaledMirrorDataOutput(:,1),scaledMirrorDataOutput(:,2),x,y);
% floor(length(find(inFull))/state.acq.binFactor))/(state.acq.inputRate/state.acq.binFactor) * state.acq.outputRate
% scaledMirrorDataDiv=diff(scaledMirrorDataOutput(:,1));
% scaledMirrorDataDiv=[0;scaledMirrorDataDiv];
startPockelsAndImageOffset = round((state.acq.acqDelay) * state.acq.outputRate);
% startPockelsAndImageOffset = -40;

inSmallShifted=circshift(inSmall,startPockelsAndImageOffset);
dia.acq.ribbon.inSmallShifted=inSmallShifted;
dia.acq.ribbon.inSmall=inSmall;
dia.acq.ribbon.xy=[x,y];
dia.acq.ribbon.xExyEx=[xEx,yEx];
dia.acq.ribbon.mirrorDataOutput=scaledMirrorDataOutput;
dia.acq.ribbon.inFull=inFull;
dia.acq.ribbon.blankCanvas=zeros(floor(sizeImage));

%% pixel reference matrix
spc_imageShift=-state.acq.scanDelay*state.acq.outputRate;
binSize=state.acq.binFactor;

for imageType = 1:2
    if imageType==2
%                 pixelRef=double(circshift(inSmall,spc_imageShift));
        pixelRef = double(inSmall);
        %         binSize=2^state.spc.acq.SPCdata.adc_resolution;
        %         binSize=state.acq.binFactor;
        %         scanToCollectRatio=state.init.hAI.sampClkRate/state.acq.outputRate*res/binSize;
        flimscan_size_x=floor(length(dia.acq.ribbon.mirrorDataOutput)/state.acq.outputRate*(state.acq.inputRate/state.acq.binFactor));
        %         workingPixelsFLIM = round(linspace(1,flimscan_size_x,length(dia.acq.ribbon.inSmall)));
        %         workingPixelsFLIM = workingPixelsFLIM(inSmall);
        pixelRef = logical(round(interp1(1:length(pixelRef),pixelRef,linspace(1,length(pixelRef),flimscan_size_x))));
        lineLabel=1:state.acq.linesPerFrame;
        lineLabel=repmat(lineLabel,state.internal.lengthOfXData,1);
        lineLabel=lineLabel(:);
        lineLabel=lineLabel(inFull);
        lineLabelFLIM = round(interp1(1:length(lineLabel),lineLabel,linspace(1,length(lineLabel),flimscan_size_x)));
        fastMirror=scaledMirrorDataOutput(:,1);
        xLabelFLIM = sizeImage(2)*(fastMirror/state.init.voltsPerOpticalDegree-state.acq.scanShiftFast)/((state.init.scanAngularRangeReferenceFast * state.acq.scanAngleMultiplierFast)/state.acq.zoomFactor) + sizeImage(2)/2;
        xLabelFLIM = round(interp1(1:length(xLabelFLIM),xLabelFLIM,linspace(1,length(xLabelFLIM),flimscan_size_x)));
        xyPixels = fixBrokenLines(xLabelFLIM(pixelRef),lineLabelFLIM(pixelRef),sizeImage);
        flimDim1=repmat(xyPixels(:,2)',[res,1]);
        flimDim1=flimDim1(:);
        flimDim2=repmat(xyPixels(:,1)',[res,1]);
        flimDim2=flimDim2(:);
        flimDim3=(1:res)';
        flimDim3=repmat(flimDim3,[length(xyPixels),1]);
        dia.acq.ribbon.FLIMpixelIndex=sub2ind([floor(sizeImage),res],flimDim1,flimDim2,flimDim3);
        dia.acq.ribbon.FLIMblankCanvas=repmat(dia.acq.ribbon.blankCanvas,[1,1,res]);
        %         dia.acq.ribbon.xPxInd=xPxInd;
        %         dia.acq.ribbon.yPxInd=yPxInd;
        workingPixelsFLIM = double(circshift(pixelRef(:),round(spc_imageShift*length(pixelRef)/length(inSmall))));
%         workingPixelsFLIM = double(circshift(pixelRef,round(spc_imageShift)));

%         workingPixelsFLIM = logical(round(interp1(1:length(workingPixelsFLIM),workingPixelsFLIM,linspace(1,length(workingPixelsFLIM),flimscan_size_x))));
%         workingPixelsFLIM = double(pixelRef);
        workingPixelsFLIM = repmat(workingPixelsFLIM',res,1);
        workingPixelsFLIM = logical(workingPixelsFLIM(:));
        dia.acq.ribbon.FLIMworkingPixels = workingPixelsFLIM;
        %         dia.acq.ribbon.pixelsToLines=lineLabel;
        dia.acq.ribbon.FLIMworkingPixelLength=length(find(workingPixelsFLIM));
    else
        pixelRef=double(inSmallShifted);
        scanToCollectRatio=state.init.hAI.sampClkRate/state.acq.outputRate;
        M=mod(scanToCollectRatio,1);
        
        workingPixels = round(repmatWithRemainder( pixelRef , scanToCollectRatio, M));
        %     pixelRef2=repmat(pixelRef',scanToCollectRatio,1);
        %     pixelRef2=pixelRef2(:);
        
        %close tails to avoid errors
        workingPixels(1)=0;
        workingPixels(end)=0;
        roundBinInd=floor(length(find(workingPixels))/binSize)*binSize;
        %     if imageType==2
        %         roundBinInd=floor(roundBinInd/(res))*res;
        %     end
        workingPixels=logical(workingPixels);
        
        lineLabel=1:state.acq.linesPerFrame;
        lineLabel=repmat(lineLabel,state.internal.lengthOfXData,1);
        lineLabel=lineLabel(:);
        lineLabel=lineLabel(inFull);
        lineLabel = round(repmatWithRemainder( lineLabel , scanToCollectRatio, M));
        %     lineLabel=repmat(lineLabel',scanToCollectRatio,1);
        %     lineLabel=lineLabel(:);
        lineLabel=lineLabel(workingPixels);
        lineLabel=lineLabel(1:roundBinInd);
        %     if imageType==2
        %     lineLabel=max(reshape(lineLabel,res,[]),[],1);
        %     else
        lineLabel=max(reshape(lineLabel,binSize,[]),[],1);
        %     end
        % pixelsToLines gives the Y reference, also need X reference. then can do
        pixelMirrorRefBeforeShift=double(inSmall);
        pixelMirrorRef2 = round(repmatWithRemainder( pixelMirrorRefBeforeShift , scanToCollectRatio, M));
        %     pixelMirrorRef2=repmat(pixelMirrorRefBeforeShift',scanToCollectRatio,1); %note - this value may not always be 50... check just in case.
        %     pixelMirrorRef2=pixelMirrorRef2(:);
        pixelMirrorRef2(1)=0;
        pixelMirrorRef2(end)=0;
        pixelMirrorRef2=logical(pixelMirrorRef2);
        
        fastMirror=scaledMirrorDataOutput(:,1);
        slowMirror=scaledMirrorDataOutput(:,2);
        fastMirror = repmatWithRemainder( fastMirror , scanToCollectRatio, M);
        slowMirror = repmatWithRemainder( slowMirror , scanToCollectRatio, M);
        %     fastMirror=repmat(fastMirror',scanToCollectRatio,1);
        %     slowMirror=repmat(slowMirror',scanToCollectRatio,1);
        %     fastMirror=fastMirror(:);
        %     slowMirror=slowMirror(:);
        % disp(length(fastMirror)); %this was necessary to prevent a bug...
        % disp(length(pixelRef2));
        fastMirror=fastMirror(pixelMirrorRef2);
        slowMirror=slowMirror(pixelMirrorRef2);
        %     disp(size(fastMirror));
        %     disp(roundBinInd);
        fastMirror=fastMirror(1:roundBinInd);
        slowMirror=slowMirror(1:roundBinInd);
        
        %     if imageType==2
        %         fastMirror=median(reshape(fastMirror,res,[]),1);
        %         slowMirror=median(reshape(slowMirror,res,[]),1);
        %     else
        fastMirror=median(reshape(fastMirror,binSize,[]),1);
        slowMirror=median(reshape(slowMirror,binSize,[]),1);
        %     end
        xPxInd = sizeImage(2)*(fastMirror/state.init.voltsPerOpticalDegree-state.acq.scanShiftFast)/((state.init.scanAngularRangeReferenceFast * state.acq.scanAngleMultiplierFast)/state.acq.zoomFactor) + sizeImage(2)/2;
        yPxInd = sizeImage(1)*(slowMirror/state.init.voltsPerOpticalDegree-state.acq.scanShiftSlow)/((state.init.scanAngularRangeReferenceSlow * state.acq.scanAngleMultiplierSlow)/state.acq.zoomFactor) + sizeImage(1)/2;
        xPxInd=round(xPxInd);
        yPxInd=round(yPxInd);
        
        xyPixels = fixBrokenLines(xPxInd,lineLabel,sizeImage);
        
        % dia.test.xyPixels=xyPixels;
        %     if imageType==1
        dia.acq.ribbon.pixelIndex=sub2ind(floor(sizeImage),xyPixels(:,2),xyPixels(:,1));
        dia.acq.ribbon.xPxInd=xPxInd;
        dia.acq.ribbon.yPxInd=yPxInd;
        dia.acq.ribbon.workingPixels=workingPixels;
        dia.acq.ribbon.pixelsToLines=lineLabel;
        dia.acq.ribbon.workingPixelLength=roundBinInd;
        dia.acq.ribbon.xyPixels=xyPixels;
        %     else
        %         res = 2^state.spc.acq.SPCdata.adc_resolution;
        %         binRatio=res/binSize;
        %         if binRatio>1
        %             workingPixels=repmat(workingPixels,1,res/binSize);
        %             workingPixels=workingPixels(:);
        %         elseif binRatio<1
        %
        %         end
        %         flimDim1=repmat(xyPixels(:,2)',[res,1]);
        %         flimDim1=flimDim1(:);
        %         flimDim2=repmat(xyPixels(:,1)',[res,1]);
        %         flimDim2=flimDim2(:);
        %         flimDim3=(1:res)';
        %         flimDim3=repmat(flimDim3,[length(xyPixels),1]);
        %         dia.acq.ribbon.FLIMpixelIndex=sub2ind([floor(sizeImage),res],flimDim1,flimDim2,flimDim3);
        %         dia.acq.ribbon.FLIMblankCanvas=repmat(dia.acq.ribbon.blankCanvas,[1,1,res]);
        %
        % %         dia.acq.ribbon.xPxInd=xPxInd;
        % %         dia.acq.ribbon.yPxInd=yPxInd;
        %         dia.acq.ribbon.FLIMworkingPixels=workingPixels;
        % %         dia.acq.ribbon.pixelsToLines=lineLabel;
        %         dia.acq.ribbon.FLIMworkingPixelLength=roundBinInd;
        % %         dia.acq.ribbon.xyPixels=xyPixels;
    end
end






