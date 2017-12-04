function acq_reader(varargin)

%Physiology and Imaging analysis software
%Emiliano Rial Verde
%October-November-December 2005
%Last modified 12/07/2006
%
%Binary file reader and analyzer. Dat, tif, and imgdat file
%synchronization.
%
%Use file path to open a particular file
%Example: acq_reader('D:\Electrophysiology\030207_1.dat');
%
%Use 'batch' option to select and open several files at once
%Example: acq_reader('batch');
%
%Use 'no file' option to open the GUI window without data
%Example: acq_reader('no file');
%
%.dat file header:
%Year
%Month
%Day
%Number of channels acquired
%Acquisition rate in samples per second
%Sweep length in samples
%Inter-sweep interval
%Number of sweeps
%Header size
%Tail size
%
%Sweep tail (after each sweep of acquired data):
%Mode (0 is V-clamp, 1 is I-clamp)
%Gainscalefactor used
%Acquisition order
%Rs in megaOhms
%Ri in megaOhms
%Cm in picoFaradays


%Close previously opened windows
close(findobj('Tag', 'pixelsumwindow'));
close(findobj('Tag', 'deltafoverfwindow'));
close(findobj('Tag','tifwindow'));
close(findobj('Tag','readwindow'));
close(findobj('Tag', 'apwindow'));
close(findobj('Tag', 'apbasewindow'));

%Default baseline choices
basewindowstartdefault=1; %in ms
basewindowdurationdefault=18; %in ms


%Opens the file and reads the data using the openfile Subfunction
if nargin==1
    if strcmp(varargin{1}, 'no file')
        userdata.filename='no file';
        userdata.channelpopupvis='off';
        userdata.channelpopupstr=[];
    else
        userdata=openfile(varargin{1}, basewindowstartdefault, basewindowdurationdefault);
    end
else
    userdata=openfile('none', basewindowstartdefault, basewindowdurationdefault);
end

if isstruct(userdata)
    %GUI window
    h0 = figure(...
        'Units','normalized',...
        'Name','ERV Physiology Data Reader. V 2.0',...
        'NumberTitle','off',...
        'Position',[0.01 0.23 0.60 0.69],...
        'doublebuffer', 'on', ...
        'Tag','readwindow', ...
        'UserData', userdata);
    a=get(h0, 'Color');

    %Plot type selection
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'Plot all', ...
        'Units','normalized',...
        'Position',[0.01 0.96 0.08 0.03], ...
        'Tag', 'plotallradio', ...
        'Callback', @plotall);
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'Plot one', ...
        'Units','normalized',...
        'Position',[0.01 0.925 0.08 0.03], ...
        'Tag', 'plotoneradio', ...
        'Callback', @plotone);
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'All-b', ...
        'Units','normalized',...
        'Position',[0.01 0.89 0.08 0.03], ...
        'Tag', 'plotall-bradio', ...
        'Callback', @allminusb);
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'One-b', ...
        'Units','normalized',...
        'Position',[0.01 0.855 0.08 0.03], ...
        'Tag', 'plotone-bradio', ...
        'Callback', @oneminusb);

    %Sweep selection
    uicontrol(h0, ...
        'Style', 'text', ...
        'String', 'Sweep #', ...
        'Units','normalized',...
        'Position',[0.28 0.96 0.08 0.03]);
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', '1', ...
        'Units','normalized',...
        'Position',[0.36 0.96 0.05 0.03], ...
        'ToolTipString', 'Sweep number', ...
        'Tag', 'sweepedit', ...
        'Callback', @sweepselect);
    uicontrol(h0, ...
        'String', 'Previous', ...
        'Units','normalized',...
        'Position',[0.1 0.96 0.08 0.03], ...
        'Callback', @previous);
    uicontrol(h0, ...
        'String', 'Next', ...
        'Units','normalized',...
        'Position',[0.19 0.96 0.08 0.03], ...
        'Callback', @next);
    uicontrol(h0, ...
        'String', 'Select', ...
        'Units','normalized',...
        'Position',[0.19 0.9275 0.08 0.03], ...
        'Callback', @select);
    uicontrol(h0, ...
        'String', 'Clear Selection', ...
        'Units','normalized',...
        'Position',[0.28 0.9275 0.08 0.03], ...
        'Callback', @clearselect);
    uicontrol(h0, ...
        'String', 'Select All', ...
        'Units','normalized',...
        'Position',[0.37 0.9275 0.08 0.03], ...
        'Callback', @allselect);

    %Mean of all or the selected traces
    uicontrol(h0, ...
        'String', 'Selection Mean', ...
        'Units','normalized',...
        'Position',[0.46 0.9275 0.08 0.03], ...
        'ToolTipString', 'Plots the mean of all selected sweeps, or the mean of all sweeps if none is selected.', ...
        'Callback', @selectionmean);

    %Channel selection
    uicontrol(h0, ...
        'Style', 'text', ...
        'String', 'Channel to Plot:', ...
        'Visible', userdata.channelpopupvis, ...
        'Units','normalized',...
        'Position',[0.56 0.935 0.07 0.02], ...
        'BackgroundColor', a, ...
        'Tag', 'channeltextpopup');
    uicontrol(h0, ...
        'Style', 'popup', ...
        'String', userdata.channelpopupstr, ...
        'Visible', userdata.channelpopupvis, ...
        'Units','normalized',...
        'Position',[0.63 0.9275 0.05 0.03], ...
        'Callback', @channelselect, ...
        'Tag', 'channelpopup');

    %Sweep Rs and Ri information
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'Rs:', ...
        'Units','normalized',...
        'Value', 1, ...
        'Position',[0.57 0.96 0.06 0.03], ...
        'Tag', 'rsradio', ...
        'Callback', @rs);
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', '?', ...
        'Units','normalized',...
        'Position',[0.63 0.96 0.05 0.03], ...
        'ToolTipString', 'Rs in MegaOhms', ...
        'Tag', 'rsedit');
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'Ri:', ...
        'Units','normalized',...
        'Value', 1, ...
        'Position',[0.69 0.96 0.06 0.03], ...
        'Tag', 'riradio', ...
        'Callback', @ri);
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', '?', ...
        'Units','normalized',...
        'Position',[0.75 0.96 0.05 0.03], ...
        'ToolTipString', 'Rs in MegaOhms', ...
        'Tag', 'riedit');

    %Baseline selection
    uicontrol(h0, ...
        'Style', 'text', ...
        'String', 'Baseline', ...
        'Units','normalized',...
        'Position',[0.42 0.96 0.08 0.03]);
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', num2str(basewindowstartdefault), ...
        'Units','normalized',...
        'Position',[0.5 0.96 0.03 0.03], ...
        'ToolTipString', 'Start of baseline in ms.', ...
        'Tag', 'basestartedit', ...
        'Callback', @basestart);
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', num2str(basewindowdurationdefault), ...
        'Units','normalized',...
        'Position',[0.53 0.96 0.03 0.03], ...
        'ToolTipString', 'Baseline duration in ms.', ...
        'Tag', 'basedurationedit', ...
        'Callback', @baseduration);

    %Y axis limits
    uicontrol(h0, ...
        'Style', 'text', ...
        'String', 'Y Axis limits:', ...
        'Units','normalized',...
        'HorizontalAlignment', 'right', ...
        'Position',[0.7 0.935 0.1 0.02], ...
        'BackgroundColor', a);
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', '-Inf', ...
        'Units','normalized',...
        'Position',[0.81 0.935 0.05 0.02], ...
        'ToolTipString', 'Start limit for the Y axis', ...
        'Tag', 'startaxisedit', ...
        'Callback', @axisselect);
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', 'Inf', ...
        'Units','normalized',...
        'Position',[0.865 0.935 0.05 0.02], ...
        'ToolTipString', 'End limit for the Y axis', ...
        'Tag', 'endaxisedit', ...
        'Callback', @axisselect);

    %Event detection
    uicontrol(h0, ...
        'String', 'Detect', ...
        'Units','normalized',...
        'Position',[0.01 0.82 0.08 0.03], ...
        'Callback', @detect);
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'Min', ...
        'Units','normalized',...
        'Value', 1, ...
        'Position',[0.01 0.785 0.08 0.03], ...
        'ToolTipString', 'Detect minimum amplitude', ...
        'Tag', 'minradio', ...
        'Callback', @detectmin);
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'Max', ...
        'Units','normalized',...
        'Position',[0.01 0.75 0.08 0.03], ...
        'ToolTipString', 'Detect maximum amplitude', ...
        'Tag', 'maxradio', ...
        'Callback', @detectmax);
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'Mean', ...
        'Units','normalized',...
        'Position',[0.01 0.715 0.08 0.03], ...
        'ToolTipString', 'Detect mean amplitude', ...
        'Tag', 'meanradio', ...
        'Callback', @detectmean);
    uicontrol(h0, ...
        'Style', 'radio', ...
        'String', 'Median', ...
        'Units','normalized',...
        'Position',[0.01 0.68 0.08 0.03], ...
        'ToolTipString', 'Detect median amplitude', ...
        'Tag', 'medianradio', ...
        'Callback', @detectmedian);
    uicontrol(h0, ...
        'Style', 'edit',  ...
        'String', '102', ...
        'Units','normalized',...
        'ToolTipString', 'Start of detection window in ms', ...
        'Position',[0.01 0.645 0.03 0.03], ...
        'Tag', 'winstartedit');
    uicontrol(h0, ...
        'String', 'S', ...
        'Units','normalized',...
        'ToolTipString', 'Select window start and end', ...
        'Position',[0.04 0.645 0.02 0.03], ...
        'Callback', @selectdetectionwindow);
    uicontrol(h0, ...
        'Style', 'edit',  ...
        'String', '110', ...
        'Units','normalized',...
        'ToolTipString', 'End of detection window in ms', ...
        'Position',[0.06 0.645 0.03 0.03], ...
        'tag', 'winendedit');

    %Action potential (or other event type) auto-detection function
    uicontrol(h0, ...
        'String', 'Detect APs', ...
        'Units','normalized',...
        'Position',[0.01 0.61 0.08 0.03], ...
        'Callback', @detectAps);

    %Noise distribution
    uicontrol(h0, ...
        'String', 'Noise', ...
        'Units','normalized',...
        'Position',[0.01 0.35 0.08 0.03], ...
        'Callback', @noise);

    %Event alignment
    uicontrol(h0, ...
        'String', 'Aligned', ...
        'Units','normalized',...
        'ToolTipString', 'Events in the selected window are aligned around its peak (min or max) before calculating the amplitude', ...
        'Position',[0.01 0.165 0.08 0.03], ...
        'Callback', @aligned);
    uicontrol(h0, ...
        'Style', 'text', ...
        'String', 'Time', ...
        'Units','normalized',...
        'Position',[0.01 0.13 0.05 0.03]);
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', '0.5', ...
        'Units','normalized',...
        'Position',[0.06 0.13 0.03 0.03], ...
        'ToolTipString', 'Time window in ms (+/-) to calculate the average amplitude of the events in the aligned detection mode', ...
        'Tag', 'winplusminusedit');

    %Batch analysis
    uicontrol(h0, ...
        'String', 'Batch group', ...
        'Units','normalized',...
        'Position',[0.01 0.27 0.08 0.03], ...
        'Callback', @batchgroup);
   
    %File/data selection and information
    uicontrol(h0, ...
        'Style', 'edit', ...
        'String', ['File: ', userdata.filename], ...
        'Units','normalized',...
        'Position',[0.81 0.96 0.15 0.03], ...
        'Tag', 'filetext', ...
        'Callback', @nextfile);
    uicontrol(h0, ...
        'String', 'Batch open', ...
        'Units','normalized',...
        'Position',[0.01 0.235 0.08 0.03], ...
        'Callback', @batchopen);
    a=evalin('base', 'who(''name'', ''Ephys*'')');
    uicontrol(h0, ...
        'Style', 'popup', ...
        'String', ['Select data'; a], ...
        'Units','normalized',...
        'Position',[0.01 0.2 0.08 0.03], ...
         'Tag', 'datapopup', ...
        'Callback', @newdata);
    uicontrol(h0, ...
        'String', 'New File', ...
        'Units','normalized',...
        'Position',[0.01 0.095 0.08 0.03], ...
        'Callback', @newfile);

    uicontrol(h0, ...
        'String', 'Select TIFs', ...
        'Units','normalized',...
        'Position',[0.01 0.05 0.08 0.03], ...
        'Callback', @selecttifs);
    uicontrol(h0, ...
        'String', 'Select IMGDATs', ...
        'Units','normalized',...
        'Position',[0.095 0.05 0.08 0.03], ...
        'Callback', @selectimgdats);
    uicontrol(h0, ...
        'String', 'TIFs path', ...
        'Units','normalized',...
        'Position',[0.01 0.01 0.08 0.03], ...
        'Callback', @selecttifpath);
    uicontrol(h0, ...
        'Style', 'text', ...
        'String', 'D:\Imaging', ...
        'Units','normalized',...
        'Position',[0.095 0.01 0.1 0.03], ...
        'Tag', 'tifpathtext');

    %Data in the figure to the workspace as a structure
    uicontrol(h0, ...
        'String', 'Data to Workspace', ...
        'Units','normalized',...
        'Position',[0.89 0.01 0.1 0.03], ...
        'Callback', @datatoworkspace);

    %Default initial action
    set(findobj('Tag', 'plotallradio'), 'Value', 1);
    if ~strcmp(userdata.filename, 'no file')
        plotall;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function userdata=openfile(filename, basewindowstartdefault, basewindowdurationdefault)
%File header:
%Year
%Month
%Day
%Number of channels acquired
%Acquisition rate in samples per second
%Sweep length in samples
%Inter-sweep interval
%Number of sweeps
%Header size
%Tail size
%
%Sweep tail (after each sweep of acquired data):
%Mode (0 is V-clamp, 1 is I-clamp)
%Gainscalefactor used
%Acquisition order
%Rs in megaOhms
%Ri in megaOhms
%Cm in picoFaradays

%Select path
pathname=textread([matlabroot, '\work\Physiology\dat_directory_name.erv'], '%s', 'whitespace', '');
%a=fopen([matlabroot, '\work\Physiology\dat_directory_name.erv'], 'w+');
%fprintf(a, '%s', pathname{:});
%fclose(a);
pathname=[pathname{:}, '\'];

if strcmp(filename, 'batch')
    d=dir([pathname, '*.dat']);
    str={d.name}; %file names in the path.
    [s,v]=listdlg('PromptString','Select files:', ...
        'ListString',str, ...
        'name', 'Batch opener');
    if v==0
        userdata=0;
    else
        for i=1:length(s)
            filename=str{s(i)};

            %Opens the file
            userdata.filename=filename;
            bin=fopen([pathname filename], 'r');
            data=fread(bin, 'float');
            fclose(bin);
            
            %Reads the header
            userdata.recordingdate=[num2str(data(2)), '/', num2str(data(3)), '/', num2str(data(1))];
            userdata.channelnumber=data(4);
            userdata.samplerate=data(5);
            userdata.sweeplength=data(6);
            userdata.isinterval=data(7);
            userdata.sweepnumber=data(8);
            userdata.headersize=data(9);
            userdata.tailsize=data(10);

            %Indeces for displaying info
            userdata.modeindex=1;
            userdata.rsindex=4;
            userdata.riindex=5;
            userdata.cmindex=6;

            %Removes the header
            userdata.data=data(userdata.headersize+1:end);
            
            %Separates the sweeps
            if size(userdata.data,1)>userdata.sweepnumber*userdata.channelnumber*(userdata.sweeplength+userdata.tailsize)
                warndlg('More data than indicated by the header!')
                userdata=0;
            elseif size(userdata.data,1)<userdata.sweepnumber*userdata.channelnumber*(userdata.sweeplength+userdata.tailsize)
                userdata=datrepair(userdata, basewindowstartdefault, basewindowdurationdefault);
            elseif size(userdata.data,1)==userdata.sweepnumber*userdata.channelnumber*(userdata.sweeplength+userdata.tailsize)
                datamat=reshape(userdata.data, userdata.sweeplength+userdata.tailsize, userdata.sweepnumber*userdata.channelnumber);
                userdata.channelpopupstr={};
                userdata.datamatchan={};
                userdata.parammatchan={};
                if userdata.channelnumber>1
                    userdata.channelpopupvis='on';
                    for i=1:userdata.channelnumber
                        userdata.datamatchan{i}=datamat(1:userdata.sweeplength,i:userdata.channelnumber:end);
                        userdata.parammatchan{i}=datamat(userdata.sweeplength+1:end,i:userdata.channelnumber:end);
                        userdata.channelpopupstr{i}=['Ch: ', num2str(i)];
                    end
                    userdata.datamat=userdata.datamatchan{1}; %The first channel is selected by default
                    userdata.parammat=userdata.parammatchan{1}; %The first channel is selected by default
                else
                    userdata.channelpopupvis='off';
                    userdata.channelpopupstr={'Ch: 1'};
                    userdata.parammat=datamat(userdata.sweeplength+1:end,:);
                    userdata.datamat=datamat(1:userdata.sweeplength,:);
                end
                recordingmode=mean(userdata.parammat(userdata.modeindex,:));
                if recordingmode==0
                    userdata.recordingmode='Current in pA.';
                elseif recordingmode==1
                    userdata.recordingmode='Voltage in mV.';
                elseif isnan(recordingmode)
                    userdata.recordingmode='Raw signal in V.';
                else
                    userdata.recordingmode='More than one recording mode or Mode Error';
                end

                %Generates the time scale
                userdata.timescale=1000/userdata.samplerate:1000/userdata.samplerate:1000*userdata.sweeplength/userdata.samplerate;

                %Substracts the baseline to the sweeps
                userdata.baselinemat=userdata.datamat(userdata.samplerate*basewindowstartdefault/1000:userdata.samplerate*basewindowstartdefault/1000+userdata.samplerate*basewindowdurationdefault/1000, :);
                userdata.baseline=mean(userdata.baselinemat);
                userdata.datamatbase=userdata.datamat-repmat(userdata.baseline, userdata.sweeplength, 1);
                
                %Additional variables to be filled during analysis
                userdata.noisemat=[];
                userdata.selected=[];
                userdata.selectedindex=[];
                userdata.events=[];
                userdata.selectedevents=[];
                userdata.alignedevents=[];
                userdata.noisemat=[];
                userdata.selectedAPssweep=[];
                userdata.selectedAPsnumber=[];
                userdata.selectedAPsindex=[];
                userdata.selectedAPspeakindex=[];
                userdata.selectedAPs=[];
                userdata.selectedAPspeak=[];
                userdata.selectedAPsmean=[];
                userdata.lines=[];
                userdata.linestime=[];
                userdata.selectedAPsimage=[];
                userdata.selectedAPsimagemean=[];

                %Assigns the userdata structure to the workspace
                assignin('base', ['Ephys', userdata.filename(1:end-4)], userdata);
            else
                %Assigns the userdata structure to the workspace
                assignin('base', ['Ephys', userdata.filename(1:end-4)], userdata);
                userdata=0;
            end
        end
    end
else
    if strcmp(filename, 'none')
        [filename, pathname]=uigetfile([pathname, '*.dat'], 'Select data file');
        if filename==0
            userdata=0;
            return
        end
        a=fopen([matlabroot, '\work\Physiology\dat_directory_name.erv'], 'w+');
        fprintf(a, '%s', pathname(1:end-1));
        fclose(a);
        filename
    end
    %Opens the file
    userdata.filename=filename;
    bin=fopen([pathname filename], 'r');
    if bin==-1
        userdata=0;
        'No such file'
        return
    end
    data=fread(bin, 'float');
    fclose(bin);

    %Reads the header
    userdata.recordingdate=[num2str(data(2)), '/', num2str(data(3)), '/', num2str(data(1))];
    userdata.channelnumber=data(4);
    userdata.samplerate=data(5);
    userdata.sweeplength=data(6);
    userdata.isinterval=data(7);
    userdata.sweepnumber=data(8);
    userdata.headersize=data(9);
    userdata.tailsize=data(10);

    %Indeces for displaying info
    userdata.modeindex=1;
    userdata.rsindex=4;
    userdata.riindex=5;
    userdata.cmindex=6;

    %Removes the header
    userdata.data=data(userdata.headersize+1:end);
    assignin('base', 'userdata', userdata);
    
    %Separates the sweeps
    if size(userdata.data,1)>userdata.sweepnumber*userdata.channelnumber*(userdata.sweeplength+userdata.tailsize)
        warndlg('More data than indicated by the header!')
        userdata=0;
    elseif size(userdata.data,1)<userdata.sweepnumber*userdata.channelnumber*(userdata.sweeplength+userdata.tailsize)
        userdata=datrepair(userdata, basewindowstartdefault, basewindowdurationdefault);
        assignin('base', 'userdata', userdata);
    elseif size(userdata.data,1)==userdata.sweepnumber*userdata.channelnumber*(userdata.sweeplength+userdata.tailsize)
        datamat=reshape(userdata.data, userdata.sweeplength+userdata.tailsize, userdata.sweepnumber*userdata.channelnumber);
        userdata.channelpopupstr={};
        userdata.datamatchan={};
        userdata.parammatchan={};
        if userdata.channelnumber>1
            userdata.channelpopupvis='on';
            for i=1:userdata.channelnumber
                userdata.datamatchan{i}=datamat(1:userdata.sweeplength,i:userdata.channelnumber:end);
                userdata.parammatchan{i}=datamat(userdata.sweeplength+1:end,i:userdata.channelnumber:end);
                userdata.channelpopupstr{i}=['Ch: ', num2str(i)];
            end
            userdata.datamat=userdata.datamatchan{1}; %The first channel is selected by default
            userdata.parammat=userdata.parammatchan{1}; %The first channel is selected by default
        else
            userdata.channelpopupvis='off';
            userdata.channelpopupstr={'Ch: 1'};
            userdata.parammat=datamat(userdata.sweeplength+1:end,:);
            userdata.datamat=datamat(1:userdata.sweeplength,:);
        end
        recordingmode=mean(userdata.parammat(userdata.modeindex,:));
        if recordingmode==0
            userdata.recordingmode='Current in pA.';
        elseif recordingmode==1
            userdata.recordingmode='Voltage in mV.';
        elseif isnan(recordingmode)
            userdata.recordingmode='Raw signal in V.';
        else
            userdata.recordingmode='More than one recording mode or Mode Error';
        end

        %Generates the time scale
        userdata.timescale=1000/userdata.samplerate:1000/userdata.samplerate:1000*userdata.sweeplength/userdata.samplerate;

        %Substracts the baseline to the sweeps
        userdata.baselinemat=userdata.datamat(userdata.samplerate*basewindowstartdefault/1000:userdata.samplerate*basewindowstartdefault/1000+userdata.samplerate*basewindowdurationdefault/1000, :);
        userdata.baseline=mean(userdata.baselinemat);
        userdata.datamatbase=userdata.datamat-repmat(userdata.baseline, userdata.sweeplength, 1);

        %Additional variables to be filled during analysis
        userdata.noisemat=[];
        userdata.selected=[];
        userdata.selectedindex=[];
        userdata.events=[];
        userdata.selectedevents=[];
        userdata.alignedevents=[];
        userdata.noisemat=[];
        userdata.selectedAPssweep=[];
        userdata.selectedAPsnumber=[];
        userdata.selectedAPsindex=[];
        userdata.selectedAPspeakindex=[];
        userdata.selectedAPs=[];
        userdata.selectedAPsmean=[];
        userdata.lines=[];
        userdata.linestime=[];
        userdata.selectedAPsimage=[];
        userdata.selectedAPsimagemean=[];
        
        %Updates the userdata in the workspace
        assignin('base', 'userdata', userdata);
    end   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotall(obj, event)

if get(findobj('Tag', 'plotallradio'), 'Value')==1
    set(findobj('Tag', 'plotoneradio'), 'Value', 0);
    set(findobj('Tag', 'plotall-bradio'), 'Value', 0);
    set(findobj('Tag', 'plotone-bradio'), 'Value', 0);
    set(findobj('Tag', 'rsedit'), 'String', '?');
    set(findobj('Tag', 'riedit'), 'String', '?');
    
    userdata=get(findobj('Tag', 'readwindow'), 'UserData');
    
    plot(userdata.timescale, userdata.datamat);
    if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
        ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
    end
    set(gca, 'Tag', 'dataaxes');
    xlabel('Time in ms.');
    ylabel(userdata.recordingmode);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotone(obj, event)

if get(findobj('Tag', 'plotoneradio'), 'Value')==1
    set(findobj('Tag', 'plotallradio'), 'Value', 0);
    set(findobj('Tag', 'plotall-bradio'), 'Value', 0);
    set(findobj('Tag', 'plotone-bradio'), 'Value', 0);
    
    userdata=get(findobj('Tag', 'readwindow'), 'UserData');

    if str2double(get(findobj('Tag', 'sweepedit'), 'String'))<=userdata.sweepnumber && str2double(get(findobj('Tag', 'sweepedit'), 'String'))>0
    else
        set(findobj('Tag', 'sweepedit'), 'String', userdata.sweepnumber);
    end

    plot(userdata.timescale, userdata.datamat(:,str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
    if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
        ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
    end
    set(gca, 'Tag', 'dataaxes');
    xlabel('Time in ms.');
    if userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==0;
        ylabel('Current in pA.');
    elseif userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==1;
        ylabel('Voltage in mV.');
    elseif isnan(userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
        ylabel('Raw signal in V.');
    end
    if get(findobj('Tag', 'rsradio'), 'Value')==1;
        set(findobj('Tag', 'rsedit'), 'String', num2str(userdata.parammat(userdata.rsindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
    end
    if get(findobj('Tag', 'riradio'), 'Value')==1
        set(findobj('Tag', 'riedit'), 'String', num2str(userdata.parammat(userdata.riindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allminusb(obj, event)

if get(findobj('Tag', 'plotall-bradio'), 'Value')==1
    set(findobj('Tag', 'plotone-bradio'), 'Value', 0);
    set(findobj('Tag', 'plotallradio'), 'Value', 0);
    set(findobj('Tag', 'plotoneradio'), 'Value', 0);
    set(findobj('Tag', 'rsedit'), 'String', '?');
    set(findobj('Tag', 'riedit'), 'String', '?');

    userdata=get(findobj('Tag', 'readwindow'), 'UserData');
    
    plot(userdata.timescale, userdata.datamatbase);
    if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
        ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
    end
    set(gca, 'Tag', 'dataaxes');
    xlabel('Time in ms.');
    ylabel(userdata.recordingmode);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oneminusb(obj, event)

if get(findobj('Tag', 'plotone-bradio'), 'Value')==1
    set(findobj('Tag', 'plotallradio'), 'Value', 0);
    set(findobj('Tag', 'plotall-bradio'), 'Value', 0);
    set(findobj('Tag', 'plotoneradio'), 'Value', 0);
    
    userdata=get(findobj('Tag', 'readwindow'), 'UserData');
    
    if str2double(get(findobj('Tag', 'sweepedit'), 'String'))<=userdata.sweepnumber && str2double(get(findobj('Tag', 'sweepedit'), 'String'))>0
    else
        set(findobj('Tag', 'sweepedit'), 'String', userdata.sweepnumber);
    end
    
    plot(userdata.timescale, userdata.datamatbase(:,str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
    if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
        ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
    end
    set(gca, 'Tag', 'dataaxes');
    xlabel('Time in ms.');
    if userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==0;
        ylabel('Current in pA.');
    elseif userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==1;
        ylabel('Voltage in mV.');
    elseif isnan(userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
        ylabel('Raw signal in V.');
    end
    if get(findobj('Tag', 'rsradio'), 'Value')==1;
        set(findobj('Tag', 'rsedit'), 'String', num2str(userdata.parammat(userdata.rsindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
    end
    if get(findobj('Tag', 'riradio'), 'Value')==1
        set(findobj('Tag', 'riedit'), 'String', num2str(userdata.parammat(userdata.riindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function previous(obj, event)

if str2double(get(findobj('Tag', 'sweepedit'), 'String'))>1
    userdata=get(findobj('Tag', 'readwindow'), 'UserData');
    set(findobj('Tag', 'sweepedit'), 'String', num2str(str2double(get(findobj('Tag', 'sweepedit'), 'String'))-1));
    if get(findobj('Tag', 'plotone-bradio'), 'Value')==1
        plot(userdata.timescale, userdata.datamatbase(:,str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
        if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
            ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
        end
        set(gca, 'Tag', 'dataaxes');
        xlabel('Time in ms.');
        if userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==0
            ylabel('Current in pA.');
        elseif userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==1
            ylabel('Voltage in mV.');
        elseif isnan(userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
            ylabel('Raw signal in V.');
        end
        if get(findobj('Tag', 'rsradio'), 'Value')==1;
            set(findobj('Tag', 'rsedit'), 'String', num2str(userdata.parammat(userdata.rsindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
        end
        if get(findobj('Tag', 'riradio'), 'Value')==1
            set(findobj('Tag', 'riedit'), 'String', num2str(userdata.parammat(userdata.riindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
        end
    elseif get(findobj('Tag', 'plotoneradio'), 'Value')==1
        plot(userdata.timescale, userdata.datamat(:,str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
        if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
            ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
        end
        set(gca, 'Tag', 'dataaxes');
        xlabel('Time in ms.');
        if userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==0
            ylabel('Current in pA.');
        elseif userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==1
            ylabel('Voltage in mV.');
        elseif isnan(userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
            ylabel('Raw signal in V.');
        end
        if get(findobj('Tag', 'rsradio'), 'Value')==1;
            set(findobj('Tag', 'rsedit'), 'String', num2str(userdata.parammat(userdata.rsindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
        end
        if get(findobj('Tag', 'riradio'), 'Value')==1
            set(findobj('Tag', 'riedit'), 'String', num2str(userdata.parammat(userdata.riindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
        end
    else
        set(findobj('Tag', 'sweepedit'), 'String', num2str(str2double(get(findobj('Tag', 'sweepedit'), 'String'))+1));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function next(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
if str2double(get(findobj('Tag', 'sweepedit'), 'String'))<userdata.sweepnumber
    set(findobj('Tag', 'sweepedit'), 'String', num2str(str2double(get(findobj('Tag', 'sweepedit'), 'String'))+1));
    if get(findobj('Tag', 'plotone-bradio'), 'Value')==1
        plot(userdata.timescale, userdata.datamatbase(:,str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
        if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
            ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
        end
        set(gca, 'Tag', 'dataaxes');
        xlabel('Time in ms.');
        if userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==0
            ylabel('Current in pA.');
        elseif userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==1
            ylabel('Voltage in mV.');
        elseif isnan(userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
            ylabel('Raw signal in V.');
        end
        if get(findobj('Tag', 'rsradio'), 'Value')==1;
            set(findobj('Tag', 'rsedit'), 'String', num2str(userdata.parammat(userdata.rsindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
        end
        if get(findobj('Tag', 'riradio'), 'Value')==1
            set(findobj('Tag', 'riedit'), 'String', num2str(userdata.parammat(userdata.riindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
        end
    elseif get(findobj('Tag', 'plotoneradio'), 'Value')==1
        plot(userdata.timescale, userdata.datamat(:,str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
        if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
            ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
        end
        set(gca, 'Tag', 'dataaxes');
        xlabel('Time in ms.');
        if userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==0
            ylabel('Current in pA.');
        elseif userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==1
            ylabel('Voltage in mV.');
        elseif isnan(userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
            ylabel('Raw signal in V.');
        end
        if get(findobj('Tag', 'rsradio'), 'Value')==1;
            set(findobj('Tag', 'rsedit'), 'String', num2str(userdata.parammat(userdata.rsindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
        end
        if get(findobj('Tag', 'riradio'), 'Value')==1
            set(findobj('Tag', 'riedit'), 'String', num2str(userdata.parammat(userdata.riindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
        end
    else
        set(findobj('Tag', 'sweepedit'), 'String', num2str(str2double(get(findobj('Tag', 'sweepedit'), 'String'))-1));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
userdata.selected=[userdata.selected userdata.datamat(:,str2double(get(findobj('Tag', 'sweepedit'), 'String')))];
userdata.selectedindex=[userdata.selectedindex str2double(get(findobj('Tag', 'sweepedit'), 'String'))];
set(findobj('Tag', 'readwindow'), 'UserData', userdata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clearselect(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
userdata.selected=[];
userdata.selectedindex=[];
set(findobj('Tag', 'readwindow'), 'UserData', userdata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allselect(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
userdata.selected=userdata.datamat;
userdata.selectedindex=1:1:userdata.sweepnumber;
set(findobj('Tag', 'readwindow'), 'UserData', userdata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sweepselect(obj, event)

if get(findobj('Tag', 'plotallradio'), 'Value')==1 || get(findobj('Tag', 'plotoneradio'), 'Value')==1
    set(findobj('Tag', 'plotoneradio'), 'Value', 1);
    plotone;
elseif get(findobj('Tag', 'plotall-bradio'), 'Value')==1 || get(findobj('Tag', 'plotone-bradio'), 'Value')==1
    set(findobj('Tag', 'plotone-bradio'), 'Value', 1);
    oneminusb;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selectionmean(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
if ~strcmp(userdata.filename, 'no file')
    set(findobj('Tag', 'plotallradio'), 'Value', 0);
    set(findobj('Tag', 'plotoneradio'), 'Value', 0);
    set(findobj('Tag', 'plotall-bradio'), 'Value', 0);
    set(findobj('Tag', 'plotone-bradio'), 'Value', 0);
    if isempty(userdata.selectedindex)
        plot(userdata.timescale, mean(userdata.datamatbase,2));
        if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
            ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
        end
        set(gca, 'Tag', 'dataaxes');
        xlabel('Time in ms.');
        if userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==0
            ylabel('Current in pA.');
        elseif userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==1
            ylabel('Voltage in mV.');
        elseif isnan(userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
            ylabel('Raw signal in V.');
        end
    else
        a=userdata.datamatbase(:,userdata.selectedindex);
        plot(userdata.timescale, mean(a,2));
        if ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf') || ~strcmp(get(findobj('Tag', 'startaxisedit'), 'String'), '-Inf')
            ylim([str2double(get(findobj('Tag', 'startaxisedit'), 'String')) str2double(get(findobj('Tag', 'endaxisedit'), 'String'))]);
        end
        set(gca, 'Tag', 'dataaxes');
        xlabel('Time in ms.');
        if userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==0
            ylabel('Current in pA.');
        elseif userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String')))==1
            ylabel('Voltage in mV.');
        elseif isnan(userdata.parammat(userdata.modeindex, str2double(get(findobj('Tag', 'sweepedit'), 'String'))));
            ylabel('Raw signal in V.');
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function basestart(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
userdata.baselinemat=userdata.datamat(userdata.samplerate*str2double(get(findobj('Tag', 'basestartedit'), 'String'))/1000:userdata.samplerate*str2double(get(findobj('Tag', 'basestartedit'), 'String'))/1000+userdata.samplerate*str2double(get(findobj('Tag', 'basedurationedit'), 'String'))/1000, :);
userdata.baseline=mean(userdata.baselinemat);
userdata.datamatbase=userdata.datamat-repmat(userdata.baseline, userdata.sweeplength, 1);
set(findobj('Tag', 'readwindow'), 'UserData', userdata);
if get(findobj('Tag', 'plotallradio'), 'Value')==1 || get(findobj('Tag', 'plotall-bradio'), 'Value')==1
    set(findobj('Tag', 'plotall-bradio'), 'Value', 1);
    allminusb;
elseif get(findobj('Tag', 'plotoneradio'), 'Value')==1 || get(findobj('Tag', 'plotone-bradio'), 'Value')==1
    set(findobj('Tag', 'plotone-bradio'), 'Value', 1);
    oneminusb;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function baseduration(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
userdata.baselinemat=userdata.datamat(userdata.samplerate*str2double(get(findobj('Tag', 'basestartedit'), 'String'))/1000:userdata.samplerate*str2double(get(findobj('Tag', 'basestartedit'), 'String'))/1000+userdata.samplerate*str2double(get(findobj('Tag', 'basedurationedit'), 'String'))/1000, :);
userdata.baseline=mean(userdata.baselinemat);
userdata.datamatbase=userdata.datamat-repmat(userdata.baseline, userdata.sweeplength, 1);
set(findobj('Tag', 'readwindow'), 'UserData', userdata);
if get(findobj('Tag', 'plotallradio'), 'Value')==1 || get(findobj('Tag', 'plotall-bradio'), 'Value')==1
    set(findobj('Tag', 'plotall-bradio'), 'Value', 1);
    allminusb;
elseif get(findobj('Tag', 'plotoneradio'), 'Value')==1 || get(findobj('Tag', 'plotone-bradio'), 'Value')==1
    set(findobj('Tag', 'plotone-bradio'), 'Value', 1);
    oneminusb;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rs(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
if get(findobj('Tag', 'plotone-bradio'), 'Value')==1 || get(findobj('Tag', 'plotoneradio'), 'Value')==1
    set(findobj('Tag', 'rsedit'), 'String', num2str(userdata.parammat(userdata.rsindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
else
    set(findobj('Tag', 'rsedit'), 'String', '?');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ri(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
if get(findobj('Tag', 'plotone-bradio'), 'Value')==1 || get(findobj('Tag', 'plotoneradio'), 'Value')==1
    set(findobj('Tag', 'riedit'), 'String', num2str(userdata.parammat(userdata.riindex,str2double(get(findobj('Tag', 'sweepedit'), 'String')))));
else
    set(findobj('Tag', 'riedit'), 'String', '?');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function detect(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
a=userdata.datamatbase(userdata.samplerate*str2double(get(findobj('Tag', 'winstartedit'), 'String'))/1000:userdata.samplerate*str2double(get(findobj('Tag', 'winendedit'), 'String'))/1000, :);
if get(findobj('Tag', 'minradio'), 'Value')==1
    userdata.events=min(a);
elseif get(findobj('Tag', 'maxradio'), 'Value')==1
    userdata.events=max(a);
elseif get(findobj('Tag', 'meanradio'), 'Value')==1
    userdata.events=mean(a);
elseif get(findobj('Tag', 'medianradio'), 'Value')==1
    userdata.events=median(a);
end
if isempty(userdata.selected)
else
    a=userdata.selected(userdata.samplerate*str2double(get(findobj('Tag', 'winstartedit'), 'String'))/1000:userdata.samplerate*str2double(get(findobj('Tag', 'winendedit'), 'String'))/1000, :);
    if get(findobj('Tag', 'minradio'), 'Value')==1
        userdata.selectedevents=min(a);
    elseif get(findobj('Tag', 'maxradio'), 'Value')==1
        userdata.selectedevents=max(a);
    elseif get(findobj('Tag', 'meanradio'), 'Value')==1
        userdata.selectedevents=mean(a);
    elseif get(findobj('Tag', 'medianradio'), 'Value')==1
        userdata.selectedevents=median(a);
    end
end
set(findobj('Tag', 'readwindow'), 'UserData', userdata);
assignin('base', 'events', userdata.events);
assignin('base', 'selectedevents', userdata.selectedevents);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function detectmax(obj, event)

if get(findobj('Tag', 'maxradio'), 'Value')==1
    set(findobj('Tag', 'minradio'), 'Value', 0);
    set(findobj('Tag', 'meanradio'), 'Value', 0);
    set(findobj('Tag', 'medianradio'), 'Value', 0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function detectmin(obj, event)

if get(findobj('Tag', 'minradio'), 'Value')==1
    set(findobj('Tag', 'maxradio'), 'Value', 0);
    set(findobj('Tag', 'meanradio'), 'Value', 0);
    set(findobj('Tag', 'medianradio'), 'Value', 0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function detectmean(obj, event)

if get(findobj('Tag', 'meanradio'), 'Value')==1
    set(findobj('Tag', 'minradio'), 'Value', 0);
    set(findobj('Tag', 'maxradio'), 'Value', 0);
    set(findobj('Tag', 'medianradio'), 'Value', 0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function detectmedian(obj, event)

if get(findobj('Tag', 'medianradio'), 'Value')==1
    set(findobj('Tag', 'minradio'), 'Value', 0);
    set(findobj('Tag', 'meanradio'), 'Value', 0);
    set(findobj('Tag', 'maxradio'), 'Value', 0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selectdetectionwindow(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
[x,y]=ginput(2);
set(findobj('Tag', 'winstartedit'), 'String', num2str(round(x(1)*(userdata.samplerate/1000))/(userdata.samplerate/1000)));
set(findobj('Tag', 'winendedit'), 'String', num2str(round(x(2)*(userdata.samplerate/1000))/(userdata.samplerate/1000)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function detectAps(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
synchronizechanneltext=1:userdata.channelnumber;
close(findobj('Tag', 'apwindow'));
h0 = figure(...
    'Units','normalized',...
    'Name','AP selector',...
    'NumberTitle','off',...
    'MenuBar', 'none', ...
    'Position',[0.62 0.76 0.2 0.177], ...
    'Tag','apwindow');
a=get(gcf, 'Color');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Events selected:', ...
    'Units','normalized',...
    'Position',[0.01 0.9 0.25 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', '0', ...
    'Units','normalized',...
    'Position',[0.26 0.9 0.2 0.08], ...
    'Tag', 'apsselectedtext');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Window before:', ...
    'Units','normalized',...
    'Position',[0.01 0.8 0.25 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', '100', ...
    'Units','normalized',...
    'Position',[0.26 0.8 0.1 0.08], ...
    'Tag', 'windowbeforeedit');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'ms', ...
    'Units','normalized',...
    'Position',[0.36 0.8 0.05 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Window after:', ...
    'Units','normalized',...
    'Position',[0.01 0.7 0.25 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', '500', ...
    'Units','normalized',...
    'Position',[0.26 0.7 0.1 0.08], ...
    'Tag', 'windowafteredit');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'ms', ...
    'Units','normalized',...
    'Position',[0.36 0.7 0.05 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Window around:', ...
    'Units','normalized',...
    'Position',[0.01 0.6 0.25 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', '10', ...
    'Units','normalized',...
    'Position',[0.26 0.6 0.1 0.08], ...
    'Tag', 'windowaroundedit');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'ms', ...
    'Units','normalized',...
    'Position',[0.36 0.6 0.05 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'checkbox', ...
    'String', '', ...
    'Units','normalized',...
    'Position',[0.42 0.8 0.05 0.07], ...
    'ToolTipString', 'Select ONE AP per trace', ...
    'Tag', 'selectoneapcheckbox', ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'One', ...
    'Units','normalized',...
    'ToolTipString', 'Select ONE AP per trace', ...
    'Position',[0.415 0.75 0.05 0.05], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'AP', ...
    'Units','normalized',...
    'ToolTipString', 'Select ONE AP per trace', ...
    'Position',[0.42 0.7 0.05 0.05], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'checkbox', ...
    'String', 'Synchronize TIFs', ...
    'Units','normalized',...
    'Value', 1, ...
    'Position',[0.05 0.5 0.28 0.07], ...
    'Tag', 'synchronizetifcheckbox', ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'ILI:', ...
    'Units','normalized',...
    'ToolTipString', 'Fluoview Inter-Line Interval in ms', ...
    'Position',[0.33 0.5 0.05 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', '0.5', ...
    'Units','normalized',...
    'ToolTipString', 'Fluoview Inter-Line Interval in ms', ...
    'Position',[0.38 0.5 0.08 0.08], ...
    'Tag', 'iliedit');
uicontrol(h0, ...
    'Style', 'checkbox', ...
    'String', 'Synchronize IMGDATs', ...
    'Units','normalized',...
    'Value', 0, ...
    'Position',[0.05 0.4 0.4 0.07], ...
    'Tag', 'synchronizeimgdatcheckbox', ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'checkbox', ...
    'String', 'Synchronize chan.', ...
    'Units','normalized',...
    'Position',[0.05 0.3 0.3 0.07], ...
    'Tag', 'synchronizechannelcheckbox', ...
    'ToolTipString', 'Synchronizes the acquisition channel used to acquire the PMT signal', ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'popup', ...
    'String', synchronizechanneltext, ...
    'Units','normalized',...
    'Position',[0.36 0.3 0.1 0.08], ...
    'Tag', 'synchronizechannelpopup');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Chan.', ...
    'Units','normalized',...
    'ToolTipString', 'Threshold value to apply to the PMT channel', ...
    'Position',[0.36 0.18 0.1 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'thresh.', ...
    'Units','normalized',...
    'ToolTipString', 'Threshold value to apply to the PMT channel', ...
    'Position',[0.36 0.11 0.1 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', '0.05', ...
    'Units','normalized',...
    'Position',[0.36 0.02 0.1 0.08], ...
    'Tag', 'channelthresholdedit');
uicontrol(h0, ...
    'String', 'Start AP Selection', ...
    'Units','normalized',...
    'Position',[0.05 0.15 0.3 0.1], ...
    'Callback', @startAPselection, ...
    'Tag', 'startAPselectionbutton');
uicontrol(h0, ...
    'String', 'Selection Done', ...
    'Units','normalized',...
    'Position',[0.05 0.02 0.3 0.1], ...
    'Callback', @selectionDone);
uicontrol(h0, ...
    'Style', 'frame', ...
    'Units','normalized',...
    'Position',[0.48 0.01 0.005 0.98], ...
    'BackgroundColor', 'k');
uicontrol(h0, ...
    'String', 'Start Automatic Selection', ...
    'Units','normalized',...
    'Position',[0.5 0.89 0.48 0.1], ...
    'Callback', @autoAPselection, ...
    'Tag', 'autoAPselectionbutton');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Ready!', ...
    'Units','normalized',...
    'Position',[0.5 0.8 0.48 0.07], ...
    'Tag', 'autoAPtext');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Amplitude threshold:', ...
    'Units','normalized',...
    'Position',[0.5 0.7 0.3 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', '?', ...
    'Units','normalized',...
    'ToolTipString', 'Threshold, in mV, for Action Potential detection', ...
    'Position',[0.78 0.7 0.2 0.07], ...
    'Tag', 'autoAPamplitudetext');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Time window:', ...
    'Units','normalized',...
    'Position',[0.5 0.6 0.28 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', '? - ?', ...
    'Units','normalized',...
    'ToolTipString', 'Time window, in ms, for Action Potential detection', ...
    'Position',[0.78 0.6 0.2 0.07], ...
    'Tag', 'autoAPwindowtext');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Events detected:', ...
    'Units','normalized',...
    'Position',[0.5 0.5 0.28 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', '?', ...
    'Units','normalized',...
    'ToolTipString', 'Number of Action Potentials detected', ...
    'Position',[0.78 0.5 0.2 0.07], ...
    'Tag', 'autoAPdetectedtext');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Image filename:', ...
    'Units','normalized',...
    'Position',[0.5 0.4 0.2 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', userdata.filename(1:8), ...
    'Units','normalized',...
    'ToolTipString', 'Image file name', ...
    'Position',[0.7 0.4 0.2 0.07], ...
    'Tag', 'autoAPfilenameedit');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', '-', ...
    'Units','normalized',...
    'Position',[0.9 0.4 0.01 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', '4', ...
    'Units','normalized',...
    'ToolTipString', 'Number of digits in the file name (Fluoview default is 4 and naming starts at 0000)', ...
    'Position',[0.92 0.4 0.04 0.07], ...
    'Tag', 'autoAPfilenamedigitsedit');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'd', ...
    'Units','normalized',...
    'Position',[0.96 0.4 0.02 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Image start time:', ...
    'Units','normalized',...
    'Position',[0.5 0.3 0.28 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', '20', ...
    'Units','normalized',...
    'ToolTipString', 'Start of imaging in ms after start of physiology', ...
    'Position',[0.78 0.3 0.2 0.07], ...
    'Tag', 'autoAPimagedelayedit');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Image operation:', ...
    'Units','normalized',...
    'Position',[0.5 0.2 0.28 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'popup', ...
    'String', 'Mean|Median|Sum|Variance', ...
    'Units','normalized',...
    'ToolTipString', 'Operation to apply to each selected feature', ...
    'Position',[0.78 0.21 0.2 0.08], ...
    'Tag', 'autoAPoperationpopup');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'Sweep number limits:', ...
    'Units','normalized',...
    'Position',[0.5 0.1 0.28 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', '1', ...
    'Units','normalized',...
    'ToolTipString', 'Start of sweep number interval to analyze (previous sweeps will not be considered)', ...
    'Position',[0.78 0.1 0.1 0.07], ...
    'Tag', 'autoAPsweepintervalstartedit');
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', 'Inf', ...
    'Units','normalized',...
    'ToolTipString', 'End of sweep number interval to analyze (later sweeps will not be considered)', ...
    'Position',[0.88 0.1 0.1 0.07], ...
    'Tag', 'autoAPsweepintervalendedit');
uicontrol(h0, ...
    'Style', 'text', ...
    'String', 'PMT channel to analyze:', ...
    'Units','normalized',...
    'Position',[0.5 0.02 0.38 0.07], ...
    'BackgroundColor', a);
uicontrol(h0, ...
    'Style', 'edit', ...
    'String', '1', ...
    'Units','normalized',...
    'ToolTipString', 'PMT channel to open from the TIF file for analysis', ...
    'Position',[0.88 0.02 0.1 0.07], ...
    'Tag', 'autoAPpmtchanneledit');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function startAPselection(obj, event) %Sub-subfunction of the AP Selector
userdata=get(findobj('Tag', 'readwindow'), 'UserData');
if get(findobj('Tag', 'selectoneapcheckbox'), 'Value')==1
    userdata.selectedAPssweep=[];
    userdata.selectedAPsnumber=[];
    userdata.selectedAPsindex=[];
    userdata.selectedAPspeakindex=[];
    userdata.selectedAPs=[];
    userdata.selectedAPsmean=[];
    userdata.lines=[];
    userdata.linestime=[];
    userdata.selectedAPsimage=[];
    userdata.selectedAPsimagemean=[];
    userdata.synchedchan=[];
    userdata.synchedchanevents=[];
    selection=[];
    selection2=[];
    if get(findobj('Tag', 'synchronizechannelcheckbox'), 'Value')==1
        chan=get(findobj('Tag', 'synchronizechannelpopup'), 'Value');
    end
    close(findobj('Tag', 'apbasewindow'));
    set(findobj('Tag', 'startAPselectionbutton'), 'String', 'Continue ...');
    apfinderwindow=str2double(get(findobj('Tag', 'windowaroundedit'), 'String'))*userdata.samplerate/1000;
    windowbefore=str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))*userdata.samplerate/1000;
    windowafter=str2double(get(findobj('Tag', 'windowafteredit'), 'String'))*userdata.samplerate/1000;
    whileclause=0;
    while whileclause==0
        axes(findobj('Tag', 'dataaxes'));
        data=userdata.datamat(:,str2double(get(findobj('Tag', 'sweepedit'), 'String')));
        if get(findobj('Tag', 'synchronizechannelcheckbox'), 'Value')==1
            data2=userdata.datamatchan{chan}(:,str2double(get(findobj('Tag', 'sweepedit'), 'String')));
        end
        [x,y,button]=ginput(1);
        if button==1
            userdata.selectedAPssweep=[userdata.selectedAPssweep str2double(get(findobj('Tag', 'sweepedit'), 'String'))];
            x=round(x).*userdata.samplerate./1000;
            userdata.selectedAPsnumber=[userdata.selectedAPsnumber; length(x)];
            set(findobj('Tag', 'apsselectedtext'), 'String', num2str(str2double(get(findobj('Tag', 'apsselectedtext'), 'String'))+length(x)));
            index=find(data(x-apfinderwindow:x+apfinderwindow)==max(data(x-apfinderwindow:x+apfinderwindow)));
            index=index(1); %This is to get rid of the multiple points found in case of signal clipping
            index=x-apfinderwindow+index-1;
            userdata.selectedAPspeakindex=[userdata.selectedAPspeakindex index];
            selection=[selection data(index-windowbefore:index+windowafter)];
            if get(findobj('Tag', 'synchronizechannelcheckbox'), 'Value')==1
                selection2=[selection2 data2(index-windowbefore:index+windowafter)];
                userdata.synchedchan=[userdata.synchedchan data2];
            end
            userdata.selectedAPsindex=[userdata.selectedAPsindex index-windowbefore];
        end
        if str2double(get(findobj('Tag', 'sweepedit'), 'String'))==size(userdata.datamat,2)
            whileclause=1;
        else
            next;
        end
    end
    userdata.selectedAPs=selection;
    if get(findobj('Tag', 'synchronizechannelcheckbox'), 'Value')==1
        userdata.synchedchanevents=selection2;
    end
    set(findobj('Tag', 'readwindow'), 'UserData', userdata);
    assignin('base', 'userdata', userdata);
    set(findobj('Tag', 'startAPselectionbutton'), 'String', 'Start AP Selection');
    selectionDone;
else
    if strcmp('Start AP Selection', get(findobj('Tag', 'startAPselectionbutton'), 'String'))
        userdata.selectedAPssweep=[];
        userdata.selectedAPsnumber=[];
        userdata.selectedAPsindex=[];
        userdata.selectedAPspeakindex=[];
        userdata.selectedAPs=[];
        userdata.selectedAPsmean=[];
        userdata.lines=[];
        userdata.linestime=[];
        userdata.selectedAPsimage=[];
        userdata.selectedAPsimagemean=[];
        close(findobj('Tag', 'apbasewindow'));
        set(findobj('Tag', 'startAPselectionbutton'), 'String', 'Continue ...');
        axes(findobj('Tag', 'dataaxes'));
        data=userdata.datamat(:,str2double(get(findobj('Tag', 'sweepedit'), 'String')));
        userdata.selectedAPssweep=[userdata.selectedAPssweep str2double(get(findobj('Tag', 'sweepedit'), 'String'))];
        apfinderwindow=str2double(get(findobj('Tag', 'windowaroundedit'), 'String'))*userdata.samplerate/1000;
        windowbefore=str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))*userdata.samplerate/1000;
        windowafter=str2double(get(findobj('Tag', 'windowafteredit'), 'String'))*userdata.samplerate/1000;
        [x,y]=ginput;
        x=round(x).*userdata.samplerate./1000;
        userdata.selectedAPsnumber=[userdata.selectedAPsnumber; length(x)];
        set(findobj('Tag', 'apsselectedtext'), 'String', num2str(str2double(get(findobj('Tag', 'apsselectedtext'), 'String'))+length(x)));
        selection=[];
        for i=1:length(x)
            index=find(data(x(i)-apfinderwindow:x(i)+apfinderwindow)==max(data(x(i)-apfinderwindow:x(i)+apfinderwindow)));
            index=index(1); %This is to get rid of the multiple points found in case of signal clipping
            index=x(i)-apfinderwindow+index-1;
            userdata.selectedAPspeakindex=[userdata.selectedAPspeakindex index];
            %The following code zero-pads the selected Action potential or
            %event in case the windows before and after exceed the
            %dimensions of the available sweeps
            if index-windowbefore<1 && index+windowafter>length(data)
                c=[zeros(abs(index-windowbefore)+1,1); data(1:end); zeros(index+windowafter-length(data),1)];
            elseif index-windowbefore<1
                c=[zeros(abs(index-windowbefore)+1,1); data(1:index+windowafter)];
            elseif index+windowafter>length(data)
                c=[data(index-windowbefore:end); zeros(index+windowafter-length(data),1)];
            else
                c=data(index-windowbefore:index+windowafter);
            end
            selection=[selection c];
            userdata.selectedAPsindex=[userdata.selectedAPsindex index-windowbefore];
        end
        userdata.selectedAPs=selection;
    elseif strcmp('Continue ...', get(findobj('Tag', 'startAPselectionbutton'), 'String'))
        axes(findobj('Tag', 'dataaxes'));
        data=userdata.datamat(:,str2double(get(findobj('Tag', 'sweepedit'), 'String')));
        userdata.selectedAPssweep=[userdata.selectedAPssweep str2double(get(findobj('Tag', 'sweepedit'), 'String'))];
        apfinderwindow=str2double(get(findobj('Tag', 'windowaroundedit'), 'String'))*userdata.samplerate/1000;
        windowbefore=str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))*userdata.samplerate/1000;
        windowafter=str2double(get(findobj('Tag', 'windowafteredit'), 'String'))*userdata.samplerate/1000;
        [x,y]=ginput;
        x=round(x).*userdata.samplerate./1000;
        userdata.selectedAPsnumber=[userdata.selectedAPsnumber; length(x)];
        set(findobj('Tag', 'apsselectedtext'), 'String', num2str(str2double(get(findobj('Tag', 'apsselectedtext'), 'String'))+length(x)));
        selection=userdata.selectedAPs;
        for i=1:length(x)
            index=find(data(x(i)-apfinderwindow:x(i)+apfinderwindow)==max(data(x(i)-apfinderwindow:x(i)+apfinderwindow)));
            index=index(1); %This is to get rid of the multiple points found in case of signal clipping
            index=x(i)-apfinderwindow+index-1;
            userdata.selectedAPspeakindex=[userdata.selectedAPspeakindex index];
            %The following code zero-pads the selected Action potential or
            %event in case the windows before and after exceed the
            %dimensions of the available sweeps
            if index-windowbefore<1 && index+windowafter>length(data)
                c=[zeros(abs(index-windowbefore)+1,1); data(1:end); zeros(index+windowafter-length(data),1)];
            elseif index-windowbefore<1
                c=[zeros(abs(index-windowbefore)+1,1); data(1:index+windowafter)];
            elseif index+windowafter>length(data)
                c=[data(index-windowbefore:end); zeros(index+windowafter-length(data),1)];
            else
                c=data(index-windowbefore:index+windowafter);
            end
            selection=[selection c];
            userdata.selectedAPsindex=[userdata.selectedAPsindex index-windowbefore];
        end
        userdata.selectedAPs=selection;
    end
    set(findobj('Tag', 'readwindow'), 'UserData', userdata);
    assignin('base', 'userdata', userdata);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selectionDone(obj, event) %Sub-subfunction of the AP Selector
userdata=get(findobj('Tag', 'readwindow'), 'UserData');
if isempty(userdata.selectedAPs)
    errordlg('No Action Potentials selected', 'AP selector error');
    set(findobj('Tag', 'startAPselectionbutton'), 'String', 'Start AP Selection');
else
    close(findobj('Tag', 'apbasewindow'));
    close(findobj('Tag', 'aptimewindow'));
    figure(...
        'Units','normalized',...
        'Name','AP selector',...
        'NumberTitle','off',...
        'MenuBar', 'none', ...
        'Position',[0.62 0.23 0.2 0.2], ...
        'Tag','apbasewindow');
    plot(mean(userdata.selectedAPs, 2));
    title('Select Baseline for AP averaging');
    [x,y]=ginput(2);
    baselineindex=x;
    base=median(userdata.selectedAPs(round(x(1)):round(x(2)), :));
    userdata.selectedAPsmean=mean(userdata.selectedAPs-repmat(base, size(userdata.selectedAPs, 1), 1),2);
    plot(1000/userdata.samplerate:1000/userdata.samplerate:1000*size(userdata.selectedAPs, 1)/userdata.samplerate, userdata.selectedAPsmean);
    set(gca, 'XLim', ...
        [0 str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))+str2double(get(findobj('Tag', 'windowafteredit'), 'String'))+1]);
    title(['Average of ', num2str(size(userdata.selectedAPs, 2)), ' events']);
    set(findobj('Tag', 'startAPselectionbutton'), 'String', 'Start AP Selection');
    set(findobj('Tag', 'readwindow'), 'UserData', userdata);
    
    %Imaging sync for TIF files
    if get(findobj('Tag', 'synchronizetifcheckbox'), 'Value')==1
        pathname=textread([matlabroot, '\work\Physiology\tif_directory_name.erv'], '%s', 'whitespace', '');
        pathname=[pathname{:}, '\'];
        h=waitbar(0, ['Opening .tif file 0 out of ', num2str(length(userdata.selectedAPssweep)), '.']);
        userdata.lines=[];
        h0 = figure(...
            'Name','AP selector',...
            'NumberTitle','off',...
            'MenuBar', 'none');
        warning off all
        for i=1:length(userdata.selectedAPssweep)
            waitbar(i/length(userdata.selectedAPssweep), h, ['Opening .tif file ', num2str(i), ' out of ', num2str(length(userdata.selectedAPssweep)), '.']);
            if fopen([pathname, userdata.filename(1:8), '\', num2str(userdata.selectedAPssweep(i)), '.tif'])>0
                [x,map] = imread([pathname, userdata.filename(1:8), '\', num2str(userdata.selectedAPssweep(i)), '.tif']);
                data(:,:,i)=double(x);
                imshow(data(:,:,i), map);
                [x,y]=ginput(2);
                x=round(x);
                userdata.lines=[userdata.lines sum(data(:,x(1):x(2),i), 2)];
            end
        end
        close(h)
        close(h0)
        ili=str2double(get(findobj('Tag', 'iliedit'), 'String'));
        userdata.linestime=ili:ili:ili*size(userdata.lines,1);
        indexconversion=round((userdata.selectedAPsindex./userdata.samplerate.*1000)./ili);
        baselineindex=round((baselineindex./userdata.samplerate.*1000)./ili);
        imagewindow=round(str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))+str2double(get(findobj('Tag', 'windowafteredit'), 'String')))/ili;
        imagenumber=[];
        for i=1:length(userdata.selectedAPsnumber)
            imagenumber=[imagenumber; repmat(i, userdata.selectedAPsnumber(i), 1)];
        end
        for i=1:length(indexconversion)
            userdata.selectedAPsimage=[userdata.selectedAPsimage userdata.lines(indexconversion(i):indexconversion(i)+imagewindow,imagenumber(i))];
        end
        userdata.selectedAPsimagemean=mean(userdata.selectedAPsimage,2);
        userdata.selectedAPsimagemean=(userdata.selectedAPsimagemean-median(userdata.selectedAPsimagemean(baselineindex(1):baselineindex(2))))./median(userdata.selectedAPsimagemean(baselineindex(1):baselineindex(2)));
        close(findobj('Tag', 'apbasewindow'));
        close(findobj('Tag', 'aptimewindow'));
        figure(...
            'Units','normalized',...
            'Name','AP baseline selector',...
            'NumberTitle','off',...
            'MenuBar', 'none', ...
            'Position',[0.62 0.23 0.2 0.48], ...
            'Tag','apbasewindow');
        subplot(2,1,1)
        plot(1000/userdata.samplerate:1000/userdata.samplerate:1000*size(userdata.selectedAPs, 1)/userdata.samplerate, userdata.selectedAPsmean);
        set(gca, 'XLim', [0 str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))+str2double(get(findobj('Tag', 'windowafteredit'), 'String'))+1]);
        title(['Average physiology and imaging. N=', num2str(sum(userdata.selectedAPsnumber))]);
        ylabel('Normalized membrane voltage');
        subplot(2,1,2)
        plot(ili:ili:ili*size(userdata.selectedAPsimage,1), userdata.selectedAPsimagemean);
        set(gca, 'XLim', [0 str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))+str2double(get(findobj('Tag', 'windowafteredit'), 'String'))+1]);
        ylabel('Normalized Secong Harmonic signal');
        xlabel('Time in ms');
    end
    
    %Imaging sync for IMGDAT (ERV photon counter) files
    if get(findobj('Tag', 'synchronizeimgdatcheckbox'), 'Value')==1
        userdata.selectedindex=userdata.selectedAPssweep;
        set(findobj('Tag', 'readwindow'), 'UserData', userdata);
        selectimgdats;
        imgdata=evalin('caller', 'imgdata');
        windowbefore=str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))*userdata.samplerate/1000;
        windowafter=str2double(get(findobj('Tag', 'windowafteredit'), 'String'))*userdata.samplerate/1000;
        window=(-windowbefore:1:windowafter)';
        selection=[];
        k=0;
        for i=1:length(userdata.selectedAPssweep)
            data=imgdata.selected(:, i);
            peaks=userdata.selectedAPspeakindex(k+1:k+userdata.selectedAPsnumber(i));
            k=k+userdata.selectedAPsnumber(i);
            windows=repmat(window, 1, length(peaks));
            peaks=repmat(peaks, length(window), 1);
            peaks=peaks+windows;
            selection=[selection data(peaks)];
        end
        userdata.selectedAPsimage=selection;
        close(findobj('Tag', 'apbasewindow'));
        close(findobj('Tag', 'aptimewindow'));
        h0 = figure(...
            'Units','normalized',...
            'Name','AP time windows selector',...
            'NumberTitle','off',...
            'MenuBar', 'none', ...
            'Units','normalized',...
            'Position',[0.62 0.43 0.2 0.2], ...
            'Tag','aptimewindow');
        uicontrol(h0, ...
            'Style', 'edit', ...
            'String', '150', ...
            'Callback', @changeWindow,...
            'Units','normalized',...
            'Position',[0.2 0.925 0.15 0.07], ...
            'ToolTipString', 'Start of the pre-AP window in ms before the AP peak', ...
            'Tag', 'preapwindowstartedit');
        uicontrol(h0, ...
            'Style', 'edit', ...
            'String', '20', ...
            'Units','normalized',...
            'Callback', @changeWindow,...
            'Position',[0.4 0.925 0.15 0.07], ...
            'ToolTipString', 'End of the pre-AP window in ms before the AP peak', ...
            'Tag', 'preapwindowendedit');
        uicontrol(h0, ...
            'Style', 'edit', ...
            'String', '50', ...
            'Units','normalized',...
            'Callback', @changeWindow,...
            'Position',[0.6 0.925 0.15 0.07], ...
            'ToolTipString', 'End of the AP window in ms after the AP peak', ...
            'Tag', 'apwindowendedit');
        uicontrol(h0, ...
            'String', 'Sync.', ...
            'Units','normalized',...
            'Callback', @synchronizeIMGDATs,...
            'Position',[0.8 0.925 0.15 0.07], ...
            'ToolTipString', 'Synchronize IMGDAT file');
        preapwindowstart=-str2double(get(findobj('Tag', 'preapwindowstartedit'), 'String'));
        preapwindowend=-str2double(get(findobj('Tag', 'preapwindowendedit'), 'String'));
        apwindowend=str2double(get(findobj('Tag', 'apwindowendedit'), 'String'));
        plot((1:size(mean(userdata.selectedAPs, 2),1))./(userdata.samplerate/1000), mean(userdata.selectedAPs, 2));
        xlim([0 size(mean(userdata.selectedAPs, 2),1)/(userdata.samplerate/1000)]);
        hold on
        line([(windowbefore/(userdata.samplerate/1000))+preapwindowstart (windowbefore/(userdata.samplerate/1000))+preapwindowstart], get(gca, 'YLim'), ...
            'Color', 'k', 'Tag', 'line1');
        line([(windowbefore/(userdata.samplerate/1000))+preapwindowend (windowbefore/(userdata.samplerate/1000))+preapwindowend], get(gca, 'YLim'), ...
            'Color', 'k', 'Tag', 'line2');
        line([(windowbefore/(userdata.samplerate/1000))+apwindowend (windowbefore/(userdata.samplerate/1000))+apwindowend], get(gca, 'YLim'), ...
            'Color', 'k', 'Tag', 'line3');
        set(findobj('Tag', 'readwindow'), 'UserData', userdata);
        assignin('base', 'userdata', userdata);
        synchronizeIMGDATs;
    end
    
    
    %Imaging sync for PMT signal acquired together with the physiology as a separate channel
    if get(findobj('Tag', 'synchronizechannelcheckbox'), 'Value')==1
        chan=get(findobj('Tag', 'synchronizechannelpopup'), 'Value');
        userdata.selectedindex=userdata.selectedAPssweep;
        set(findobj('Tag', 'readwindow'), 'UserData', userdata);
        windowbefore=str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))*userdata.samplerate/1000;
        windowafter=str2double(get(findobj('Tag', 'windowafteredit'), 'String'))*userdata.samplerate/1000;
        window=(-windowbefore:1:windowafter)';
        selection=[];
        k=0;
        for i=1:length(userdata.selectedAPssweep)
            data=userdata.datamatchan{chan}(:, userdata.selectedAPssweep(i));
            peaks=userdata.selectedAPspeakindex(k+1:k+userdata.selectedAPsnumber(i));
            k=k+userdata.selectedAPsnumber(i);
            windows=repmat(window, 1, length(peaks));
            peaks=repmat(peaks, length(window), 1);
            peaks=peaks+windows;
            selection=[selection data(peaks)];
        end
        userdata.selectedAPsimage=selection;
        close(findobj('Tag', 'apbasewindow'));
        close(findobj('Tag', 'aptimewindow'));
        if get(findobj('Tag', 'selectoneapcheckbox'), 'Value')==1
            preapwindowstart=-19;
            preapwindowend=-10;
            apwindowend=20;
        else
            preapwindowstart=-150;
            preapwindowend=-20;
            apwindowend=50;
        end
        h0 = figure(...
            'Units','normalized',...
            'Name','AP time windows selector',...
            'NumberTitle','off',...
            'MenuBar', 'none', ...
            'Units','normalized',...
            'Position',[0.62 0.43 0.2 0.2], ...
            'Tag','aptimewindow');
        uicontrol(h0, ...
            'Style', 'edit', ...
            'String', num2str(-preapwindowstart), ...
            'Callback', @changeWindow,...
            'Units','normalized',...
            'Position',[0.2 0.925 0.15 0.07], ...
            'ToolTipString', 'Start of the pre-AP window in ms before the AP peak', ...
            'Tag', 'preapwindowstartedit');
        uicontrol(h0, ...
            'Style', 'edit', ...
            'String', num2str(-preapwindowend), ...
            'Units','normalized',...
            'Callback', @changeWindow,...
            'Position',[0.4 0.925 0.15 0.07], ...
            'ToolTipString', 'End of the pre-AP window in ms before the AP peak', ...
            'Tag', 'preapwindowendedit');
        uicontrol(h0, ...
            'Style', 'edit', ...
            'String', num2str(apwindowend), ...
            'Units','normalized',...
            'Callback', @changeWindow,...
            'Position',[0.6 0.925 0.15 0.07], ...
            'ToolTipString', 'End of the AP window in ms after the AP peak', ...
            'Tag', 'apwindowendedit');
        uicontrol(h0, ...
            'String', 'Sync.', ...
            'Units','normalized',...
            'Callback', @synchronizeCH,...
            'Position',[0.8 0.925 0.15 0.07], ...
            'ToolTipString', 'Synchronize channel');
        plot((1:size(mean(userdata.selectedAPs, 2),1))./(userdata.samplerate/1000), mean(userdata.selectedAPs, 2));
        xlim([0 size(mean(userdata.selectedAPs, 2),1)/(userdata.samplerate/1000)]);
        hold on
        line([(windowbefore/(userdata.samplerate/1000))+preapwindowstart (windowbefore/(userdata.samplerate/1000))+preapwindowstart], get(gca, 'YLim'), ...
            'Color', 'k', 'Tag', 'line1');
        line([(windowbefore/(userdata.samplerate/1000))+preapwindowend (windowbefore/(userdata.samplerate/1000))+preapwindowend], get(gca, 'YLim'), ...
            'Color', 'k', 'Tag', 'line2');
        line([(windowbefore/(userdata.samplerate/1000))+apwindowend (windowbefore/(userdata.samplerate/1000))+apwindowend], get(gca, 'YLim'), ...
            'Color', 'k', 'Tag', 'line3');
        set(findobj('Tag', 'readwindow'), 'UserData', userdata);
        assignin('base', 'userdata', userdata);
        synchronizeCH;
    end
    set(findobj('Tag', 'readwindow'), 'UserData', userdata);
    assignin('base', 'userdata', userdata);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changeWindow(obj, event) %Sub-subfunction of the AP Selector
userdata=get(findobj('Tag', 'readwindow'), 'UserData');
windowbefore=str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))*userdata.samplerate/1000;
preapwindowstart=-str2double(get(findobj('Tag', 'preapwindowstartedit'), 'String'));
preapwindowend=-str2double(get(findobj('Tag', 'preapwindowendedit'), 'String'));
apwindowend=str2double(get(findobj('Tag', 'apwindowendedit'), 'String'));
set(findobj('Tag', 'line1'), 'Visible', 'off');
set(findobj('Tag', 'line2'), 'Visible', 'off');
set(findobj('Tag', 'line3'), 'Visible', 'off');
line([(windowbefore/(userdata.samplerate/1000))+preapwindowstart (windowbefore/(userdata.samplerate/1000))+preapwindowstart], get(gca, 'YLim'), ...
    'Color', 'k', 'Tag', 'line1');
line([(windowbefore/(userdata.samplerate/1000))+preapwindowend (windowbefore/(userdata.samplerate/1000))+preapwindowend], get(gca, 'YLim'), ...
    'Color', 'k', 'Tag', 'line2');
line([(windowbefore/(userdata.samplerate/1000))+apwindowend (windowbefore/(userdata.samplerate/1000))+apwindowend], get(gca, 'YLim'), ...
    'Color', 'k', 'Tag', 'line3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function synchronizeIMGDATs(obj, event) %Sub-subfunction of the AP Selector
userdata=get(findobj('Tag', 'readwindow'), 'UserData');
imgdata=evalin('base', 'imgdata');
windowbefore=str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))*userdata.samplerate/1000;
preapwindowstart=-str2double(get(findobj('Tag', 'preapwindowstartedit'), 'String'))*userdata.samplerate/1000;
preapwindowend=-str2double(get(findobj('Tag', 'preapwindowendedit'), 'String'))*userdata.samplerate/1000;
apwindowend=str2double(get(findobj('Tag', 'apwindowendedit'), 'String'))*userdata.samplerate/1000;
data=userdata.selectedAPsimage;
imgdata.preAPcount=sum(data(windowbefore+preapwindowstart:windowbefore+preapwindowend, :))./(windowbefore+preapwindowend-windowbefore-preapwindowstart);
imgdata.APcount=sum(data(windowbefore+preapwindowend:windowbefore+apwindowend, :))./(windowbefore+apwindowend-windowbefore-preapwindowend);
imgdata.abspreAPcount=sum(data(windowbefore+preapwindowstart:windowbefore+preapwindowend, :));
imgdata.absAPcount=sum(data(windowbefore+preapwindowend:windowbefore+apwindowend, :));
if isempty(imgdata.basecount)
    baselinesize=windowbefore+preapwindowend-windowbefore-preapwindowstart;
    close(findobj('Tag', 'apbasewindow'));
    figure(...
        'Units','normalized',...
        'Name','AP time windows selector',...
        'NumberTitle','off',...
        'MenuBar', 'none', ...
        'Units','normalized',...
        'Position',[0.62 0.23 0.2 0.2], ...
        'Tag','apbasewindow');
    warning off all
    for i=1:length(userdata.selectedAPssweep)
        plot(userdata.datamat(:,userdata.selectedAPssweep(i)));
        title('Select start of baselines for IMGDAT counts');
        [x,y]=ginput(userdata.selectedAPsnumber(i));
        for j=1:length(x)
            imgdata.basecount=[imgdata.basecount sum(imgdata.selected(x(j):x(j)+baselinesize, i))/baselinesize];
            imgdata.absbasecount=[imgdata.absbasecount sum(imgdata.selected(x(j):x(j)+baselinesize, i))];
        end
    end
end
assignin('base', 'imgdata', imgdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function synchronizeCH(obj, event) %Sub-subfunction of the AP Selector
userdata=get(findobj('Tag', 'readwindow'), 'UserData');
chan=get(findobj('Tag', 'synchronizechannelpopup'), 'Value');
channelthreshold=str2double(get(findobj('Tag', 'channelthresholdedit'), 'String'));
windowbefore=str2double(get(findobj('Tag', 'windowbeforeedit'), 'String'))*userdata.samplerate/1000;
preapwindowstart=-str2double(get(findobj('Tag', 'preapwindowstartedit'), 'String'))*userdata.samplerate/1000;
preapwindowend=-str2double(get(findobj('Tag', 'preapwindowendedit'), 'String'))*userdata.samplerate/1000;
apwindowend=str2double(get(findobj('Tag', 'apwindowendedit'), 'String'))*userdata.samplerate/1000;
data=userdata.selectedAPsimage;
data=data-channelthreshold;
data(data<0)=0;
if evalin('base', 'exist(''imgdata'')')
    imgdata=evalin('base', 'imgdata');
end
imgdata.preAPcount=sum(data(windowbefore+preapwindowstart:windowbefore+preapwindowend, :))./(windowbefore+preapwindowend-windowbefore-preapwindowstart);
imgdata.APcount=sum(data(windowbefore+preapwindowend:windowbefore+apwindowend, :))./(windowbefore+apwindowend-windowbefore-preapwindowend);
imgdata.abspreAPcount=sum(data(windowbefore+preapwindowstart:windowbefore+preapwindowend, :));
imgdata.absAPcount=sum(data(windowbefore+preapwindowend:windowbefore+apwindowend, :));
if evalin('base', 'exist(''imgdata'')')
    if evalin('base', 'isempty(imgdata.basecount)')
        baselinesize=windowbefore+preapwindowend-windowbefore-preapwindowstart;
        close(findobj('Tag', 'apbasewindow'));
        figure(...
            'Units','normalized',...
            'Name','AP time windows selector',...
            'NumberTitle','off',...
            'MenuBar', 'none', ...
            'Units','normalized',...
            'Position',[0.62 0.23 0.2 0.2], ...
            'Tag','apbasewindow');
        warning off all
        for i=1:length(userdata.selectedAPssweep)
            plot(userdata.datamat(:,userdata.selectedAPssweep(i)));
            title('Select start of baselines for PMT signal');
            [x,y]=ginput(userdata.selectedAPsnumber(i));
            for j=1:length(x)
                data=userdata.datamatchan{chan}(x(j):x(j)+baselinesize, userdata.selectedAPssweep(i));
                data=data-channelthreshold;
                data(data<0)=0;
                imgdata.basecount=[imgdata.basecount sum(data)/baselinesize];
                imgdata.absbasecount=[imgdata.absbasecount sum(data)];
            end
        end
    end
else
    imgdata.basecount=[];
    imgdata.absbasecount=[];
    baselinesize=windowbefore+preapwindowend-windowbefore-preapwindowstart;
    close(findobj('Tag', 'apbasewindow'));
    figure(...
        'Units','normalized',...
        'Name','AP time windows selector',...
        'NumberTitle','off',...
        'MenuBar', 'none', ...
        'Units','normalized',...
        'Position',[0.62 0.23 0.2 0.2], ...
        'Tag','apbasewindow');
    warning off all
    for i=1:length(userdata.selectedAPssweep)
        plot(userdata.datamat(:,userdata.selectedAPssweep(i)));
        title('Select start of baselines for IMGDAT counts');
        [x,y]=ginput(userdata.selectedAPsnumber(i));
        for j=1:length(x)
            data=userdata.datamatchan{chan}(x(j):x(j)+baselinesize, userdata.selectedAPssweep(i));
            data=data-channelthreshold;
            data(data<0)=0;
            imgdata.basecount=[imgdata.basecount sum(data)/baselinesize];
            imgdata.absbasecount=[imgdata.absbasecount sum(data)];
        end
    end
end
assignin('base', 'imgdata', imgdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function autoAPselection(obj, event) %Sub-subfunction of the AP Selector
close(findobj('Tag', 'apbasewindow'));
close(findobj('Tag', 'aptimewindow'));

set(findobj('Tag', 'plotall-bradio'), 'Value', 1);
figure(findobj('Tag', 'readwindow'));
allminusb;
set(findobj('Tag', 'autoAPamplitudetext'), 'String', '?');
set(findobj('Tag', 'autoAPwindowtext'), 'String', '? - ?');
set(findobj('Tag', 'autoAPdetectedtext'), 'String', '?');

%User threshold and time window selection
set(findobj('Tag', 'autoAPtext'), 'String', 'Select Voltage Detection Threshold');
[x,amplitudethreshold]=ginput(1);
set(findobj('Tag', 'autoAPamplitudetext'), 'String', num2str(round(amplitudethreshold)));
set(findobj('Tag', 'autoAPtext'), 'String', 'Select Detection Time Window');
[timewindow,y]=ginput(2);
set(findobj('Tag', 'autoAPtext'), 'String', 'Aligning Action Potentials');
timewindow=round(timewindow);
set(findobj('Tag', 'autoAPwindowtext'), 'String', [num2str(min(timewindow)), ' - ', num2str(max(timewindow))]);

%detect APs
userdata=get(findobj('Tag', 'readwindow'), 'UserData');
userdata.selectedAPs=userdata.datamatbase(min(timewindow)*userdata.samplerate/1000:max(timewindow)*userdata.samplerate/1000,:);
userdata.selectedAPssweep=find(sum(userdata.selectedAPs>amplitudethreshold));
userdata.selectedAPssweep=userdata.selectedAPssweep(str2double(get(findobj('Tag', 'autoAPsweepintervalstartedit'), 'String'))<=userdata.selectedAPssweep & userdata.selectedAPssweep<=str2double(get(findobj('Tag', 'autoAPsweepintervalendedit'), 'String')));
userdata.selectedAPs=userdata.selectedAPs(:,userdata.selectedAPssweep);
userdata.selectedAPsnumber=ones(length(userdata.selectedAPssweep),1);
set(findobj('Tag', 'autoAPdetectedtext'), 'String', num2str(length(userdata.selectedAPssweep)));

%Aligns APs at the peak
userdata.selectedAPsindex=[];
[userdata.selectedAPspeak, index]=max(userdata.selectedAPs);
userdata.selectedAPspeakindex=index+min(timewindow)*userdata.samplerate/1000-1;
a=userdata.selectedAPspeakindex-min(userdata.selectedAPspeakindex)+1;
b=userdata.selectedAPspeakindex+userdata.sweeplength-max(userdata.selectedAPspeakindex);
aps=[];
for i=1:length(a)
    aps=[aps userdata.datamatbase(a(i):b(i), userdata.selectedAPssweep(i))];
end
userdata.selectedAPsmean=mean(aps,2);
%Plots the mean AP
figure
set(gcf, 'Name', 'AP Selector', 'Tag', 'apbasewindow');
plot(userdata.timescale(1:length(userdata.selectedAPsmean)), userdata.selectedAPsmean);
title('Mean Action Potential');
xlabel('Time in ms');
ylabel('Membrane potential in mV (baseline subtracted)');

%Fluoview TIF file synchronization
if get(findobj('Tag', 'synchronizetifcheckbox'), 'Value')==1
    set(findobj('Tag', 'autoAPtext'), 'String', 'Opening TIF files');
    pathname=textread([matlabroot, '\work\Physiology\tif_directory_name.erv'], '%s', 'whitespace', '');
    pathname=[pathname{:}, '\'];
    a=num2str(length(userdata.selectedAPssweep));
    h=waitbar(0, ['Opening .tif file 0 out of ', a, '.']);
    warning off all
    filename=get(findobj('Tag', 'autoAPfilenameedit'), 'String');
    filenamedigits=get(findobj('Tag', 'autoAPfilenamedigitsedit'), 'String');
    %Opens the TIF files. The selected sweep number -1 is used because Fluoview starts numbering from 0
    for i=1:length(userdata.selectedAPssweep)
        waitbar(i/length(userdata.selectedAPssweep), h, ['Opening .tif file ', num2str(i), ' out of ', a, '.']);
        if fopen([pathname, userdata.filename(1:8), '\', filename, '-', num2str(userdata.selectedAPssweep(i)-1, ['%0', filenamedigits, 'd']), '.tif'])>0
            fclose('all');
            [x,map] = imread([pathname, userdata.filename(1:8), '\', filename, '-', num2str(userdata.selectedAPssweep(i)-1, ['%0', filenamedigits, 'd']), '.tif'], str2double(get(findobj('Tag', 'autoAPpmtchanneledit'), 'String')));
            data(:,:,i)=double(x);
        end
    end
    close(h);
    %Opens the mean image to select the feature/s to analyze
    set(findobj('Tag', 'autoAPtext'), 'String', 'Select image features');
    figure
    set(gcf, 'Name', 'Image Feature Selector', 'Tag', 'aptimewindow');
    imshow(mean(data,3), map);
    [x, y]=ginput;
    close(findobj('Tag', 'aptimewindow'));
    x=reshape(x, 2, length(x)/2)';
    if x(1,1)<1
        x(1,1)=1;
    end
    if x(end,2)>size(data,2)
        x(end,2)=size(data,2);
    end
    %Extracts the selected features from the images
    lines=[];
    for i=1:size(x,1)
        lines{i}=data(:,x(i,1):x(i,2),:);
    end
    %Aligns the images to the AP peak and uses the selected operation per image (mean, median, sum, or variance)
    operation=get(findobj('Tag', 'autoAPoperationpopup'), 'Value');
    line=[];
    for i=1:size(lines,2)
        for j=1:size(lines{i},3)
            if operation==1
                line(:,j,i)=resample(mean(lines{i}(:,:,j),2), userdata.samplerate, 1/str2double(get(findobj('Tag', 'iliedit'), 'string'))*1000);
                operationtext='Mean';
            elseif operation==2
                line(:,j,i)=resample(median(lines{i}(:,:,j),2), userdata.samplerate, 1/str2double(get(findobj('Tag', 'iliedit'), 'string'))*1000);
                operationtext='Median';
            elseif operation==3
                line(:,j,i)=resample(sum(lines{i}(:,:,j),2), userdata.samplerate, 1/str2double(get(findobj('Tag', 'iliedit'), 'string'))*1000);
                operationtext='Sum';
            elseif operation==4
                line(:,j,i)=resample(var(lines{i}(:,:,j),0,2), userdata.samplerate, 1/str2double(get(findobj('Tag', 'iliedit'), 'string'))*1000);
                operationtext='Variance';
            end
        end
    end
    line=[zeros(str2double(get(findobj('Tag', 'autoAPimagedelayedit'), 'String'))*userdata.samplerate/1000, size(line,2), size(line,3)); line];
    a=userdata.selectedAPspeakindex-min(userdata.selectedAPspeakindex)+1;
    b=userdata.selectedAPspeakindex+size(line,1)-max(userdata.selectedAPspeakindex);
    lineaps=[];
    for i=1:length(a)
        lineaps=[lineaps line(a(i):b(i), i, :)];
    end
    close(findobj('Tag', 'apbasewindow'));
    figure('Units', 'normalized', ...
        'Position', [0.1 0.03 0.3 0.9], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'Tag', 'apbasewindow');
    subplot(size(lines,2)+1, 1, 1);
    plot(userdata.selectedAPsmean(1:min([length(userdata.selectedAPsmean) size(lineaps,1)])));
    title('Select Baseline and limits for the traces');
    xlim([0 size(lineaps,1)]);
    ylim([min(userdata.selectedAPsmean) max(userdata.selectedAPsmean)]);
    for i=1:size(lines,2)
        subplot(size(lines,2)+1, 1, i+1);
        plot(mean(lineaps(:,:,i),2));
        xlim([0 size(lineaps,1)]);
    end
    %Limits and baseline selection for the Image traces.
    [x, y]=ginput(3);
    x=round(x);
    close(findobj('Tag', 'apbasewindow'));
    figure('Units', 'normalized', ...
        'Position', [0.1 0.03 0.3 0.9], ...
        'NumberTitle', 'off');
    subplot(size(lines,2)+1, 1, 1);
    plot(userdata.timescale(x(1):x(3)), userdata.selectedAPsmean(x(1):x(3)));
    title(['Mean Action Potential and ', operationtext, ' of selected linescan features (', userdata.filename(1:6), '-', userdata.filename(8), '). N=', num2str(length(userdata.selectedAPssweep)), '.']);
    ylabel('mV');
    xlim([userdata.timescale(x(1)) userdata.timescale(x(3))]);
    ylim([min(userdata.selectedAPsmean) max(userdata.selectedAPsmean)]);
    linesdff=[];
    a=[];
    for i=1:size(lines,2)
        subplot(size(lines,2)+1, 1, i+1);
        baseline=mean(lineaps(x(1):x(2),:,i),1);
        a=lineaps(x(1):x(3),:,i);
        baseline=repmat(baseline, [size(a,1), 1, 1]);
        a=(a-baseline)./baseline;
        linesdff(:,:,i)=a;
        plot(userdata.timescale(x(1):x(3)), mean(linesdff(:,:,i),2));
        ylabel('\DeltaF/F');
        xlim([userdata.timescale(x(1)) userdata.timescale(x(3))]);
    end
    xlabel('Time in ms.');
    userdata.selectedAPsimage=data;
    userdata.lines=lineaps;
    userdata.selectedAPsimagemean=linesdff;
end
set(findobj('Tag', 'readwindow'), 'UserData', userdata);
assignin('base', 'userdata', userdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function noise(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
userdata.noisemat=reshape(userdata.baselinemat-repmat(userdata.baseline, size(userdata.baselinemat, 1), 1), size(userdata.baselinemat,1)*size(userdata.baselinemat,2), 1);
set(findobj('Tag', 'readwindow'), 'UserData', userdata);
assignin('base', 'userdata', userdata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aligned(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
if get(findobj('Tag', 'maxradio'), 'Value')==1
    [c, index]=max(userdata.datamatbase(userdata.samplerate*str2double(get(findobj('Tag', 'winstartedit'), 'String'))/1000:userdata.samplerate*str2double(get(findobj('Tag', 'winendedit'), 'String'))/1000, :));
elseif get(findobj('Tag', 'minradio'), 'Value')==1
    [c, index]=min(userdata.datamatbase(userdata.samplerate*str2double(get(findobj('Tag', 'winstartedit'), 'String'))/1000:userdata.samplerate*str2double(get(findobj('Tag', 'winendedit'), 'String'))/1000, :));
else
    set(findobj('Tag', 'minradio'), 'Value', 1);
    set(findobj('Tag', 'maxradio'), 'Value', 0);
    set(findobj('Tag', 'meanradio'), 'Value', 0);
    set(findobj('Tag', 'medianradio'), 'Value', 0);
    [c, index]=min(userdata.datamatbase(userdata.samplerate*str2double(get(findobj('Tag', 'winstartedit'), 'String'))/1000:userdata.samplerate*str2double(get(findobj('Tag', 'winendedit'), 'String'))/1000, :));
end
index=index+userdata.samplerate*str2double(get(findobj('Tag', 'winstartedit'), 'String'))/1000-1;
c=0:userdata.sweeplength:userdata.sweeplength*size(userdata.datamat,2)-1;
index=index+c;
plusminus=round(userdata.samplerate*str2double(get(findobj('Tag', 'winplusminusedit'), 'String'))/1000);
index=repmat(index, plusminus*2+1,1);
c=-plusminus:1:plusminus;
c=repmat(c', 1, size(index,2));
index=index+c;
userdata.alignedevents=mean(userdata.datamatbase(index));
set(findobj('Tag', 'readwindow'), 'UserData', userdata);
assignin('base', 'alignedevents', userdata.alignedevents);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function batchopen(obj, event)

button=questdlg('Keep data on workspace?', '', 'Yes', 'No', 'Cancel', 'Yes');
if strcmp(button, 'Yes')
    if evalin('base', 'exist(''userdata'')')==1
        userdata=evalin('base', 'userdata');
        evalin('base', 'clear userdata');
        assignin('base', ['Ephys', userdata.filename(1:end-4)], userdata);
    end
    if evalin('base', 'exist(''tifUserData'')')==1
        userdata=evalin('base', 'tifUserData');
        evalin('base', 'clear tifUserData');
        assignin('base', ['Tif', userdata.directory_name(end-7:end)], userdata);
    end
    acq_reader('batch');
elseif strcmp(button, 'No')
    acq_reader('batch');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newfile(obj, event)

button=questdlg('Keep data on workspace?', '', 'Yes', 'No', 'Cancel', 'Yes');
if strcmp(button, 'Yes')
    if evalin('base', 'exist(''userdata'')')==1
        userdata=evalin('base', 'userdata');
        evalin('base', 'clear userdata');
        assignin('base', ['Ephys', userdata.filename(1:end-4)], userdata);
    end
    if evalin('base', 'exist(''tifUserData'')')==1
        userdata=evalin('base', 'tifUserData');
        evalin('base', 'clear tifUserData');
        assignin('base', ['Tif', userdata.directory_name(end-7:end)], userdata);
    end
    acq_reader;
elseif strcmp(button, 'No')
    acq_reader;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newdata(obj, event)

a=get(findobj('Tag', 'datapopup'), 'String');
if length(a)>1
    b=get(findobj('Tag', 'datapopup'), 'Value');
    a=a{b};
    if strcmp(a, 'Select data')
        userdata.filename='no file';
        userdata.channelpopupvis='off';
        userdata.channelpopupstr=[];
        assignin('base', 'userdata', userdata);
        set(findobj('Tag', 'readwindow'), 'UserData', userdata);
        set(findobj('Tag', 'filetext'), 'String', ['File: ', userdata.filename]);
        set(findobj('Tag', 'channeltextpopup'), 'Visible', userdata.channelpopupvis);
        set(findobj('Tag', 'channelpopup'), 'String', userdata.channelpopupstr);
        set(findobj('Tag', 'channelpopup'), 'Visible', userdata.channelpopupvis);
        delete(gca);
    else
        userdata=evalin('base', a);
        assignin('base', 'userdata', userdata);
        set(findobj('Tag', 'readwindow'), 'UserData', userdata);
        set(findobj('Tag', 'filetext'), 'String', ['File: ', userdata.filename]);
        set(findobj('Tag', 'channeltextpopup'), 'Visible', userdata.channelpopupvis);
        set(findobj('Tag', 'channelpopup'), 'String', userdata.channelpopupstr);
        set(findobj('Tag', 'channelpopup'), 'Value', 1);
        set(findobj('Tag', 'channelpopup'), 'Visible', userdata.channelpopupvis);
        if get(findobj('Tag', 'plotallradio'), 'Value')==1
            plotall;
        elseif get(findobj('Tag', 'plotall-bradio'), 'Value')==1
            allminusb;
        elseif get(findobj('Tag', 'plotoneradio'), 'Value')==1
            plotone;
        elseif get(findobj('Tag', 'plotone-bradio'), 'Value')==1
            oneminusb;
        else
            set(findobj('Tag', 'plotallradio'), 'Value', 1);
            plotall;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nextfile(obj, event)

if evalin('base', 'exist(''userdata'')')==1
    userdata=evalin('base', 'userdata');
    a=get(findobj('Tag', 'filetext'), 'String');
    if strcmp(userdata.filename, a(7:end))
    else
        button=questdlg('Keep data on workspace?', '', 'Yes', 'No', 'Cancel', 'Yes');
        
        if strcmp(button, 'Yes')
            evalin('base', 'clear userdata');
            assignin('base', ['Ephys', userdata.filename(1:end-4)], userdata);
            if evalin('base', 'exist(''tifUserData'')')==1
                userdata=evalin('base', 'tifUserData');
                evalin('base', 'clear tifUserData');
                assignin('base', ['Tif', userdata.directory_name(end-7:end)], userdata);
            end
            acq_reader(a(7:end));
        elseif strcmp(button, 'No')
            acq_reader(a(7:end));
        end
    end
else
    a=get(findobj('Tag', 'filetext'), 'String');
    acq_reader(a(7:end));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selecttifs(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
assignin('base', 'userdata', userdata);
if isempty(userdata.selectedindex)
    errordlg('Select traces first', 'Selection error');
else
    pathname=textread([matlabroot, '\work\Physiology\tif_directory_name.erv'], '%s', 'whitespace', '');
    pathname=[pathname{:}, '\'];
    h=waitbar(0, ['Opening .tif file 0 out of ', num2str(length(userdata.selectedindex)), '.']);
    data=[];
    map=[];
    for i=1:length(userdata.selectedindex)
        waitbar(i/length(userdata.selectedindex), h, ['Opening .tif file ', num2str(i), ' out of ', num2str(length(userdata.selectedindex)), '.']);
        if fopen([pathname, userdata.filename(1:8), '\', num2str(userdata.selectedindex(i)), '.tif'])>0
            [x,map] = imread([pathname, userdata.filename(1:8), '\', num2str(userdata.selectedindex(i)), '.tif']);
            data(:,:,i)=double(x);
        end
    end
    close(h)
    acq_tif(data, map);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selectimgdats(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
assignin('base', 'userdata', userdata);
if isempty(userdata.selectedindex)
    errordlg('Select traces first', 'Selection error');
else
    pathname=textread([matlabroot, '\work\Physiology\tif_directory_name.erv'], '%s', 'whitespace', '');
    pathname=[pathname{:}, '\'];
    bin=fopen([pathname, userdata.filename(1:end-3), 'imgdat'], 'r');
    data=fread(bin, 'float');
    fclose(bin);

    %File header:
    %1) Year
    %2) Month
    %3) Day
    %4) Fluoview Settings
    %5) Acquisition rate in samples per second
    %6) Sweep length in samples
    %7) Inter-sweep interval
    %8) Number of sweeps
    %9) Header size

    %Data:
    %lineactive
    %counter.data (one sweep after the other)
    
    imgdata.recordingdate=[num2str(data(2)), '/', num2str(data(3)), '/', num2str(data(1))];
    a={'XY 800 by 600 1.6s/scan' 'XY 800 by 600 3.2s/scan' 'XY 800 by 600 7.8s/scan', ...
        'XY 800 by 600 23.1s/scan' 'XY 800 by 600 76.7s/scan', ...
        'Linescan 40 lines' 'Linescan 100 lines' 'Linescan 200 lines' 'Linescan 400 lines', ...
        'Linescan 1000 lines' 'Linescan 2000 lines' 'Linescan 4000 lines' 'Linescan 8000 lines'};
    imgdata.fluoview=a{data(4)};
    imgdata.samplerate=data(5);
    imgdata.sweeplength=data(6);
    imgdata.interval=data(7);
    imgdata.sweepnumber=data(8);
    imgdata.lineactive=data(data(9)+1:data(9)+imgdata.sweeplength);
    imgdata.sweeps=reshape(data(data(9)+imgdata.sweeplength+1:end), imgdata.sweeplength, imgdata.sweepnumber);
    imgdata.selectedindex=userdata.selectedindex;
    imgdata.selected=imgdata.sweeps(:, userdata.selectedindex);
    imgdata.preAPcount=[];
    imgdata.APcount=[];
    imgdata.basecount=[];
    imgdata.abspreAPcount=[];
    imgdata.absAPcount=[];
    imgdata.absbasecount=[];
    assignin('base', 'imgdata', imgdata);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selecttifpath(obj, event)

pathname=textread([matlabroot, '\work\Physiology\tif_directory_name.erv'], '%s', 'whitespace', '');
pathname=[pathname{:}, '\'];
pathname=uigetdir(pathname, 'Select location of TIF files');
a=fopen([matlabroot, '\work\Physiology\tif_directory_name.erv'], 'w+');
fprintf(a, '%s', pathname);
fclose(a);
set(findobj('Tag', 'tifpathtext'), 'String', pathname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function datatoworkspace(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
assignin('base', 'userdata', userdata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function channelselect(obj, event)

userdata=get(findobj('Tag', 'readwindow'), 'UserData');
userdata.datamat=userdata.datamatchan{get(findobj('Tag', 'channelpopup'), 'Value')};
userdata.parammat=userdata.parammatchan{get(findobj('Tag', 'channelpopup'), 'Value')};
recordingmode=mean(userdata.parammat(userdata.modeindex,:));
if recordingmode==0
    userdata.recordingmode='Current in pA.';
elseif recordingmode==1
    userdata.recordingmode='Voltage in mV.';
elseif isnan(recordingmode)
    userdata.recordingmode='Raw signal in V.';
else
    userdata.recordingmode='More than one recording mode or Mode Error';
end
userdata.baselinemat=userdata.datamat(userdata.samplerate*str2double(get(findobj('Tag', 'basestartedit'), 'String'))/1000:userdata.samplerate*str2double(get(findobj('Tag', 'basestartedit'), 'String'))/1000+userdata.samplerate*str2double(get(findobj('Tag', 'basedurationedit'), 'String'))/1000, :);
userdata.baseline=mean(userdata.baselinemat);
userdata.datamatbase=userdata.datamat-repmat(userdata.baseline, userdata.sweeplength, 1);
set(findobj('Tag', 'readwindow'), 'UserData', userdata);
if get(findobj('Tag', 'plotallradio'), 'Value')==1
    plotall;
elseif get(findobj('Tag', 'plotall-bradio'), 'Value')==1
    allminusb;
elseif get(findobj('Tag', 'plotoneradio'), 'Value')==1
    plotone;
elseif get(findobj('Tag', 'plotone-bradio'), 'Value')==1
    oneminusb;
else
    set(findobj('Tag', 'plotallradio'), 'Value', 1);
    plotall;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axisselect(obj, event)

if get(findobj('Tag', 'plotallradio'), 'Value')==1
    plotall;
elseif get(findobj('Tag', 'plotall-bradio'), 'Value')==1
    allminusb;
elseif get(findobj('Tag', 'plotoneradio'), 'Value')==1
    plotone;
elseif get(findobj('Tag', 'plotone-bradio'), 'Value')==1
    oneminusb;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function userdata=datrepair(userdata, basewindowstartdefault, basewindowdurationdefault)

userdata.sweepnumber=(size(userdata.data,1)/(userdata.sweeplength+userdata.tailsize))/userdata.channelnumber;
button=questdlg(['Sweeps found: ', num2str(userdata.sweepnumber), '. Channels: ', num2str(userdata.channelnumber), '.'],...
    'DAT Repair Tool','Repair File?','Cancel','Repair File?');
if strcmp(button, 'Repair File?')
    pathname=textread([matlabroot, '\work\Physiology\dat_directory_name.erv'], '%s', 'whitespace', '');
    pathname=[pathname{:}, '\'];
    bin=fopen([pathname, userdata.filename], 'r');
    data=fread(bin, 'float');
    fclose(bin);
    movefile([pathname, userdata.filename], [pathname, userdata.filename(1:end-4), '_old.dat']);
    data(8)=userdata.sweepnumber;
    bin=fopen([pathname, userdata.filename], 'w');
    fwrite(bin, data, 'float');
    fclose(bin);
    button=questdlg(['Old file saved as: ', pathname, userdata.filename(1:end-4), '_old.dat'], ...
        'DAT Repair Tool', 'Open Repaired File?', 'Cancel', 'Open Repaired File?');
    if strcmp(button, 'Open Repaired File?')
        datamat=reshape(userdata.data, userdata.sweeplength+userdata.tailsize, userdata.sweepnumber*userdata.channelnumber);
        userdata.channelpopupstr={};
        userdata.datamatchan={};
        userdata.parammatchan={};
        if userdata.channelnumber>1
            userdata.channelpopupvis='on';
            for i=1:userdata.channelnumber
                userdata.datamatchan{i}=datamat(1:userdata.sweeplength,i:userdata.channelnumber:end);
                userdata.parammatchan{i}=datamat(userdata.sweeplength+1:end,i:userdata.channelnumber:end);
                userdata.channelpopupstr{i}=['Ch: ', num2str(i)];
            end
            userdata.datamat=userdata.datamatchan{1}; %The first channel is selected by default
            userdata.parammat=userdata.parammatchan{1}; %The first channel is selected by default
        else
            userdata.channelpopupvis='off';
            userdata.parammat=datamat(userdata.sweeplength+1:end,:);
            userdata.datamat=datamat(1:userdata.sweeplength,:);
        end
        recordingmode=mean(userdata.parammat(userdata.modeindex,:));
        if recordingmode==0
            userdata.recordingmode='Current in pA.';
        elseif recordingmode==1
            userdata.recordingmode='Voltage in mV.';
        elseif isnan(recordingmode)
            userdata.recordingmode='Raw signal in V.';
        else
            userdata.recordingmode='More than one recording mode or Mode Error';
        end

        %Generates the time scale
        userdata.timescale=1000/userdata.samplerate:1000/userdata.samplerate:1000*userdata.sweeplength/userdata.samplerate;

        %Substracts the baseline to the sweeps
        userdata.baselinemat=userdata.datamat(userdata.samplerate*basewindowstartdefault/1000:userdata.samplerate*basewindowstartdefault/1000+userdata.samplerate*basewindowdurationdefault/1000, :);
        userdata.baseline=mean(userdata.baselinemat);
        userdata.datamatbase=userdata.datamat-repmat(userdata.baseline, userdata.sweeplength, 1);

        %Additional variables to be filled during analysis
        userdata.noisemat=[];
        userdata.selected=[];
        userdata.selectedindex=[];
        userdata.events=[];
        userdata.selectedevents=[];
        userdata.alignedevents=[];
        userdata.noisemat=[];
        userdata.selectedAPssweep=[];
        userdata.selectedAPsnumber=[];
        userdata.selectedAPsindex=[];
        userdata.selectedAPspeakindex=[];
        userdata.selectedAPs=[];
        userdata.selectedAPsmean=[];
        userdata.lines=[];
        userdata.linestime=[];
        userdata.selectedAPsimage=[];
        userdata.selectedAPsimagemean=[];
    else
        userdata=0;
    end
else
    userdata=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function batchgroup(obj, event)

a=evalin('base', 'who(''name'', ''Ephys*'')');
[s, v]=listdlg('ListString', a);
if v==1
    channel=get(findobj('Tag', 'channelpopup'), 'Value');
    data=[];
    for i=1:length(s)
        userdata=evalin('base', a{s(i)});
        if userdata.channelnumber>1
            data(:,:,i)=userdata.datamatchan{channel};
        else
            data(:,:,i)=userdata.datamat;
        end
    end
    assignin('base', 'grouped_data', data);
end
