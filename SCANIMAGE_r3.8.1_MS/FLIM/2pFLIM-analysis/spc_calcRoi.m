function a = spc_calcRoi
global spc;
global gui;


if ~spc.switches.noSPC
    nChannels = spc.datainfo.scan_rx;
else
    nChannels = spc.state.acq.numberOfChannelsAcquire;
end

filterwindow = 1; %if neccesary.
if length(findobj('Tag', 'RoiA0')) == 0
    beep;
    errordlg('Set the background ROI (roi 0)!');
    return;
end

[filepath, basename, fn, max1] = spc_AnalyzeFilename(spc.filename);

sSiz = get(0, 'ScreenSize');
fpos = [50   100   500   sSiz(4)-200];

if isfield(gui.spc, 'calcRoi')
     if ishandle(gui.spc.calcRoi)
     else
         gui.spc.calcRoi = figure ('position', fpos);
     end
 else
      gui.spc.calcRoi = figure ('position', fpos);
end

spc_updateMainStrings;
name_start=findstr(spc.filename, '\');
name_start=name_start(end)+1;

cd (filepath);

if ~isnan(str2double(basename(1)))
    basename = ['A_', basename];
end
basename(strfind(basename, ' ')) = '_';

fname = [basename, '_ROI2'];
evalc(['global  ', fname]);


if exist([fname, '.mat'], 'file')
    load([fname, '.mat'], fname);
    evalc(['Ch = ', fname]);
else
    a = [];
    bg = [];
end

for channelN = 1:nChannels
        try
            a = Ch(channelN).roiData;
            bg = Ch(channelN).bgData;
        end
        
        
        gui.spc.proChannel = channelN;
        spc_switchChannel;
        
        if get(gui.spc.spc_main.fit_eachtime, 'Value')
                try
                    betahat=spc_fitexp2gauss;
                    spc_redrawSetting(1);
                    fit_error = 0;
                catch
                    fit_error = 1;
                end
            else
            fit_error = 1;
        end
        
        pause(0.1);
        
        nRoi = length(gui.spc.figure.roiB);
        if ~spc.switches.noSPC
            range = spc.fit(channelN).range;
        end

        [a, bg] = spc_calcRoi_internal(a, bg, fn);
        for j=1:nRoi-1
            if spc.switches.noSPC
                a(j).time(fn) = datenum(spc.state.internal.triggerTimeString);
                a(j).time3(fn) = datenum(spc.state.internal.triggerTimeString);
            else
                a(j).time(fn) = datenum([spc.datainfo.date, ',', spc.datainfo.time]);
                a(j).time3(fn) = datenum(spc.datainfo.triggerTime);
            end
        end
        
        Ch(channelN).roiData = a;
        Ch(channelN).bgData = bg;
        
        if isfield(gui.spc.figure, 'polyRoi')
                if ishandle(gui.spc.figure.polyRoi{1})
                    nPoly = length(gui.spc.figure.polyRoi);
                else
                    nPoly = 0;
                end
        else
            nPoly = 0;
        end
        if nPoly
            la = spc_calcpolyLines;
            %evalc([fname, '(', num2str(channelN) ,').polyLines{fn} = la']);
            %evalc(['tmp=', fname, '(', num2str(channelN), ').polyLines']);
            Ch(channelN).polyLines{fn} = la;
            tmp = Ch(channelN).polyLines;
            for i=1:length(tmp)
                try
                    dLen(i) = length(tmp{i}.fraction);
                catch
                    dLen(i) = nan;
                end
            end
            len = min(dLen);
            %for j=1:length(tmp{1}.fraction);
                for i=1:length(tmp)
                    try
                        dend(i, 1:len) = tmp{i}.fraction(1:len);
                    catch
                        dend(i, 1:len) = nan(1, len);
                    end
                end
            %end
            %evalc([fname, '(', num2str(channelN), ').Dendrite = dend']);
            Ch(channelN).Dendrite = dend;
        end
end

Ch(1).filename = spc.filename;
Ch(1).roiData(1).filename = fname;
evalc([fname, '= Ch']);
% evalc ([fname, '.roiData = a']);
% evalc ([fname, '.bgData = bg']);
%evalc ([fname, '.stack = stack']);
save(fname, fname);
%Aout = a;
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

basetime = 0;
for subP = 1:panelN  %Three figures
    error = 0;

    figure (gui.spc.calcRoi);
    subplot(figFormat(1), figFormat(2), subP);
    hold off;
    legstr = [];
    for channelN = 1:nChannels
        for j=1:nRoi-1
            if ishandle(gui.spc.figure.roiB(j+1)) 
                if (strcmp(get(gui.spc.figure.roiB(j+1), 'Type'), 'rectangle') || strcmp(get(gui.spc.figure.roiB(j+1), 'Type'), 'line'))
                    k = mod(j, length(color_a))+1;
                    time1 = a(j).time3;
                    time1 = time1(a(j).time > 1000);
                    if basetime == 0
                        basetime = min(time1);
                    end
                    t = (time1 - basetime)*24*60;
                    evalc(['val = Ch(channelN).roiData(j).', fig_content{subP}]);
                    val = val(a(j).time > 1000);
                    if length(t) == length(val)
                        plot(t, val, '-o', 'color', color_a{k}, 'linewidth', channelN);
                    else
                        plot(val, '-o', 'color', color_a{k}, 'linewidth', channelN);
                        error = 1;
                    end
                    hold on;
                    str1 = sprintf('Ch%01d,ROI%02d', channelN, j);
                    legstr = [legstr; str1];
                end
            end
        end;
    end
    if subP == panelN
        hl = legend(legstr);
        pos = get(hl, 'position');
        set(hl, 'position', [0, 0, pos(3), pos(4)]);
    end
    ylabel(['\fontsize{12} ', fig_yTitle{subP}]);

    if ~error
        xlabel ('\fontsize{12} Time (min)');
    else
        xlabel ('\fontsize{12} ERROR');
    end
end
