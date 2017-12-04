function yphys_dispEphys
global yphys
global gh
global state

    filestr = yphys.filename;
    [pathstr,filenamestr,extstr] = fileparts(filestr);
    if isfield(yphys, 'aveString')
        if iscell(yphys.aveString)
			if isempty(findstr(cell2mat(yphys.aveString),filenamestr))
                plotColor = 'green';
			else
                 plotColor = 'red';
			end
        else
            plotColor = 'green';
        end
    else
        plotColor ='green';
    end
    
    if isempty(findobj('tag', 'yphys_plot'))
        yphys.figure.fhandle = figure('tag', 'yphys_plot', 'name', 'yphys plot');
        yphys.figure.plot = plot(yphys.data.data(:, 1), yphys.data.data(:, 2));
        hold on;
        yphys.figure.avePlot = plot(yphys.data.data(:, 1), yphys.data.data(:, 2), 'color', plotColor);
        hold off;
    end
                    
    try
			set(yphys.figure.plot, 'XData', yphys.data.data(:,1), 'YData', yphys.data.data(:,2));
            if isfield(yphys, 'aveString')
                if length(yphys.aveString)
                    set(yphys.figure.avePlot, 'XData', yphys.aveData(:,1), 'YData', yphys.aveData(:,2), 'color', plotColor);
                else
                    set(yphys.figure.avePlot, 'XData', yphys.data.data(:,1), 'YData', yphys.data.data(:,2), 'color', plotColor);
                end
            else
                set(yphys.figure.avePlot, 'XData', yphys.data.data(:,1), 'YData', yphys.data.data(:,2), 'color', plotColor);
            end
	
    catch ME
        disp('Error in yphys_getData'); 
        fprintf(2,'ERROR in callback function (%s): \t%s\n',mfilename,ME.message);
	end

    
%  figure(yphys.figure.fhandle);
% obj1 = findobj('Tag', 'EphysButton');
% 
% if isempty(obj1)
% 	gh.yphys.figure.EphysPreButton = uicontrol('Style','pushbutton','Units','normalized', 'Position',[.0 .07 .05 .05], 'String','<', 'Tag',...
%         'EphysButton', 'CallBack', 'yphys_moveToEphys(1)');
% 	gh.yphys.figure.EphysPostButton = uicontrol('Style','pushbutton','Units','normalized', 'Position',[.05 .07 .05 .05], 'String', '>',...
%         'Tag', 'EphysButton', 'CallBack', 'yphys_moveToEphys(2)');
% end
% 
% try
%     delete(gh.yphys.figure.currentEphysText);
%     delete(gh.yphys.figure.averageInEphys, gh.yphys.figure.epochEphysPulse);
% end

% [pathstr,filenamestr,extstr] = fileparts(yphys.filename);
% numA = str2num(filenamestr(end-2: end));
% 
% for i=1:length(yphys.aveString);
%      if isempty(yphys.aveString{i})
%          numB(i) = 1;
%      else
%          numB(i) = str2num(yphys.aveString{i}(end-6:end-4));
%      end
% end
% if isempty(yphys.aveString)
%     numB = 1;
% end
% 
% gh.yphys.figure.currentEphysText = uicontrol('style', 'edit', 'Units','normalized', 'Position',[.025 .005 .05 .05], 'String', ...
%     num2str(numA), 'CallBack', 'yphys_moveToEphys(3)');
% gh.yphys.figure.averageInEphys = uicontrol('style', 'edit', 'Units','normalized', 'Position',[.225 .005 .45 0.05], 'String', num2str(numB), ...
%     'CallBack', 'yphys_moveToEphys(4)');
% gh.yphys.figure.epochEphysPulse = uicontrol('style', 'text', 'Units','normalized', 'Position',[.1 .005 .1 0.05], 'String', ['e', num2str(state.yphys.acq.epochN), 'p', num2str(state.yphys.acq.pulseN), '_int']);