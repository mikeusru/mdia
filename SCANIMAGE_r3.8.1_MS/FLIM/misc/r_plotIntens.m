function range = r_plotIntens(r, range)

if nargin < 2
    range = [1:length(r.roiData{1}.Gave)];
end

nRoi = length(r.roiData);
color_a = {'green', 'red', 'black', 'cyan', 'magenda'};

figure;
hold off;
for j = 1 :nRoi
    plot(r.roiData{j}.Rave(range), '-o', 'color', color_a{j}); 
    hold on;
end;

figure;
hold off;
for j = 1 :nRoi
    plot(r.roiData{j}.Gave(range), '-o', 'color', color_a{j}); 
    hold on;
end;

figure;
hold off;
for j = 1 :nRoi
    plot((r.roiData{j}.Gave(range)-min(r.roiData{j}.Gave(range))).^(3/2), r.roiData{j}.Rave(range)-min(r.roiData{j}.Rave(range)), '-o', 'color', color_a{j}); 
    hold on;
end;
%Xlim([0, max(get(gca, 'Xlim'))]);
range = length(range);