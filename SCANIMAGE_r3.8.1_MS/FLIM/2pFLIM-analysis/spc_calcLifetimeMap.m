function spc_calcLifetimeMap
global spc;
global gui;

pos_max2 = spc.fit(gui.spc.proChannel).t_offset; %str2num(get(gui.spc.spc_main.F_offset, 'String'));
if isempty (pos_max2);
    pos_max2 = 1.0;
end
if isnan(pos_max2)
    pos_max2 = 1.0;
end

set(gui.spc.spc_main.F_offset, 'String', num2str(pos_max2));

%spc.fit.range = round(spc.fit.range);
range = spc.fit(gui.spc.proChannel).range;


imageMod = spc.imageMod(range(1):range(2), :, :);
lineN = size(spc.imageMod, 2)/spc.datainfo.scan_rx;
if spc.datainfo.scan_rx > 1
    imageMod = imageMod(:, (gui.spc.proChannel-1)*lineN + 1:gui.spc.proChannel*lineN, :);
end

try
    spc_roi = get(gui.spc.figure.roi, 'Position');
catch
    spc_roi = [1,1,spc.size(3), spc.size(2)];
end



project = reshape(sum(spc.imageMod, 1),spc.datainfo.scan_y, spc.datainfo.scan_x);
spc.lifetimeAll = reshape(sum(sum(spc.imageMod, 2), 3), spc.size(1), 1);

% [maxcount, pos_max] = max(spc.lifetimeAll(range(1):1:range(2)));
% pos_max = pos_max+range(1)-1;

x_project = range(1):range(2); %1:length(range(1):range(2));
x_project2 = repmat(x_project, [1,lineN*spc.datainfo.scan_x]);
x_project2 = reshape(x_project2, length(x_project), lineN, size(spc.imageMod, 3));
sumX_project = imageMod.*x_project2;
sumX_project = sum(sumX_project, 1);

sum_project = sum(imageMod, 1);
sum_project = reshape(sum_project, lineN, size(spc.imageMod, 3)); 

spc.lifetimeMap = zeros(lineN, size(spc.imageMod, 3));
bw = (sum_project > 0);

%%%%%%%%%%%%%%%%%%%%%%
% tauD = spc.fit(gui.spc.proChannel).beta0(2)*spc.datainfo.psPerUnit/1000;
% tauAD = spc.fit(gui.spc.proChannel).beta0(4)*spc.datainfo.psPerUnit/1000;
% pop1 = 0*spc.lifetimeMap;
% pop2 = 0*spc.lifetimeMap;
% pop2(bw) = spc_getFraction(sumX_project(bw)./sum_project(bw));
% pop1(bw) = 1- pop2(bw);
% spc.lifetimeMap(bw) = (tauD*tauD*pop1(bw)+tauAD*tauAD*pop2(bw))/(tauD*pop1(bw) + tauAD*pop2(bw));

spc.lifetimeMap(bw) = (sumX_project(bw)./sum_project(bw))*spc.datainfo.psPerUnit/1000-pos_max2;
%[~, spc.lifetimeMap(bw)] = spc_getFraction(sumX_project(bw)./sum_project(bw));


if spc.SPCdata.line_compression > 1
    aa = 1/spc.SPCdata.line_compression;
    %[xi, yi] = meshgrid(aa:aa:spc.SPCdata.scan_size_x, aa:aa:spc.SPCdata.scan_size_y);
    [xi, yi] = meshgrid(1:aa:1-aa+lineN, 1:aa:1-aa+size(spc.imageMod, 3));
    lifetimeMap1 = [spc.lifetimeMap; spc.lifetimeMap(end, :)];
    lifetimeMap2 = [lifetimeMap1, lifetimeMap1(:, end)];
    spc.lifetimeMap = interp2(lifetimeMap2, xi, yi);
    spc.size(2) = lineN * (1/aa);
    spc.size(3) = size(spc.imageMod, 3) * (1/aa);           
end

if spc.switches.filter > 1
    filterWindow = ones(spc.switches.filter, spc.switches.filter)/spc.switches.filter/spc.switches.filter;
    spc.lifetimeMap(1:end-1, 2:end) = imfilter(spc.lifetimeMap(1:end-1, 2:end), filterWindow, 'replicate');
end


if isfield(spc, 'roipoly')
	spc.lifetimeMap(~spc.roipoly) = spc.fit(gui.spc.proChannel).lifetime_limit(2);
end
