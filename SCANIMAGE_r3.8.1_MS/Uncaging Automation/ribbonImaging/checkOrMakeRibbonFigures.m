
function checkOrMakeRibbonFigures
global dia state
if ~isfield(dia.handles,'ribbonAcqFigure') || ~ishandle(dia.handles.ribbonAcqFigure(1)) || strcmp(get(dia.handles.ribbonAcqFigure(1),'visible'),'off')
    figurePosition=ones(state.init.maximumNumberOfInputChannels,4); %initialize the array...
    axisPosition = [0 0 1 1];
    startImageData = dia.acq.ribbon.blankCanvas;
    startImageData = uint8(startImageData);
    
    for i=1:length(state.acq.acquiringChannel)
        if state.acq.acquiringChannel(i)
            figurePosition(i,:)=get(state.internal.GraphFigure(i),'position');
            
            dia.handles.ribbonAcqFigure(i)=figure('Position', figurePosition(i,:) ,'doublebuffer', 'on', ...
                'Tag',  ['ribbonAcq' num2str(i)], 'Name',  ['Ribbon Acquisition of Channel ' num2str(i)], 'NumberTitle', 'off',  'MenuBar', 'none', ...
                'CloseRequestFcn', 'set(gcf, ''visible'', ''off'')','ColorMap', gray(256));
            
            dia.handles.ribbonAcqAxis(i) = axes('YDir', 'Reverse','NextPlot', 'add', 'XLim', [-0.5 .5] + [1 state.acq.pixelsPerLine],'YLim', [-0.5 .5] + [1 state.internal.storedLinesPerFrame], ...
                'CLim', get(state.internal.axis(i),'CLim'), 'Parent', dia.handles.ribbonAcqFigure(i), ...
                'YTickLabelMode', 'manual', 'XTickLabelMode', 'manual', ...
                'XTickLabel', [], 'YTickLabel', [], 'DataAspectRatioMode', 'manual','position',axisPosition);
            
            dia.handles.ribbonImage(i) = image('CData', startImageData, 'CDataMapping', 'Scaled', 'Parent', dia.handles.ribbonAcqAxis(i), ...
                'EraseMode','none');
            
            
        end
    end
end

