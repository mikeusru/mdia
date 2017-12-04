function Aout = yphys_calcium_offLine (inAverage)
global state;
global yphys;
global gh;

if ~nargin
    inAverage = 0;
end

color_a = {'green', 'red', 'white', 'cyan', 'magenda'};
%fh = 402;

roiobj = findobj('Tag', 'ROI');

nRoi = length(roiobj);

data = yphys.image.imageData;
header = yphys.image.imageHeader;
num = yphys.image.currentImage;


if header.acq.linescan
    yphys_linescanAnalysis;
else
    calcium_calcRoi;
end

if isfield(yphys.image, 'intensity')
    try
        Aout = yphys.image.intensity{num};
    catch
        yphys.image.intensity{num} = {};
        Aout = yphys.image.intensity{num};
    end
    
else
    yphys.image.intensity{num} = {};
    Aout = yphys.image.intensity{num};
end
if ~isfield(yphys.image, 'aveImage')
    yphys.image.aveImage = [];
end
if nRoi > 0
    if inAverage
        if ~isfield(yphys.image, 'aveImage')
            yphys.image.aveImage = num;
        end
        if isempty(find(yphys.image.aveImage == num))
            yphys.image.aveImage = [yphys.image.aveImage, num];
        end

        yphys.image.average.ratio = Aout.ratio .* 0;
        siz = length(yphys.image.average.ratio);
        Num = 0;
        for i=yphys.image.aveImage
            sizN = length(yphys.image.intensity{i}.ratio);
            if siz == sizN
                yphys.image.average.ratio  = yphys.image.intensity{i}.ratio + yphys.image.average.ratio;
                Num = Num + 1;
            else
%                 yphys.image.average.ratio  = [];
%                 Num = 1;
            end
        end
        if ~isempty(yphys.image.average.ratio)
            yphys.image.average.ratio=  yphys.image.average.ratio/Num;
        end



    end
    
        filenamestr = [yphys.image.baseName, '_intensity'];
        evalc([filenamestr, '=yphys.image.intensity']);
        
        if ~exist(yphys.image.pathstr)
            mkdir(yphys.image.pathstr);
        end
        cd(yphys.image.pathstr);
        save(filenamestr, filenamestr);
        try
            filenamestr2 = ['e', num2str(state.yphys.acq.epochN), 'p', num2str(state.yphys.acq.pulseN), '_int'];
        catch
            filenamestr2 = 'Intensity';    
        end
        saveAverage.average = yphys.image.average;
        saveAverage.aveImage = yphys.image.aveImage;
        evalc([filenamestr2, '=saveAverage']);
        save(filenamestr2, filenamestr2);
end
%evalc([state.files.baseName, '_int = A1']);
%save([state.files.baseName, '_int'], [state.files.baseName, '_int']);


yphys_showImageTraces(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calcium_calcRoi;
global yphys
global gh
data = yphys.image.imageData;
header = yphys.image.imageHeader;
num = yphys.image.currentImage;
roiobj = findobj('Tag', 'ROI');
nRoi = length(roiobj);


if nRoi > 0
	for j = 1:length(gh.yphys.figure.roiCalcium) %RoiCounter = 1:nRoi
        if ishandle(gh.yphys.figure.roiCalcium(j))
            ROI = get(gh.yphys.figure.roiCalcium(j), 'Position');
            theta = [0:1/20:1]*2*pi;
            xr = ROI(3)/2;
            yr = ROI(4)/2;
            xc = ROI(1) + ROI(3)/2;
            yc = ROI(2) + ROI(4)/2;
            x1 = round(sqrt(xr^2*yr^2./(xr^2*sin(theta).^2 + yr^2*cos(theta).^2)).*cos(theta) + xc);
            y1 = round(sqrt(xr^2*yr^2./(xr^2*sin(theta).^2 + yr^2*cos(theta).^2)).*sin(theta) + yc);
            siz = size(data);
            ROIreg = roipoly(ones(siz(1), siz(2)), x1, y1);
            %figure; image(ROIreg);
            nPixel = sum(ROIreg(:));
            for i= 1: header.acq.numberOfFrames
                greenim = data(:,:,i*2-1);
                redim = data(:,:, i*2);
                greenCrop = greenim(ROIreg);
                redCrop = redim(ROIreg);
                greenMean(i, j) = mean(greenCrop(:));
                redMean(i, j) = mean(redCrop(:));
                greenSum(i, j) = sum(greenCrop(:));
                redSum(i, j) = sum(redCrop(:));
                if i == 1
                    blankG = greenim(1:16, 1:128);
                    greenBack = mean(blankG(:));
                    blankR = redim(1:16, 1:128);
                    redBack = mean(blankR(:));
                end
            end
            %evalc(['Aout.position', num2str(j), '=ROI']);
            greenMean(:, j) = greenMean(:, j) - greenBack;
            redMean(:, j) = redMean(:, j) - redBack;
            greenSum(:, j) = nPixel*greenMean(:,j);
            redSum(:, j) = nPixel*redMean(:,j);
            Aout.ratio(:, j) = greenSum(:, j)/mean(redSum(3:end, j), 1);
            Aout.position{j} = ROI;
        end
	
	end
	
	Aout.greenMean = greenMean;
	Aout.redMean = redMean;
	Aout.greenSum = greenSum;
	Aout.redSum = redSum;
	yphys.image.intensity{num} = Aout;

end

