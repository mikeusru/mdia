function yphys_averageData
global yphys


yphys_loadAverage;

if ~isfield(yphys, 'aveData')
    yphys.aveData = yphys.data.data;
    yphys.aveString{1} = yphys.filename;
end

tmpData = yphys.data.data;
[pathstr, filenamestr, extstr]=fileparts(yphys.filename);

if iscell(yphys.aveString)
    if isempty(findstr(cell2mat(yphys.aveString),filenamestr))
        yphys.aveString{end+1} = yphys.filename;
        if length(yphys.aveData) > length(tmpData)
            yphys.aveData = yphys.aveData(1:length(tmpData), :);
        elseif length(yphys.aveData) < length(tmpData)
            tmpData = tmpData(1:length(yphys.aveData), :);
        end
        yphys.aveData(:, 2) = (tmpData(:, 2) + yphys.aveData(:, 2)*(length(yphys.aveString)-1))/length(yphys.aveString);
    else
        %beep;
        %disp('Already in average');
    end
else
    yphys.aveData = yphys.data.data;
    yphys.aveString = [];
    yphys.aveString{1} = yphys.filename;
end
if ishandle(yphys.figure.avePlot)
    %yphys.fwindow = 1;
    fave = imfilter(yphys.aveData(:,2), ones(yphys.fwindow, 1)/yphys.fwindow);
    set(yphys.figure.avePlot, 'XData', yphys.aveData(:,1), 'YData', fave, 'Color', 'red');
end
yphys_updateAverage;