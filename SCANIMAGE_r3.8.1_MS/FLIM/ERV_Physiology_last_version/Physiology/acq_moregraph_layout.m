%Physiology scope software
%Emiliano Rial Verde
%December 2005
%Updated for better performance in Matlab 2006a. November 2006
%
%Non-amplifier graphs layout script
if recchannelnum>ampchannelnum
    a=chin.HwChannel;
    for i=1:length(chin)-ampchannelnum;
        
        close(findobj('Tag', ['channelwindow', num2str(i+ampchannelnum)]));
        
        h0 = figure(...
            'Units','normalized',...
            'MenuBar','none',...
            'Name',['Channel: ', num2str(a{i+ampchannelnum}), '. ERV Physiology Recorder. V 2.0'],...
            'NumberTitle','off',...
            'doublebuffer', 'on', ...
            'Tag',['channelwindow', num2str(i+ampchannelnum)]);
        if i==1 || i==4 || i==7 || i==10
            set(h0, 'Position',[0.62    0.05    0.37    0.3]);
        elseif i==2 || i==5 || i==8 || i==11
            set(h0, 'Position',[0.62    0.36    0.37    0.3]);
        elseif i==3 || i==6 || i==9 || i==12
            set(h0, 'Position',[0.62    0.67    0.37    0.3]);
        end
        axes('XLim', defaulttimescalerange, ...
            'NextPlot', 'replacechildren');
        title(['Channel: ', num2str(a{i+ampchannelnum})]);
        xlabel('Time in ms')
        ylabels{i+ampchannelnum}=ylabel('Raw signal in Volts ');
        p{i+ampchannelnum}=plot(timescale, zeros(samplespertrigger,1));
        set(gca, 'XLim', defaulttimescalerange, ...
            'YTickMode', 'auto', ...
            'YTickLabelMode', 'auto', ...
            'YMinorTick', 'on', ...
            'NextPlot', 'replacechildren', ...
            'YColor', 'k');
        scopeaxes{i+ampchannelnum}=gca;
        set(p{i+ampchannelnum}, 'LineStyle', '-', 'Color', 'b');
    end
end