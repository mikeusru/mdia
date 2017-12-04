function takashi_setRoi(org, dists)
%num = length(a.img);
k = 1;
nRoi = 3;

for roi_n = 1:nRoi
    TagN = ['Ts', num2str(roi_n), '_', num2str(org)];  
    ROIs = findobj('Tag', TagN);
    if length(ROIs) > 0
        ROIs_pos = get(ROIs, 'Position');
        for i = dists
        end
    end

end
TagNb = ['Tb', num2str(org)];
ROIs = findobj('Tag', TagN);
if length(ROIb) > 0
        ROIb_pos = get(ROIb, 'Position');
        for i = dists
            TagNb = ['Tb', num2str(i)];
            ROIb = findobj('Tag', TagNb);
            set(ROIb, 'Position', ROIb);
        end
end
