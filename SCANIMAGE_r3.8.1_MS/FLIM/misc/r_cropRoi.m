function Aout = r_cropRoi(basename, numbers, montage, cLimit, cLimit2);
%%%%%%%%%%%%%%
% Making montage for usual images
%%%%%%%%%%%%\

waitforbuttonpress;
%figure(gcf);
axes(gca);
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
rectangle('Position', [p1, offset]);
ROI = [p1, offset];
% xlimit = get(gca, 'Xlim');
% ylimit = get(gca, 'Ylim');
% ROI = [xlimit(1), ylimit(1), xlimit(2) - xlimit(1), ylimit(2)-ylimit(1)];
Aout.ROI = ROI;
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
            greenim = imcrop(greenim, ROI);
            Aout.greenval(j) = mean(mean(greenim, 1));

            
            greenim = (greenim - cLimit(1))/(cLimit(2) - cLimit(1));

            redim = data(:,:,2);
            redim = imcrop(redim, ROI);
            Aout.redval(j) = mean(mean(redim, 1), 2);
            
            redim = (redim - cLimit2(1))/(cLimit2(2) - cLimit2(1));

            
            siz = size(greenim);
            colorim = zeros(siz(1), siz(2), 3);
            f = [1,1,1;1,1,1;1,1,1]/9;
            redim = filter2(f, redim);
            greenim = filter2(f, greenim);

            greenim(greenim > 1) = 1;
            greenim(greenim < 0) = 0;
            
            redim (redim >=1) = 1;
            redim (redim < 0) = 0;
            colorim(:, :, 1) = redim;
            colorim(:, :, 2) = greenim;
            image(colorim);
            set(gca, 'XTickLabel', '', 'YTickLabel', '');
        j = j+1;
	end

 figure; hold on; plot(Aout.greenval, '-o'); plot(Aout.redval, '-o', 'color', 'red');