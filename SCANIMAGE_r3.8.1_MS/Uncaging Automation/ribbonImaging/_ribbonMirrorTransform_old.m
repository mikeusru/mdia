function scaledMirrorDataOutput = ribbonMirrorTransform(scaledMirrorDataOutput)
%scaledMirrorDataOutput = ribbonMirrorTransform(scaledMirrorDataOutput)
%changes the mirror data settings to use ribbon scanning
global state dia

dia.acq.ribbonScale=2;

% fillFrac=state.acq.fillFraction;
% state.acq.pixelsPerLine=128;
fastOffset=zeros(length(state.acq.mirrorDataOutput),1);
%assume for now that entire time is imaged. need to correct this later.
x=dia.acq.ribbonx;
y=dia.acq.ribbony;
[y,ind]=sort(y,'ascend');
x=x(ind);
% slowRange=max(scaledMirrorDataOutput(:,2))-min(scaledMirrorDataOutput(:,2));
fastRange=max(scaledMirrorDataOutput(:,1))-min(scaledMirrorDataOutput(:,1));
slowRange=max(scaledMirrorDataOutput(:,2))-min(scaledMirrorDataOutput(:,2));

pixelVoltRatioFast=fastRange/dia.acq.ribbonPixelsPerLine; %maybe consider fillFrac here
pixelVoltRatioSlow=slowRange/dia.acq.ribbonLinesPerFrame; %maybe consider fillFrac here

fastMiddle=max(scaledMirrorDataOutput(:,1))-fastRange/2;
slowMiddle=max(scaledMirrorDataOutput(:,2))-slowRange/2;

xVolts=(x-dia.acq.ribbonPixelsPerLine/2)*pixelVoltRatioFast;
xVoltsOffset=xVolts-fastMiddle; %sign on this may need to be different
t=round(y*length(state.acq.mirrorDataOutput)/dia.acq.ribbonLinesPerFrame);
for i=1 : (length(t)-1)
    tRange=t(i):t(i+1);
    ofsRange=linspace(xVoltsOffset(i),xVoltsOffset(i+1),length(tRange));
    fastOffset(tRange)=ofsRange;
end

yVolts=(y-dia.acq.ribbonLinesPerFrame/2)*pixelVoltRatioSlow;
yVoltsOffset=yVolts-slowMiddle; %sign on this may need to be different

t=round(y*length(state.acq.mirrorDataOutput)/dia.acq.ribbonLinesPerFrame);
for i=1 : (length(t)-1)
    tRange=t(i):t(i+1);
    ofsRange=linspace(xVoltsOffset(i),xVoltsOffset(i+1),length(tRange));
    fastOffset(tRange)=ofsRange;
end



scaledMirrorDataOutput(:,1)=scaledMirrorDataOutput(:,1)+fastOffset;
scaledMirrorDataOutput(:,1)=scaledMirrorDataOutput(:,1)/dia.acq.ribbonScale;

linesPerStripe=state.acq.linesPerFrame/state.internal.numberOfStripes;
stripeShapes=cell(state.internal.numberOfStripes,length(state.acq.acquiringChannel));
for i=1:length(stripeShapes)
    for j=1:length(state.acq.acquiringChannel)
        if state.acq.acquiringChannel(i)
            counter=1;
            for k=1:linesPerStripe
                stripeShapes{j,i}(k,:)=[zeros(1,32), ones(1,64), zeros(1,32)];
                counter=counter+64;
            end
            stripeShapes{j,i}(stripeShapes{j,i}==1)=1:2048;
        end
    end
end
dia.acq.ribbonStripeShapes=stripeShapes;
%make ribbon figure;
checkOrMakeRibbonFigures;



function checkOrMakeRibbonFigures
global dia state
if ~isfield(dia.handles,'ribbonAcqFigure') || ~ishandle(dia.handles.ribbonAcqFigure(1)) || strcmp(get(dia.handles.ribbonAcqFigure(1),'visible'),'off')
    figurePosition=ones(state.init.maximumNumberOfInputChannels,4); %initialize the array...
    axisPosition = [0 0 1 1];
    startImageData = zeros(state.internal.storedLinesPerFrame, state.acq.pixelsPerLine*dia.acq.ribbonScale); %VI102209A
    startImageData = uint8(startImageData);
    
    for i=1:length(state.acq.acquiringChannel)
        if state.acq.acquiringChannel(i)
            figurePosition(i,:)=get(state.internal.GraphFigure(i),'position');
            
            dia.handles.ribbonAcqFigure(i)=figure('Position', figurePosition(i,:) ,'doublebuffer', 'on', ...
                'Tag',  ['ribbonAcq' num2str(i)], 'Name',  ['Ribbon Acquisition of Channel ' num2str(i)], 'NumberTitle', 'off',  'MenuBar', 'none', ...
                'CloseRequestFcn', 'set(gcf, ''visible'', ''off'')','ColorMap', gray(256));
            
            dia.handles.ribbonAcqAxis(i) = axes('YDir', 'Reverse','NextPlot', 'add', 'XLim', [-0.5 .5] + [1 state.acq.pixelsPerLine*dia.acq.ribbonScale],'YLim', [-0.5 .5] + [1 state.internal.storedLinesPerFrame], ...
                'CLim', get(state.internal.axis(i),'CLim'), 'Parent', dia.handles.ribbonAcqFigure(i), ...
                'YTickLabelMode', 'manual', 'XTickLabelMode', 'manual', ...
                'XTickLabel', [], 'YTickLabel', [], 'DataAspectRatioMode', 'manual','position',axisPosition);
            
            dia.handles.ribbonImage(i) = image('CData', startImageData, 'CDataMapping', 'Scaled', 'Parent', dia.handles.ribbonAcqAxis(i), ...
                'EraseMode','none');
            
            
        end
    end
end

