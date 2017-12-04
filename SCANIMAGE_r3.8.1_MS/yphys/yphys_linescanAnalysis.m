%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yphys_linescanAnalysis;
global yphys

data = yphys.image.imageData;
header = yphys.image.imageHeader;
num = yphys.image.currentImage;
siz = size(data);

for j = 1:header.acq.numberOfChannelsAcquire
    data1 = data(:,:,j:2:end);
    data2 = []; 
    for i=1:siz(3)/2; 
        data2 = [data2; data1(:,:,i)]; 
    end
    lineData{j} = data2;
end

yphys.linescan.profileChannel = 2; 
% yphys.linescan.profileChannel = 1; %%%%%%%%%CHANGE HERE
yphys.linescan.pStart = header.acq.linesPerFrame * 2;
yphys.linescan.pEnd = header.acq.linesPerFrame * 3;
yphys.linescan.bStart = 1;
yphys.linescan.bEnd = 25;
yphys.linescan.filterwindow = 21;
yphys.linescan.nLineRoi = 1;
yphys.linescan.prange = [];
yphys.lineData = lineData;

data = lineData{yphys.linescan.profileChannel};
background = mean(mean(data(yphys.linescan.bStart:yphys.linescan.bEnd), 1), 2);

data1 = lineData{1};
data2 = lineData{2};
background1 = mean(mean(data1(yphys.linescan.bStart:yphys.linescan.bEnd), 1), 2);
background2 = mean(mean(data2(yphys.linescan.bStart:yphys.linescan.bEnd), 1), 2);

profile = mean(data(yphys.linescan.pStart:yphys.linescan.pEnd, :), 1)-background;
yphys.linescan.profile = filter(ones(yphys.linescan.filterwindow, 1)/yphys.linescan.filterwindow, 1, profile);
%figure; plot(profile);
[xmax,imax,xmin,imin] = extreme(yphys.linescan.profile);
if yphys.linescan.nLineRoi == 2
    if imax(2) > imax(1)
        tmp = imax(1);
        imax(1) = imax(2);
        imax(2) = tmp;
        tmp = xmax(1);
        xmax(1) = xmax(2);
        xmax(2) = tmp;
        tmp = xmax(1);
    end
end

for j = 1:yphys.linescan.nLineRoi
    if yphys.linescan.nLineRoi == 2
        if j == 2
            plimit(1) = 1;
            plimit(2) = (imax(1)+imax(2))/2;
        elseif j == 1
            plimit(1) = (imax(1)+imax(2))/2;
            plimit(2) = length(yphys.linescan.profile);
        end
    else
        plimit(1) = 1;
        plimit(2) = length(yphys.linescan.profile);
    end
    i = 0;
    while (yphys.linescan.profile(imax(j)+i) > xmax(j)*0.7) & (i + imax(j) < plimit(2))
        i = i+1;
    end
    half_after(j) = imax(j) + i;
    i = 0;
    while (yphys.linescan.profile(imax(j)-i) > xmax(j)*.7) & (imax(j) - i) > plimit(1)
        i = i+1;
    end
    half_before(j) = imax(j) - i;
    yphys.linescan.prange{j} = [half_before(j):half_after(j)];
    
    yphys.image.position{j} = yphys.linescan.prange{j};
    yphys.image.intensity{num}.greenMean(:, j) = mean(lineData{1}(:,yphys.linescan.prange{j}), 2)-background1;
    if header.acq.numberOfChannelsAcquire > 1
        yphys.image.intensity{num}.redMean(:, j) = mean(lineData{2}(:,yphys.linescan.prange{j}), 2)-background2;
            yphys.image.intensity{num}.ratio(:, j) = yphys.image.intensity{num}.greenMean(:, j)/mean(yphys.image.intensity{num}.redMean(:, j));
%            yphys.image.intensity{num}.ratio(:, j) = yphys.image.intensity{num}.greenMean(:, j);
    else
        yphys.image.intensity{num}.ratio(:, j) = yphys.image.intensity{num}.greenMean(:, j);
    end
end



