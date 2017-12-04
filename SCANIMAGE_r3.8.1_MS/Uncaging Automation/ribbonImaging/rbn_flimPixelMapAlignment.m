function rbn_flimPixelMapAlignment( shiftConstant )
%rbn_flimPixelMapAlignment( shiftConstant ) checks different shift
%constants to get the right FLIM image recreation
global dia state
spc_imageShift=round(-state.acq.scanDelay*state.acq.outputRate +shiftConstant );
inFull=dia.acq.ribbon.inFull;
inSmall=dia.acq.ribbon.inSmall;
sizeImage=size(dia.acq.ribbon.blankCanvas)+.5;
scaledMirrorDataOutput=dia.acq.ribbon.mirrorDataOutput;
res = 2^state.spc.acq.SPCdata.adc_resolution;


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
        FLIMpixelIndex=sub2ind([floor(sizeImage),res],flimDim1,flimDim2,flimDim3);
%         dia.acq.ribbon.FLIMblankCanvas=repmat(dia.acq.ribbon.blankCanvas,[1,1,res]);
        %         dia.acq.ribbon.xPxInd=xPxInd;
        %         dia.acq.ribbon.yPxInd=yPxInd;
        workingPixelsFLIM = double(circshift(pixelRef(:),round(spc_imageShift*length(pixelRef)/length(inSmall))));
%         workingPixelsFLIM = double(circshift(pixelRef,round(spc_imageShift)));

%         workingPixelsFLIM = logical(round(interp1(1:length(workingPixelsFLIM),workingPixelsFLIM,linspace(1,length(workingPixelsFLIM),flimscan_size_x))));
%         workingPixelsFLIM = double(pixelRef);
        workingPixelsFLIM = repmat(workingPixelsFLIM',res,1);
        workingPixelsFLIM = logical(workingPixelsFLIM(:));
%         dia.acq.ribbon.FLIMworkingPixels = workingPixelsFLIM;
        %         dia.acq.ribbon.pixelsToLines=lineLabel;
%         dia.acq.ribbon.FLIMworkingPixelLength=length(find(workingPixelsFLIM));
% % 
% spc_imageShift=round(-state.acq.scanDelay*state.acq.outputRate +shiftConstant );
% inFull=dia.acq.ribbon.inFull;
% inSmall=dia.acq.ribbon.inSmall;
% sizeImage=size(dia.acq.ribbon.blankCanvas)+.5;
% 
% binSize=state.acq.binFactor;
% res = 2^state.spc.acq.SPCdata.adc_resolution;
% pixelRef=double(circshift(dia.acq.ribbon.inSmall,spc_imageShift));
% scanToCollectRatio=state.init.hAI.sampClkRate/state.acq.outputRate*res/binSize;
% M=mod(scanToCollectRatio,1);
% 
% workingPixels = repmatWithRemainder( pixelRef , scanToCollectRatio, M);
% %close tails to avoid errors
% workingPixels(1)=0;
% workingPixels(end)=0;
% roundBinInd=floor(length(find(workingPixels))/binSize)*binSize;
% roundBinInd=floor(roundBinInd/(res))*res;
% workingPixels=logical(workingPixels);
% 
% lineLabel=1:state.acq.linesPerFrame;
% lineLabel=repmat(lineLabel,state.internal.lengthOfXData,1); %divided by two because bidirectional
% lineLabel=lineLabel(:);
% lineLabel=lineLabel(inFull);
% lineLabel = repmatWithRemainder( lineLabel , scanToCollectRatio, M);
% %     lineLabel=repmat(lineLabel',scanToCollectRatio,1);
% %     lineLabel=lineLabel(:);
% lineLabel=lineLabel(workingPixels);
% lineLabel=lineLabel(1:roundBinInd);
% lineLabel=max(reshape(lineLabel,res,[]),[],1);
% % pixelsToLines gives the Y reference, also need X reference. then can do
% pixelMirrorRefBeforeShift=double(inSmall);
% pixelMirrorRef2 = repmatWithRemainder( pixelMirrorRefBeforeShift , scanToCollectRatio, M);
% %     pixelMirrorRef2=repmat(pixelMirrorRefBeforeShift',scanToCollectRatio,1); %note - this value may not always be 50... check just in case.
% %     pixelMirrorRef2=pixelMirrorRef2(:);
% pixelMirrorRef2(1)=0;
% pixelMirrorRef2(end)=0;
% pixelMirrorRef2=logical(pixelMirrorRef2);
% 
% fastMirror=dia.acq.ribbon.mirrorDataOutput(:,1);
% % slowMirror=scaledMirrorDataOutput(:,2);
% fastMirror = repmatWithRemainder( fastMirror , scanToCollectRatio, M);
% % slowMirror = repmatWithRemainder( slowMirror , scanToCollectRatio, M);
% %     fastMirror=repmat(fastMirror',scanToCollectRatio,1);
% %     slowMirror=repmat(slowMirror',scanToCollectRatio,1);
% %     fastMirror=fastMirror(:);
% %     slowMirror=slowMirror(:);
% % disp(length(fastMirror)); %this was necessary to prevent a bug...
% % disp(length(pixelRef2));
% fastMirror=fastMirror(pixelMirrorRef2);
% % slowMirror=slowMirror(pixelMirrorRef2);
% fastMirror=fastMirror(1:roundBinInd);
% % slowMirror=slowMirror(1:roundBinInd);
% fastMirror=median(reshape(fastMirror,res,[]),1);
% % slowMirror=median(reshape(slowMirror,res,[]),1);
% xPxInd = sizeImage(2)*(fastMirror/state.init.voltsPerOpticalDegree-state.acq.scanShiftFast)/((state.init.scanAngularRangeReferenceFast * state.acq.scanAngleMultiplierFast)/state.acq.zoomFactor) + sizeImage(2)/2;
% % yPxInd = sizeImage(1)*(slowMirror/state.init.voltsPerOpticalDegree-state.acq.scanShiftSlow)/((state.init.scanAngularRangeReferenceSlow * state.acq.scanAngleMultiplierSlow)/state.acq.zoomFactor) + sizeImage(1)/2;
% xPxInd=round(xPxInd);
% % yPxInd=round(yPxInd);
% 
% xyPixels=[xPxInd',(lineLabel)'];
% for i=1:max(xyPixels(:,2))
%     ind=xyPixels(:,2)==i;
%     xPixelValues=xyPixels(ind,1);
%     if numel(xPixelValues)>1
%         pixelJump=find(abs(diff(xPixelValues))>2); %in case there are breaks in the line
%         p = polyfit(1:length(xPixelValues),xPixelValues',1);
%         if isempty(pixelJump)
%             newXPixelValues=round(mean(xPixelValues)-length(xPixelValues)/2) : round(mean(xPixelValues)-length(xPixelValues)/2) + length(xPixelValues) -1;
%             if p(1)<0
%                 newXPixelValues = fliplr(newXPixelValues);
%             end
%         else
%             xPixelSegment=xPixelValues(1:pixelJump(1));
%             newXsegment=round(mean(xPixelSegment)-length(xPixelSegment)/2) : round(mean(xPixelSegment)-length(xPixelSegment)/2) + length(xPixelSegment) -1;
%             if p(1)<0
%                 newXsegment = fliplr(newXsegment);
%             end
%             newXPixelValues=newXsegment;
%             for j=1:length(pixelJump)
%                 if j==length(pixelJump)
%                     maxInd=length(xPixelValues);
%                 else
%                     maxInd=pixelJump(j+1);
%                 end
%                 xPixelSegment=xPixelValues(pixelJump(j)+1 : maxInd);
%                 newXsegment=round(mean(xPixelSegment)-length(xPixelSegment)/2) : round(mean(xPixelSegment)-length(xPixelSegment)/2) + length(xPixelSegment) -1;
%                 if p(1)<0
%                     newXsegment = fliplr(newXsegment);
%                 end
%                 newXPixelValues=[newXPixelValues,newXsegment];
%             end
%         end
%         xyPixels(ind,1)=newXPixelValues;
%     end
% end
% 
% %correct for pixels out of bounds
% xyPixels(xyPixels(:,1)>floor(sizeImage(1)),1)=floor(sizeImage(1));
% xyPixels(xyPixels(:,1)<1)=1;
% xyPixels(xyPixels(:,2)>floor(sizeImage(2)),2)=floor(sizeImage(2));
% xyPixels(xyPixels(:,2)<1)=1;
% 
%  flimDim1=repmat(xyPixels(:,2)',[res,1]);
%         flimDim1=flimDim1(:);
%         flimDim2=repmat(xyPixels(:,1)',[res,1]);
%         flimDim2=flimDim2(:);
%         flimDim3=(1:res)';
%         flimDim3=repmat(flimDim3,[length(xyPixels),1]);
% FLIMpixelIndex=sub2ind([floor(sizeImage),res],flimDim1,flimDim2,flimDim3);
% 
image1 = dia.acq.ribbon.originalFLIMimage;
image1=image1(workingPixelsFLIM(:));
% image1=image1(1:roundBinInd);
temp1=dia.acq.ribbon.FLIMblankCanvas;
temp1(FLIMpixelIndex)=image1;
temp1=sum(temp1,3);

try
    if ~ishandle(dia.acq.rbn.FLIMalignFig)
        dia.acq.rbn.FLIMalignFig = figure('Name','FLIM Ribbon Pixel Preview');
        dia.acq.rbn.FLIMalignAx = axes('parent',dia.acq.rbn.FLIMalignFig);
    end
catch
    dia.acq.rbn.FLIMalignFig = figure('Name','FLIM Ribbon Pixel Preview');
    dia.acq.rbn.FLIMalignAx = axes('parent',dia.acq.rbn.FLIMalignFig);
end
figure(dia.acq.rbn.FLIMalignFig);
imagesc(temp1,'Parent',dia.acq.rbn.FLIMalignAx);
axis(dia.acq.rbn.FLIMalignAx,'image','off');
% 
dia.acq.ribbon.FLIMShiftConstant=shiftConstant;
% 
% 
% 
%     function b = repmatWithRemainder( a , scanRatio, remainder)
%         if remainder~=0
%             b=repmat(a',floor(scanRatio),1);
%             ending=a(1:floor(length(a*remainder)));
%             b=[b(:);ending(:)];
%         else
%             b=repmat(a',scanRatio,1);
%             b=b(:);
%         end
%     end
% 
% end

