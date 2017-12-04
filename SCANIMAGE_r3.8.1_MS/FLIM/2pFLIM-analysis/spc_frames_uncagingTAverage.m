function spc_frames_uncagingTAverage
global spc gui
%global tmp

prompt = {'Baseline', 'Frames per uncaging', 'N of uncaging', 'smooth'};
dlg_title = 'Input';
num_lines = 2;
def = {'32', '16', '30', '3'};
answer = inputdlg(prompt, dlg_title, num_lines, def);
if isempty(answer)
    return;
end
baseline = str2num(answer{1});
frames_per_uncaging = str2num(answer{2});
n_of_uncaging = str2num(answer{3});
fw = str2num(answer{4});

spc.page = 1;
set(gui.spc.spc_main.spc_page, 'String', num2str(spc.page));
spc_redrawSetting(1);

for i = 1 : frames_per_uncaging
    spc.stack.image1{i} = 0*spc.stack.image1{i};
    fprintf('Frame-%d, average frames: ', i);
    for j = 0 : n_of_uncaging - 1
        for k = 0-fw+1:0
            frame = baseline + j* frames_per_uncaging + (i-1) + k;
            spc.stack.image1{i} = spc.stack.image1{i}+spc.stack.image1{frame};
            fprintf('%d, ', frame);
        end
    end
    fprintf('\n');
    spc.stack.image1{i} = spc.stack.image1{i} ;
end

spc.stack.nStack = frames_per_uncaging;


%%Display
spc.page = 1;
set(gui.spc.spc_main.spc_page, 'String', num2str(spc.page));

set(gui.spc.figure.projectAuto, 'Value', 1);
spc_redrawSetting(1);

spc_max = max(spc.project(:));
set(gui.spc.figure.LutUpperlimit, 'String', num2str(round(spc_max/3)));
set(gui.spc.figure.LutLowerlimit, 'String', num2str(round(spc_max/20)));

siz = size(spc.rgbLifetime);
rgb_image = [];
for i = 1:frames_per_uncaging
    set(gui.spc.spc_main.spc_page, 'String', num2str(i));
    spc_redrawSetting(1);
    rgb_image = [rgb_image, spc.rgbLifetime];
end
figure; image(rgb_image);
set(gca, 'xtick', []);
set(gca, 'ytick', []);
set(gca, 'position', [0, 0, 1, 1]);
set(gcf, 'position', [100, 250, 64*frames_per_uncaging, 64]);
imwrite(rgb_image, 'image_montage.tif', 'compression', 'none');
end


