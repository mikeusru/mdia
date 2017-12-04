% function PQC_test
% global state
try
    stopFocus;
end
frames = 10;
nLines = 128;
nPixels = 128;
nTime = 50;
nStripe = 4;
nLinesPerStripe = 32;
state.spc.internal.ifstart = 1;

PQC_readBuffer(0);

PQC_startMeasurement(0, frames*nLines*2 + 5000);
try
    exportClocks(frames);
    start(state.acq.hClockTasks);
    dioTrigger;
end

pixel_time = 1.28e-5;

%[ret, val] = PQC_readBuffer(0);
corr = [0, 0];
linesum = 0;
first = 1;

for i = 1:2
    frameImage{i} = zeros(nTime, nLines, nPixels);
end

tic
for i = 1:nStripe*frames
    nLinesCapture = nLinesPerStripe*i - linesum;
    if i == nStripe*frames
        nLinesCapture = nLinesCapture - 1;
    end
    isize = [nTime, nPixels, nLinesCapture];
    if i==1
        flag(1) = 1;
    elseif i==nStripe*frames
        flag(1) = 2;
    else
        flag(1) = 0;
    end
    flag(2) = 0;
   [ret,corr, line, image1] = PQC_readBuffer_intoFrameA(0, corr, pixel_time, isize, 2, flag);
%     disp(line);
return;

    siz = size(image1);
    image1 = reshape(image1, [nTime, nPixels, siz(2)/nPixels]);
    imageB{i} = reshape(sum(image1, 1), nPixels, siz(2)/nPixels);
    siz = size(image1);
    startLine = linesum + 1;
    endLine =  linesum + line + 1;
    
    if i ~= 1
        sizS = size(saveImage);
        frameImage{1}(:,:,startLine) = image1(:,:, 1) +  saveImage(:, :, sizS(3)/2);
        frameImage{2}(:,:,startLine) = image1(:,:, 1 + siz(3)/2) +  saveImage(:, :, end);
    end
    
    if i == 1
        frameImage{1}(:,:,startLine:endLine) = image1(:,:, 1:siz(3)/2);
        frameImage{2}(:,:, startLine:endLine) = image1(:,:, siz(3)/2 + 1:end);
    else
        frameImage{1}(:,:,startLine+1:endLine) = image1(:,:, 2:line+1);
        frameImage{2}(:,:, startLine+1:endLine) = image1(:,:, line+1+2:end);
    end
   
    saveImage = image1;
    
    linesum  = linesum + line;
    if (ret < 0 && linesum > 0) || (linesum >= frames*nLines)
        ret
        break;
    end
end
toc

PQC_stopMeasurement(0);
stopFocus;

imageA = reshape(sum(frameImage{1},1), [nPixels, nLines*frames]);

