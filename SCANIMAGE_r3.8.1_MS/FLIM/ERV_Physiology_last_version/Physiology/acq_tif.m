function acq_tif(varargin)

%Function to analize tif files from line scans
%
%
%Emiliano Rial Verde
%May 2006
%Updated for better performance with Matlab 2006a
%November 2006

if nargin>0
    pathname=textread([matlabroot, '\work\Physiology\tif_directory_name.erv'], '%s', 'whitespace', '');
    pathname=[pathname{:}, '\'];
    directory_name=evalin('base', 'userdata.filename');
    directory_name=[pathname, directory_name(1:end-4)]; 
end
if nargin==0
    %Recovers the last folder used, selects new folder, and updates the folder file
    pathname=textread([matlabroot, '\work\Physiology\tif_directory_name.erv'], '%s', 'whitespace', '');
    pathname=[pathname{:}, '\'];
    directory_name=uigetdir(pathname,'Select folder containing .tif files to average');
    a=fopen([matlabroot, '\work\Physiology\tif_directory_name.erv'], 'w+');
    fprintf(a, '%s', pathname(1:end-1));
    fclose(a);

    %Selects files to open
    d = dir([directory_name, '\*.tif']);
    str = {d.name};
    [s,v] = listdlg('PromptString','Select files to average', 'ListString', str);

    if isempty(s)
        data=[];
    else
        a=str(s);
        if length(a{1})>7
            datasize=size(imread([directory_name, '\', a{1}]));
            data=zeros(datasize(1), datasize(2), length(a));
            for i=1:length(a)
                [x,map] = imread([directory_name, '\', a{i}]);
                data(:,:,i)=double(x);
            end
        else
            filenumbers=[];
            for i=1:length(a)
                if isempty(str2double(a{i}(1:3)))
                    b=str2double(a{i}(1:2));
                else
                    b=str2double(a{i}(1:3));
                end
                filenumbers=[filenumbers; b];
            end
            filenumbers=sort(filenumbers);
            datasize=size(imread([directory_name, '\', a{1}]));
            data=zeros(datasize(1), datasize(2), length(filenumbers));
            for i=1:length(filenumbers)
                [x,map] = imread([directory_name, '\', num2str(filenumbers(i)), '.tif']);
                data(:,:,i)=double(x);
            end
        end
    end
elseif nargin==1
    data=varargin{1};
    map=colormap('gray');
elseif nargin==2
    data=varargin{1};
    map=varargin{2};
end

if isempty(data)
else
    datamean=mean(data,3);

    tifUserData.directory_name=directory_name;
    tifUserData.data=data;
    tifUserData.datamean=datamean;
    tifUserData.map=map;
    tifUserData.bkg=[];
    tifUserData.datamiusbkg=[];
    tifUserData.datameanmiusbkg=[];
    tifUserData.pixelsumroi=[];
    tifUserData.pixelsumroimean=[];
    tifUserData.locationroi=[];
    tifUserData.deltafoverf=[];
    tifUserData.deltafoverfmean=[];
    tifUserData.selected=[];
    tifUserData.timescale=[];

    h0 = figure(...
        'Units','normalized',...
        'Name','ERV .tif observer',...
        'NumberTitle','off',...
        'Position',[0.24 0.54 0.75 0.36], ...
        'Tag', 'tifwindow', ...
        'UserData', tifUserData);
    uicontrol(h0, ...
        'String', 'Substract BKG', ...
        'Units','normalized',...
        'Position',[0.01 0.925 0.09 0.07], ...
        'Callback', @SubstractBackground);
    uicontrol(h0, ...
        'String', 'Select ROI', ...
        'Units','normalized',...
        'Position',[0.11 0.925 0.09 0.07], ...
        'Callback', @SelectROI);
    uicontrol(h0, ...
        'String', 'Select Base', ...
        'Units','normalized',...
        'Position',[0.21 0.925 0.09 0.07], ...
        'Callback', @SelectBaseline);
    uicontrol(h0, ...
        'String', 'Select Line Scans', ...
        'Units','normalized',...
        'Position',[0.31 0.925 0.09 0.07], ...
        'Callback', @RemoveLineScans, ...
        'Tag', 'removefailuresbutton');
    uicontrol(h0, ...
        'String', 'Get Data', ...
        'Units','normalized',...
        'ToolTipString', 'Gets data out of the UserData property and puts it on the workspace', ...
        'Position',[0.41 0.925 0.09 0.07], ...
        'Callback', 'tifUserData=get(findobj(''Tag'', ''tifwindow''), ''UserData'');');
    uicontrol(h0, ...
        'String', 'Synchronize Physiology', ...
        'Units','normalized',...
        'Position',[0.51 0.925 0.09 0.07], ...
        'Callback', @Physiology);
    h1 = uicontrol(h0, ...
        'Style', 'text', ...
        'String', 'Time per line (in ms):', ...
        'Units','normalized',...
        'Position',[0.61 0.925 0.09 0.05]);
    a=get(gcf, 'Color');
    set(h1, 'BackgroundColor', a);
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', '2', ...
        'Units','normalized',...
        'Position',[0.7 0.925 0.02 0.07], ...
        'Tag', 'timeperline');
    uicontrol(h0, ...
        'Style', 'popup', ...
        'String', 'gray|hot|winter|bone|cool|jet|spring|summer', ...
        'Value', 2, ...
        'Callback', @ColorChange, ...
        'ToolTipString', 'Colormap selector', ...
        'Units','normalized',...
        'Position',[0.75 0.92 0.05 0.07], ...
        'Tag', 'colormappopup');
    imshow(datamean, map);
    colormap('hot');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SubstractBackground(obj, event)
%Background is calculated and subtracted from each line and in each image independently

userdata=get(findobj('Tag', 'tifwindow'), 'UserData');
band=ginput(2);
band=round(band(:,1));
userdata.bkg=mean(userdata.data(:, band(1):band(2), :), 2);
userdata.bkg=repmat(userdata.bkg, [1 size(userdata.data, 2) 1]);
userdata.datamiusbkg=userdata.data-userdata.bkg;
userdata.datameanmiusbkg=mean(userdata.datamiusbkg, 3);
imshow(userdata.datameanmiusbkg, userdata.map);
ColorChange;
set(findobj('Tag', 'tifwindow'), 'UserData', userdata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SelectROI(obj, event)

close(findobj('Tag', 'pixelsumwindow'))
userdata=get(findobj('Tag', 'tifwindow'), 'UserData');
if isempty(userdata.datamiusbkg)
    button=questdlg('Background NOT subtracted','WARNING!!!','Continue','Cancel','Continue');
    if strcmp(button, 'Cancel')
        return
    end
    userdata.locationroi=ginput(2);
    userdata.locationroi=round(userdata.locationroi(:,1));
    userdata.pixelsumroi=sum(userdata.data(:, userdata.locationroi(1):userdata.locationroi(2), :), 2);
    userdata.pixelsumroimean=mean(userdata.pixelsumroi,3);
else
    userdata.locationroi=ginput(2);
    userdata.locationroi=round(userdata.locationroi(:,1));
    userdata.pixelsumroi=sum(userdata.datamiusbkg(:, userdata.locationroi(1):userdata.locationroi(2), :), 2);
    userdata.pixelsumroimean=mean(userdata.pixelsumroi,3);
end
set(findobj('Tag', 'tifwindow'), 'UserData', userdata);

figure(...
    'Units','normalized',...
    'Name','ERV .tif observer',...
    'NumberTitle','off',...
    'Position',[0.004 0.54 0.23 0.36], ...
    'Tag', 'pixelsumwindow');
plot(userdata.pixelsumroimean);
title('Pixel sum vs. line number');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SelectBaseline(obj, event)

close(findobj('Tag', 'deltafoverfwindow'))
userdata=get(findobj('Tag', 'tifwindow'), 'UserData');
band=userdata.locationroi;
if isempty(userdata.datamiusbkg)
    x=userdata.data;
else
    x=userdata.datamiusbkg;
end
a=get(findobj('Tag', 'timeperline'), 'String');
baseline=inputdlg({'Baseline duration in ms.'; 'Line duration in ms.'}, ...
    'Baseline', 1, {'100'; a});
duration=str2double(baseline{1});
interval=str2double(baseline{2});
baseline=floor(duration/interval)-1;
timeline=interval:interval:size(x,1)*interval;
userdata.deltafoverf=sum(x(:,band(1):band(2),:), 2);
baseline=mean(userdata.deltafoverf(1:baseline,:,:),1);
baseline=repmat(baseline, [size(userdata.deltafoverf,1) 1 1]);
userdata.deltafoverf=(userdata.deltafoverf-baseline)./baseline;
userdata.deltafoverfmean=mean(userdata.deltafoverf,3);
set(findobj('Tag', 'tifwindow'), 'UserData', userdata);
figure(...
    'Units','normalized',...
    'Name','ERV .tif observer',...
    'NumberTitle','off',...
    'Position',[0.004 0.075 0.23 0.36], ...
    'Tag', 'deltafoverfwindow');
plot(timeline, userdata.deltafoverfmean);
title('\DeltaF/F vs. time in ms');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RemoveLineScans(obj, event)

userdata=get(findobj('Tag', 'tifwindow'), 'UserData');
figure(...
    'Units','normalized',...
    'Name','Line Scan Selector: Press S to select, N to see next Line Scan, or P for the previous one; press the SpaceBar to cancel, or any Mouse Button to end selection',...
    'NumberTitle','off',...
    'Position',[0.24 0.1 0.75 0.36], ...
    'Color', 'k', ...
    'Tag', 'tifselectionwindow');
i=1;
userdata.selected=[];
ili=str2double(get(findobj('Tag', 'timeperline'), 'String'));
while i<=size(userdata.data,3)
    imshow(userdata.data(:,:,i), userdata.map);
    set(gca, 'Visible', 'on', 'YColor', 'w', 'YGrid', 'on', 'TickDir', 'out', 'YTickLabel', num2str(str2num(get(gca, 'YTickLabel'))*ili)); %Use str2num and NOT str2double
    ylabel('Time in ms');
    ColorChange;
    title(['TIF file ', num2str(i), 'out of ', num2str(size(userdata.data,3)), '.'], 'Color', 'w');
    w=waitforbuttonpress;
    if w==0
        close(findobj('Tag', 'tifselectionwindow'))
        break
    elseif w==1
        if strcmp(get(gcf, 'CurrentCharacter'), 's')
            if isempty(find(userdata.selected==i))
                userdata.selected=[userdata.selected i];
            end
            i=i+1;
            if i>size(userdata.data,3)
                close(findobj('Tag', 'tifselectionwindow'))
            end
        elseif strcmp(get(gcf, 'CurrentCharacter'), 'n')
            i=i+1;
            if i>size(userdata.data,3)
                close(findobj('Tag', 'tifselectionwindow'))
            end
        elseif strcmp(get(gcf, 'CurrentCharacter'), 'p')
            if i==1
            else
                i=i-1;
            end
        elseif strcmp(get(gcf, 'CurrentCharacter'), ' ')
            userdata.selected=[];
            close(findobj('Tag', 'tifselectionwindow'))
            break
        end
    end
end
if isempty(userdata.selected)
else
    userdata.datamean=mean(userdata.data(:,:,userdata.selected),3);
    figure(findobj('Tag', 'tifwindow'));
    imshow(userdata.datamean, userdata.map);
    ColorChange;
end
set(findobj('Tag', 'tifwindow'), 'UserData', userdata);
assignin('base', 'tifUserData', userdata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ColorChange(obj, event)
str=get(findobj('Tag', 'colormappopup'), 'String');
str=strrep(str(get(findobj('Tag', 'colormappopup'), 'Value'),:), ' ', '');
colormap(str);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Physiology(obj, event)

imaging=get(findobj('Tag', 'tifwindow'), 'UserData');
physiology=evalin('base', 'userdata');
if length(physiology.selectedindex)==1
    index=physiology.selectedindex;
else
    index=physiology.selectedindex(imaging.selected);
end
data=physiology.datamat(:,index);
a=str2double(get(findobj('Tag', 'timeperline'), 'String'));
imaging.timescale=a:a:size(imaging.data, 1)*a;
set(findobj('Tag', 'tifwindow'), 'UserData', imaging);
assignin('base', 'tifUserData', imaging);

b=mean(data,2);
figure
[AX,H1,H2]=plotyy(physiology.timescale, b, imaging.timescale, imaging.deltafoverf);
title(['Cell: ', physiology.filename(1:end-6), '-', physiology.filename(end-4), '. Number of traces: ', num2str(length(index)), '.']);
a=min([max(physiology.timescale) max(imaging.timescale)]);
set(AX(1), 'XLim', [0 a], 'YLim', [-Inf max(b)+1], 'Box', 'off', 'YTick', (-100:0.5:40)', 'YTickLabel', (-100:0.5:40)');
set(AX(2), 'XLim', [0 a], 'YLim', [-2 Inf], 'YMinorTick', 'on');
set(get(AX(1),'Ylabel'), 'String', physiology.recordingmode);
set(get(AX(2), 'Ylabel'), 'String', '\DeltaF/F');
set(get(AX(1),'Xlabel'), 'String', 'Time in ms.');