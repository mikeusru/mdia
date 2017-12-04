function r_setRoi(org, dists)
%num = length(a.img);
k = 1;
nRoi = 8;

for roi_n = 1:nRoi
    TagN = ['Ts', num2str(roi_n), '_', num2str(org)];  
    ROIs = findobj('Tag', TagN);
    if length(ROIs) > 0
        ROIs_pos = get(ROIs, 'Position');
        for i = dists
            TagN = ['Ts', num2str(roi_n), '_', num2str(i)];
            ROIa = findobj('Tag', TagN);
            set(ROIa, 'Position', ROIs_pos);
        end
    end
end
TagNb = ['Tb', num2str(org)];
ROIb = findobj('Tag', TagNb);
if length(ROIb) > 0
        ROIb_pos = get(ROIb, 'Position');
        for i = dists
            TagNb = ['Tb', num2str(i)];
            ROIb = findobj('Tag', TagNb);
            set(ROIb, 'Position', ROIb_pos);
        end
end
