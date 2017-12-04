function [green, red] = takashi_intensity (a)
%num = length(a.img);
k = 1;
nRoi = 8;
for i = a.num   
  for roi_n = 1:nRoi
    TagN = ['Ts', num2str(roi_n), '_', num2str(i)];
    TagNb = ['Tb', num2str(i)];
    ROIs = findobj('Tag', TagN);
    ROIb = findobj('Tag', TagNb);
    ROIs_pos = get(ROIs, 'Position');
    ROIb_pos = get(ROIb, 'Position');
    %j = str2num(get(get(get(ROIs, 'Parent'), 'Parent'), 'Name'));
    sp = imcrop(a.img{k}, ROIs_pos); 
    spine_ave = mean(sp(:));
    spine_int = sum(sp(:));
    nPixel = spine_int / spine_ave;
    bg = imcrop(a.img{k}, ROIb_pos);
    back_ave = mean(bg(:));
    %back_int

    
   if isfield(a, 'red')
        sp_red = imcrop(a.red{k}, ROIs_pos); 
        spine_ave_red = mean(sp_red(:));
        bg_red = imcrop(a.red{k}, ROIb_pos);
        back_ave_red = mean(bg_red(:));
        green(i, roi_n) = (spine_ave - back_ave)*nPixel;
        red(i, roi_n) = (spine_ave_red - back_ave_red)*nPixel;
        %back_int_red
    else
        green(i, roi_n) = (spine_ave - back_ave)*nPixel;
    end

  end
      k = k+1;
end
