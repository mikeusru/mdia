function Aout = r_cropRoi2(filename, montage, cLimit, cLimit2);

xlimit = get(gca, 'Xlim');
ylimit = get(gca, 'Ylim');
ROI = [xlimit(1), ylimit(1), xlimit(2) - xlimit(1), ylimit(2)-ylimit(1)];
Aout.ROI = ROI;

	j = 1;


       fig_c = figure;
       set(fig_c, 'Tag', 'Crop');
       set(gcf, 'PaperPositionMode', 'auto');
       set(gcf, 'PaperOrientation', 'landscape');

	[data,header] = genericOpenTif(filename);
    redave = mean(data(:,:,2:2:end), 3);
    
    for i= 1: header.acq.numberOfFrames
        figure(fig_c);
            subplot(montage(1), montage(2), j);

            
            
            greenim = data(:,:,i*2-1);
            greenim = imcrop(greenim, ROI);
            Aout.greenval(j) = mean(mean(greenim, 1));
            greenim = medfilt2(greenim, [3,3]);
            greenim = filter2(ones(5,5)/25, greenim);
            Aout.greenMax(j) = max(max(greenim, [], 1), [], 2);
            
            greenim = (greenim - cLimit(1))/(cLimit(2) - cLimit(1));

            red_im2 = data(:,:,i*2);
            red_im2 = imcrop(red_im2, ROI);
            Aout.redval(j) = mean(mean(red_im2, 1), 2);
            red_im = medfilt2(red_im2, [5,5]);
            red_im = filter2(ones(5,5)/25, red_im);
            Aout.redMax(j) = max(max(red_im, [], 1), [], 2);
            %red_im = redave ;
            red_im = red_im2;
            red_im = imcrop(red_im, ROI);
            red_im = (red_im - cLimit2(1))/(cLimit2(2) - cLimit2(1));
            
            %f = [1,1,1;1,1,1;1,1,1]/9;
%             red_im = filter2(f, red_im);
%             greenim = filter2(f, greenim);
            greenim(greenim > 1) = 1;
            greenim(greenim < 0) = 0;
            red_im (red_im >=1) = 1;
            red_im (red_im < 0) = 0;
            
            
            siz = size(greenim);
            colorim = zeros(siz(1), siz(2), 3);

            %colorim(:, :, 1) = red_im;
            colorim(:, :, 2) = greenim;
            image(colorim);
            set(gca, 'XTickLabel', '', 'YTickLabel', '');

        set(gca, 'XTickLabel', '', 'YTickLabel', '');
        j = j+1;
        
	end
 figure; hold on; plot(Aout.greenval, '-o'); plot(Aout.redval, '-o', 'color', 'red');