function yphys_moveToImage(flag)
global yphys;
global gh;


if flag == 1
    yphys.image.currentImage = yphys.image.currentImage-1;
        try
            yphys_calcium(yphys.image.currentImage);
        catch
            yphys.image.currentImage = yphys.image.currentImage+1;
            yphys_calcium(yphys.image.currentImage);
            %yphys_showImageTraces(0);
        end
elseif flag == 2
    %if yphys.image.currentImage <= length(yphys.image.intensity)-1
        yphys.image.currentImage = yphys.image.currentImage+1;
        try
            yphys_calcium(yphys.image.currentImage);
        catch
            yphys.image.currentImage = yphys.image.currentImage-1;
            yphys_calcium(yphys.image.currentImage);
        end
        %end
elseif flag == 3
    pos = str2num(get(gh.yphys.figure.currentImageText, 'String'));
    try
        yphys.image.currentImage = pos;
        yphys_calcium(yphys.image.currentImage);
    catch
        yphys.image.currentImage = length(yphys.image.intensity);
        yphys_calcium(yphys.image.currentImage);
    end
        %end
elseif flag == 4
    yphys.image.aveImage = str2num(get(gh.yphys.figure.averageInFigure, 'String'))
    yphys_showImageTraces(0);
elseif flag == 5
    yphys.image.currentSlice = yphys.image.currentSlice-1;
    yphys_showImageTraces(0);
elseif flag == 6
    yphys.image.currentSlice = yphys.image.currentSlice+1;
    yphys_showImageTraces(0);
end

