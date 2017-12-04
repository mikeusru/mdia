function spc_calc_timeCourseFromStack (slices)
global spc gui

if ~nargin
    slices = 1:spc.stack.nStack;
end

%%%%%%%%%%%%%%%
[PATHSTR,fileNAME,EXT] = fileparts(spc.filename);

cd(PATHSTR);

fname = [fileNAME, '_ROI2'];
evalc(['global  ', fname]);

if ~spc.switches.noSPC
    nChannels = spc.datainfo.scan_rx;
else
    nChannels = 1; %spc.state.acq.numberOfChannelsAcquire;
end

filename = [PATHSTR, filesep, fname, '.mat'];
if exist(filename, 'file')
    load(filename);
    evalc(['Ch = ', fname]);
end

for channelN = 1:nChannels
    try
        a = Ch(channelN).roiData;
        bg = Ch(channelN).bgData;
    catch
        a = [];
        bg = [];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nRoi = length(gui.spc.figure.roiB);
if ~spc.switches.noSPC
    range = spc.fit(gui.spc.proChannel).range;
end
pos_max2 = str2num(get(gui.spc.spc_main.F_offset, 'String'));
if pos_max2 == 0 || isnan (pos_max2)
    pos_max2 = 1.0;
end

if spc.switches.redImg
    img_greenMax = spc.state.img.greenMax;
    img_redMax = spc.state.img.redMax;
end

for j=1:nRoi
    %a(j).time = spc.scanHeader.acq.linesPerFrame*spc.scanHeader.acq.msPerLine*[1:spc.stack.nStack];
    %a(j).time = 1:spc.stack.nStack;
    a(j).time = spc.scanHeader.acq.linesPerFrame*spc.scanHeader.acq.msPerLine*[1:spc.stack.nStack]/1000;
end

%for channelN = 1:nChannels
for channelN = gui.spc.proChannel(1);
    gui.spc.proChannel = channelN;
    spc_switchChannel;
    for fn=slices
            spc.page = fn;
            spc.switches.currentPage = spc.page;
            set(gui.spc.spc_main.spc_page, 'String', num2str(spc.page));
            
                spc_redrawSetting;
                pause(0.01);

           [a, bg] = spc_calcRoi_internal(a, bg, fn);
    end 
    
     Ch(channelN).roiData = a;
     Ch(channelN).bgData = bg;
end%Channel.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ch(1).filename = spc.filename;
Ch(1).roiData(1).filename = fname;
evalc([fname, '= Ch']);
%evalc ([fname, '.stack = stack']);

save(fname, fname);

%%%%%%%%%%%%%%%%%%%%%%%%
%Figure
color_a = {[0.7,0.7,0.7], 'red', 'blue', 'green', 'magenta', 'cyan', [1,0.5,0],'black'};
fig_contentA = {'fraction2', 'tau_m', 'int_int2', 'red_int2', 'ratio'};
fig_yTitleA = {'Fraction', 'Tau_m', 'Intensity(FLIM)', 'Intensity(R)', 'ratio'};
fc(1) = get(gui.spc.spc_main.fracCheck, 'Value');
fc(2) = get(gui.spc.spc_main.tauCheck, 'Value');
fc(3) = get(gui.spc.spc_main.greenCheck, 'Value');
fc(4) = get(gui.spc.spc_main.redCheck, 'Value');
fc(5) = get(gui.spc.spc_main.RatioCheck, 'Value');

if spc.switches.noSPC
        fc(1) = 0;
        fc(2) = 0;
        set(gui.spc.spc_main.fracCheck, 'Value', 0);
        set(gui.spc.spc_main.tauCheck, 'Value', 0);
end

k = 0;
for j = 1:length(fc)
    if fc(j)
        k = k+1;
        fig_content{k} = fig_contentA{j};
        fig_yTitle{k} = fig_yTitleA{j};
    end
end
if ~k
    return;
end

panelN = k;
figFormat = [panelN, 1]; %panelN by 1 subplot.

% color_a = {[0.7,0.7,0.7], 'red', 'blue', 'green', 'magenta', 'cyan', [1,0.5,0],'black'};
% if ~spc.switches.noSPC
%     fig_content = {'tau_m', 'int_int2'};
%     fig_yTitle = {'tau_m', 'Intensity(Green)'};
% else
%     fig_content = {'ratio', 'int_int2', 'red_int2'};
%     fig_yTitle = {'Ratio', 'Intensity(Green)', 'Intensity(Red)'};    
% end
% 
% figFormat = [length(fig_content), 1]; 
% 
sSiz = get(0, 'ScreenSize');
fpos = [50   100   500   sSiz(4)-200];
if isfield(gui.spc.figure, 'fastFramePlot')
    if ishandle(gui.spc.figure.fastFramePlot)
        figure(gui.spc.figure.fastFramePlot);
    else
        gui.spc.figure.fastFramePlot = figure('position', fpos);
    end
else
    gui.spc.figure.fastFramePlot = figure('position', fpos);
end


for subP = 1:prod(figFormat)  %Three figures
    error = 0;

    
    subplot(figFormat(1), figFormat(2), subP);
    hold off;
    legstr = [];
    for channelN = 1:nChannels
        for j=1:nRoi-1
            if ishandle(gui.spc.figure.roiB(j+1))
                k = mod(j, length(color_a))+1;
                time1 = a(j).time;
                if j==1 && subP == 1
                    basetime = min(time1);
                end
                t = (time1 - basetime);

                try
                    evalc(['val = Ch(channelN).roiData(j).', fig_content{subP}]);

                    if length(t) == length(val)
                        plot(t, val, '-', 'color', color_a{k}, 'linewidth', channelN);
                    else
                        plot(val, '-', 'color', color_a{k}, 'linewidth', channelN);
                        error = 1;
                    end
                end
                hold on;
                str1 = sprintf('Ch%01d,ROI%02d', channelN, j);
                legstr = [legstr; str1];
            end
        end;
    end
    legend(legstr);
    ylabel(['\fontsize{12} ', fig_yTitle{subP}]);

    if ~error
        xlabel ('\fontsize{12} Frame');
    else
        xlabel ('\fontsize{12} ERROR');
    end
end

