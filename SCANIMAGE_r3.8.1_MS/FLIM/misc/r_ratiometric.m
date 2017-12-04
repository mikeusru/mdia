function [ratioval, time_in_min] = r_ratiometric(basename, numbers, montage, bg, climit, thresh, movie);
%%%%%%%%%%%%%%
% Making montage for usual images
%%%%%%%%%%%%

if nargin < 5
    movie = 0;
end
%handles = gui.spc.lifetimerange;
backr = bg(2);
backg = bg(1);

if movie
    mov_name = ['anim-', basename, '.avi'];
    mov = avifile(mov_name, 'fps', 2);
end
% 
% try
j = 1;


if  findobj('Tag', 'RatioFig')
    fig_c = figure(findobj('Tag', 'RatioFig'));
else
   fig_c = figure;
   set(fig_c, 'Tag', 'RatioFig');
   set(gcf, 'PaperPositionMode', 'auto');
   set(gcf, 'PaperOrientation', 'landscape');
end

	for i=numbers
        str1 = '000';
        str2 = num2str(i);
        str1(end-length(str2)+1:end) = str2;
        filename1 = [basename, str1, 'max.tif'];
        filename2 = [basename, str1, '.tif'];
        if exist(filename1)
            [data,header]=genericOpenTif(filename1);
        elseif exist(filename2)
            [data,header]=genericOpenTif(filename2);
        else
            disp('No such file');
        end
        figure(fig_c);
            subplot(montage(1), montage(2), j);
            greenim = data(:,:,1);
            greenval = sum(greenim(greenim-backg > thresh)-backg);
            redim = data(:,:,2);
            redval = sum(redim(greenim-backg > thresh)-backr);
            point_ratio = (redim(greenim-backg > thresh)-backr)./(greenim(greenim-backg > thresh)-backg);
            ratioval(j) = (redval)/(greenval);
            %ratioval(j) = mean(mean(point_ratio));
            time_in_min(j) = header.internal.triggerTimeInSeconds/60;
            
            h = [1,1,1;1,1,1;1,1,1]/9;
            greenimF = filter2(h, greenim);
            redimF = filter2(h, redim);
            colorim = (redimF-backr)./(greenimF-backg);
            colorim (greenim-backg < thresh) = 0;
            imagesc(colorim, climit);
            set(gca, 'XTickLabel', '', 'YTickLabel', '');
        if movie
            F = getframe(gca);
            mov = addframe(mov,F);
        end
        j = j+1;
	end
% catch
%     disp(['Error at', num2str(i)]);
% end
colorbar;
if movie
    mov = close(mov);
end
