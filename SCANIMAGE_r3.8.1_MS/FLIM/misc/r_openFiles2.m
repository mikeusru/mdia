function a = r_openFiles2(basename, num)

delete(findobj('Tag', 'rrr'));
nRoi = 8;

i = 1;
for j=num
    str1 = '000';
    str2 = num2str(j);
    str1(end-length(str2)+1:end) = str2;
    filename1 = [basename, str1, '.tif'];
    info = imfinfo (filename1);
    nimg = length(info);

    for imc = 1:nimg/2
        aimg{imc} = medfilt2(imread(filename1, imc*2-1), [3,3]);
        ared{imc} = medfilt2(imread(filename1, imc*2), [3,3]);
        if imc == 1
            a.img{i} = aimg{imc};
            a.red{i} = ared{imc};
        else
            a.img{i} = a.img{i} + aimg{imc};
            a.red{i} = a.red{i} + ared{imc};            
        end
    end

    a.num(i) = j;
    figure('name', num2str(j), 'Tag', 'rrr'); 
    imagesc(a.img{i});
    colorA = {'green', 'white', 'cyan', 'yellow', 'magenta', 'blue', [0.7,0.7,0.7], [0.3,0.3,0.3]};
    for k = 1:nRoi
        ROI_spine1 = [120-k*110/nRoi   24    16    16];
        TagN = ['Ts', num2str(k), '_', num2str(j)];
        rectangle('Position', ROI_spine1, 'EdgeColor', colorA{k}, 'ButtonDownFcn', 'r_dragRoi2', 'Tag', TagN, 'linewidth', 2);  
    end
    ROI_background = [3 3    16    16];
    TagNb = ['Tb', num2str(j)];
    rectangle('Position', ROI_background, 'EdgeColor', 'red', 'ButtonDownFcn', 'r_dragRoi2', 'Tag', TagNb);
    i = i+1;
end

%     ROI_spine1 = [70   24    16    16];
%     ROI_spine2 = [50   24    16    16];
%     ROI_spine3 = [30   24    16    16];
%     ROI_spine4 = [10   24    16    16];
%     ROI_background = [3 3    16    16];
%     TagN1 = ['Ts1_', num2str(j)];
%     TagN2 = ['Ts2_', num2str(j)];
%     TagN3 = ['Ts3_', num2str(j)];
%     TagN4 = ['Ts4_', num2str(j)];
%     TagNb = ['Tb', num2str(j)];
% 
%     rectangle('Position', ROI_spine1, 'EdgeColor', 'green', 'ButtonDownFcn', 'r_dragRoi2', 'Tag', TagN1);
%     rectangle('Position', ROI_spine2, 'EdgeColor', 'white', 'ButtonDownFcn', 'r_dragRoi2', 'Tag', TagN2);
%     rectangle('Position', ROI_spine3, 'EdgeColor', 'cyan', 'ButtonDownFcn', 'r_dragRoi2', 'Tag', TagN3);
%     rectangle('Position', ROI_spine4, 'EdgeColor', [0.7, 0.7, 0.7], 'ButtonDownFcn', 'r_dragRoi2', 'Tag', TagN4);
%     rectangle('Position', ROI_background, 'EdgeColor', 'red', 'ButtonDownFcn', 'r_dragRoi2', 'Tag', TagNb);