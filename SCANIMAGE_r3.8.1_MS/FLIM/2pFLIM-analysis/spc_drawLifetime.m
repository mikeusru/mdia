function spc_drawLifetime
global spc
global gui

range = spc.fit(gui.spc.proChannel).range;


spc_roi=round(get(gui.spc.figure.roi, 'Position'));
siz = size(spc.project);
if spc_roi(3) > siz(2) || spc_roi(4) > siz(1) || spc_roi(3) == 1 || spc_roi(4) == 1
    spc_selectAll;
end
if isfield(spc, 'roipoly')
    if size(spc.roipoly) ~= spc.size(2:3)
        spc_selectAll;
    end
end

try

    if spc.SPCdata.line_compression >= 2
        ss = spc.SPCdata.line_compression;
        index = (spc.project >= spc.fit(gui.spc.proChannel).lutlim(1));
        [xi, yi] = meshgrid(ss:ss:spc.datainfo.scan_y*ss, ss:ss:spc.datainfo.scan_x*ss);
        index = interp2(index, xi, yi, 'nearest');          
    else
        index = (spc.project >= spc.fit(gui.spc.proChannel).lutlim(1));
    end
    siz = size(index);
    %bw = (spc.lifetimeMap > 1);
    %index =index.*bw;        siz = size(index);	
    index = repmat (index(:), [1,spc.size(1)]);
    index = reshape(index, siz(1), siz(2), spc.size(1));
    index = permute(index, [3,1,2]);

    if spc.SPCdata.scan_rout_x > 1
        lineN = spc.datainfo.scan_y/spc.SPCdata.scan_rout_x;
        imageMod = index .*  reshape(spc.imageMod(:, (gui.spc.proChannel-1)*lineN + 1:gui.spc.proChannel*lineN, :), spc.size(1), lineN, spc.datainfo.scan_x);
    else
        imageMod = index .*  reshape(spc.imageMod, spc.size(1), spc.datainfo.scan_y, spc.datainfo.scan_x);
    end
    %spc.imageMod = image;
catch
    %image = reshape(full(spc.imageMod), spc.size(1), spc.size(2), spc.size(3));
    imageMod = spc.imageMod;
    disp('LUT error: Line 45 spc_drawLifetime');
end

    if isfield(spc, 'roipoly')
        try
            index = spc.roipoly;
            if spc.SPCdata.line_compression > 1
    %             aa = spc.SPCdata.line_compression;
    %             [xi, yi] = meshgrid(aa:aa:spc.SPCdata.scan_size_x*aa, aa:aa:spc.SPCdata.scan_size_y*aa);
    %             index = interp2(index, xi, yi, 'nearest');          
    %         end
            else
                siz = size(index);
                index = repmat (index(:), [1,spc.size(1)]);
                index = reshape(index, siz(1), siz(2), spc.size(1));
                index = permute(index, [3,1,2]);
                if spc.SPCdata.scan_rout_x > 1
                    lineN = spc.datainfo.scan_y/spc.SPCdata.scan_rout_x;
                    imageMod = spc.imageMod(:, (gui.spc.proChannel-1)*lineN + 1:gui.spc.proChannel*lineN, :);
                end
                imageMod = reshape((index(:) .*  imageMod(:)), spc.size(1), spc.SPCdata.scan_size_y, spc.SPCdata.scan_size_x);
            end
        catch
            display('Problem in ROIPOLY (spc_drawLifetime)');
            spc.roipoly = spc.project*0 + 1;
        end
    end

%spc.imageThresh = imageMod;

% 
if spc.SPCdata.line_compression > 1
    spc_roi1 = round(spc_roi / spc.SPCdata.line_compression);
    spc_roi1(spc_roi1 <= 1) = 1;
else
    spc_roi1 = spc_roi;
end
try
    cropped = imageMod(:, spc_roi1(2):spc_roi1(2)+spc_roi1(4)-1, spc_roi1(1):spc_roi1(1)+spc_roi1(3)-1);
catch
    Xlim1 = get(gui.spc.figure.projectAxes, 'Xlim');
    Ylim1 = get(gui.spc.figure.projectAxes, 'Ylim');
    siz2 = Ylim1(2) - Ylim1(1);
    siz3 = Xlim1(2) - Xlim1(1);
    spc_roi = [1, 1, siz3, siz2];
    if spc.SPCdata.line_compression > 1
        spc_roi1 = round(spc_roi / spc.SPCdata.line_compression);
    else
        spc_roi1 = spc_roi;
    end
    spc_roi1(spc_roi1<1) = 1;
    set(gui.spc.figure.roi, 'Position', spc_roi);
    set(gui.spc.figure.mapRoi, 'position', spc_roi, 'EdgeColor', [1,1,1]);
    cropped = imageMod(:, spc_roi1(2):spc_roi1(2)+spc_roi1(4)-1, spc_roi1(1):spc_roi1(1)+spc_roi1(3)-1);
end
spc.lifetime = reshape(sum(sum(cropped, 2),3), 1, spc.size(1));

siz = size(cropped);
spc.projectThresh = reshape(sum(cropped, 1), siz(2), siz(3));
spc.fit(gui.spc.proChannel).nPixel = sum(spc.projectThresh(:) > 0);
try
    spc.fit(gui.spc.proChannel).background = spc.datainfo.pix_time*spc.datainfo.darkCount(gui.spc.proChannel) ...
        *spc.fit(gui.spc.proChannel).nPixel/spc.SPCdata.adc_resolution*spc.state.acq.numAvgFramesSave;
    %set(gui.spc.spc_main.beta7, 'string', num2str(spc.fit(gui.spc.proChannel).background ));
catch
    spc.fit(gui.spc.proChannel).background = 0;
end

lifetime = spc.lifetime(range(1):1:range(2));
lifetime = lifetime(:);
t = [range(1):1:range(2)];
t = t*spc.datainfo.psPerUnit/1000;

if ~ishandle(gui.spc.figure.lifetimePlot)
    try
        close(gui.spc.figure.lifetime);
    end
    figure(gui.spc.figure.lifetime);
    set(gui.spc.figure.lifetime, 'name', 'Lifetime');
    gui.spc.figure.lifetimeAxes = axes;
    set(gui.spc.figure.lifetimeAxes, 'Position', [0.15, 0.37, 0.8, 0.57], 'XTick', []);
    gui.spc.figure.lifetimePlot = plot(1:64, zeros(64,1));
    hold on;
    gui.spc.figure.fitPlot = plot(1:64, zeros(64, 1));
    xlabel('');
    ylabel('Photon');
    gui.spc.figure.residual = axes;
    set(gui.spc.figure.residual, 'position', [0.15, 0.15, 0.8, 0.18]);
    gui.spc.figure.residualPlot = plot(1:64, zeros(64, 1));    
    xlabel('Lifetime (ns)');
    ylabel('Residuals');

end

set(gui.spc.figure.lifetimePlot, 'XData', t, 'YData', lifetime);
set(gui.spc.figure.fitPlot, 'XData', t, 'YData', lifetime);
set(gui.spc.figure.fitPlot, 'Color', 'Black');
set(gui.spc.figure.residualPlot, 'Xdata', t, 'Ydata', zeros(length(lifetime), 1));
set(gui.spc.figure.lifetimeAxes, 'XTick', []);
set(gui.spc.figure.lifetimeAxes, 'XLim', [0, ceil(spc.fit(gui.spc.proChannel).range(2)*spc.datainfo.psPerUnit/1000)]);
set(gui.spc.figure.residual, 'XLim',[0, ceil(spc.fit(gui.spc.proChannel).range(2)*spc.datainfo.psPerUnit/1000)]);
if (spc.switches.logscale == 0)
    set(gui.spc.figure.lifetimeAxes, 'YScale', 'linear');
else
    set(gui.spc.figure.lifetimeAxes, 'YScale', 'log');
end


%figure(gui.spc.figure.lifetime);
