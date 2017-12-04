function r_makemovie3(filename, montage, cLimit, cLimit2, movie);

xlimit = get(gca, 'Xlim');
ylimit = get(gca, 'Ylim');
ROI = [xlimit(1), ylimit(1), xlimit(2) - xlimit(1), ylimit(2)-ylimit(1)];
Aout.ROI = ROI;
j = 1;

if movie
    mov_name = ['anim-', basename, '.avi'];
    mov = avifile(mov_name, 'fps', 2);
end

%try
	j = 1;
	
	if findobj('Tag', 'RedFig')
        fig_r = figure(findobj('Tag', 'RedFig'));
	else
        fig_r = figure;
        colormap(gray);
        set(fig_r, 'Tag', 'RedFig');
        set(gcf, 'PaperPositionMode', 'auto');
        set(gcf, 'PaperOrientation', 'landscape');
	end
	if findobj('Tag', 'GreenFig')
        fig_g = figure(findobj('Tag', 'GreenFig'));
	else
         fig_g = figure;
         colormap(gray);
         set(fig_g, 'Tag', 'GreenFig');
         set(gcf, 'PaperPositionMode', 'auto');
        set(gcf, 'PaperOrientation', 'landscape');
	end
	if  findobj('Tag', 'ColorFig')
        fig_c = figure(findobj('Tag', 'ColorFig'));
	else
       fig_c = figure;
       set(fig_c, 'Tag', 'ColorFig');
       set(gcf, 'PaperPositionMode', 'auto');
       set(gcf, 'PaperOrientation', 'landscape');
	end
	
	[data,header] = genericOpenTif(filename);
    redave = mean(data(:,:,2:2:end), 3);
    
    for i= 1: header.acq.numberOfFrames
        figure(fig_c);
            subplot(montage(1), montage(2), j);

            
            
            greenim = data(:,:,i*2-1);
            greenim = (greenim - cLimit(1))/(cLimit(2) - cLimit(1));

            redim = data(:,:,i*2);
            %redim = redave ;
            redim = (redim - cLimit2(1))/(cLimit2(2) - cLimit2(1));
            
            f = [1,1,1;1,1,1;1,1,1]/9;
            redim = filter2(f, redim);
            greenim = filter2(f, greenim);
            greenim(greenim > 1) = 1;
            greenim(greenim < 0) = 0;
            redim (redim >=1) = 1;
            redim (redim < 0) = 0;
            
            
            siz = size(greenim);
            colorim = zeros(siz(1), siz(2), 3);

            colorim(:, :, 1) = redim;
            colorim(:, :, 2) = greenim;
            image(colorim);
            set(gca, 'XTickLabel', '', 'YTickLabel', '');
        figure(fig_g);
            subplot(montage(1), montage(2), j);
            imagesc(data(:,:,i*2-1), cLimit);
            set(gca, 'XTickLabel', '', 'YTickLabel', '');
        figure(fig_r);
            subplot(montage(1), montage(2), j);
            imagesc(data(:,:,i*2-1), cLimit2);
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
if movie
    mov = close(mov);
end
