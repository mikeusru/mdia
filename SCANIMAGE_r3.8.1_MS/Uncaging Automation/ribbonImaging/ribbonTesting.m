%ribbon testing and plotting
%%
figure;
plot(dia.acq.ribbon.xPxInd,dia.acq.ribbon.yPxInd);
axis equal
hold on
for i=1:length(dia.acq.ribbon.xPxInd)
    plot(dia.acq.ribbon.xPxInd(i),dia.acq.ribbon.yPxInd(i),'ro');
    drawnow;
    pause(.01);
end

%%
figure;
plot(dia.acq.ribbon.pixelsToLines);
hold on
plot(dia.acq.ribbon.yPxInd,'r');

%%
figure;
plot(dia.acq.ribbon.xPxInd,dia.acq.ribbon.pixelsToLines);
axis equal

%%
figure
plot(state.acq.mirrorDataOutput(:,1),state.acq.mirrorDataOutput(:,2))
axis equal
hold on
plot(x,y,'r','linewidth',2);
plot(xEx,yEx,'g','linewidth',2);
plot(scaledMirrorDataOutput(:,1),scaledMirrorDataOutput(:,2),'gx');
%%
stripeFinalData=dia.test.stripeFinalData;
%%
figure
plot(inSmall)
hold on
plot(inSmallShiftPos,'r');
%%
figure
plot(inSmall);
hold on
plot(inSmallShifted,'r');
%%
figure
plot(scaledMirrorDataOutput(:,1));
hold on
ind=1:length(scaledMirrorDataOutput);

plot(ind(scaledMirrorDataDiv>0),scaledMirrorDataOutput(scaledMirrorDataDiv>0,1),'ro')
%%
figure
plot(scaledMirrorDataOutput(:,1));
hold on
ind=1:length(scaledMirrorDataOutput);
% plot(ind(inSmall),scaledMirrorDataOutput(inSmall,1),'ro')
plot(ind(inSmallShiftPos),scaledMirrorDataOutput(inSmallShiftPos,1),'gx')
plot(ind(inSmallShiftNeg),scaledMirrorDataOutput(inSmallShiftNeg,1),'ro')
%%
figure
plot(scaledMirrorDataOutput(:,1));
hold on
ind=1:length(scaledMirrorDataOutput);
plot(ind(inSmallShifted),scaledMirrorDataOutput(inSmallShifted,1),'ro')
%%
figure
plot(dia.acq.ribbon.xPxInd,dia.acq.ribbon.pixelsToLines+min(dia.acq.ribbon.yPxInd),'ro');
axis equal
% plot(dia.acq.ribbon.pixelsToLines+min(dia.acq.ribbon.yPxInd))
%%
figure
% xyPixels=[,];
plot(dia.acq.ribbon.xPxInd',(dia.acq.ribbon.pixelsToLines+min(dia.acq.ribbon.yPxInd))','bx')
hold on
plot(dia.acq.ribbon.xyPixels(:,1),dia.acq.ribbon.xyPixels(:,2),'ro')
axis equal
%%
figure
imagesc(BW);
hold on
plot(dia.acq.ribbon.xyPixels(:,1),dia.acq.ribbon.xyPixels(:,2),'go');