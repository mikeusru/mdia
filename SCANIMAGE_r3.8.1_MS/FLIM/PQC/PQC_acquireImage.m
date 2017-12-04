function [ret, nLines, acqLines] = PQC_acquireImage (focus, stopLine)
%% function PQC_acquireImage
% This is a function to acquire image from PicoQuant card
%

%% CREDITS
%  Created 9/07/2016, by Ryohei
%% ********************************************************

global state spc

%%%%%Actual acquisition.%%%%%%%%%%%%%%
acqLines = 0;
nCh = state.spc.acq.SPCdata.n_channels;
ret = 0;

startLine1 = state.spc.internal.lineCounter + 1; %TOTAL first line
stopLine1 = state.internal.frameCounter * state.acq.linesPerFrame + stopLine; %TOTAL last line
nLines = stopLine1 - state.spc.internal.lineCounter; %NFrame need to fill.
if (startLine1 == 1)
    flag(1) = 1;
    state.spc.internal.corr = [0, 0];
else
    flag(1) = 0;
end
if ~focus && stopLine1 == state.acq.numberOfFrames * state.acq.linesPerFrame
    flag(1) = 2;
    nLines = nLines - 1;
end

flag(2) = state.spc.acq.spc_takeFLIM; % && (~focus);

%fprintf('line: %d, %d, %d --- ', state.internal.frameCounter, stopLine1, nLines);
if nLines > 0
    nPixels = state.acq.pixelsPerLine;
    if flag(2)
        isize = [state.spc.acq.SPCdata.adc_resolution, nPixels, nLines];
    else
        isize = [1, nPixels, nLines];
    end
    lineID = 2;
 
    [ret, state.spc.internal.corr, acqLines, acqImage] = ...
        PQC_readBuffer_intoFrame(0, state.spc.internal.corr, state.acq.pixelTime, isize, lineID, flag);
    
    %fprintf('Acuired line: %d\n', acqLine);
    if acqLines > 0
        siz = size(acqImage);
        acqImage = reshape(acqImage, [isize(1), nPixels, siz(2)/nPixels]);
        acqImage = permute(acqImage, [1, 3, 2]);
        siz = size(acqImage);
        %disp(siz);
        
        for ch = 1:nCh
            imageCh1{ch} = acqImage(:, 1 + (ch-1)*siz(2)/nCh : ch*siz(2)/nCh, :);
            imageCh2{ch} = imageCh1{ch};
            if startLine1 ~= 1
                saveImageCh = state.spc.internal.saveImage;
                imageCh2{ch}(:, 1, :) =  imageCh2{ch}(:, 1, :) + saveImageCh{ch}(:, end, :);
            end 
        end
        
        if state.acq.bidirectionalScan
            for ch = 1:nCh
                siz1 = size(imageCh2{ch});
                if mod(startLine1, 2) == 0
                    invertLine = 2:2:siz1(2);
                else
                    invertLine = 1:2:siz1(2)-1;
                end
                imageCh2{ch}(:, invertLine, :)  = imageCh2{ch}(:, invertLine, end:-1:1); 
            end
        end
        
        y1 = [1:acqLines];
        loc = y1 + startLine1 - 1;
        if startLine1 ~= 1
            %loc = loc - 1;
        end
        loc1 = mod(loc-1, state.acq.linesPerFrame)+1;
        frame1 = ceil(loc/state.acq.linesPerFrame);
%         disp([loc1(1), frame1(1), loc1(end)]);
        if focus
            frame1 = mod(frame1 - 1, nCh) + 1;
            f1 = 1:2;
            %imageCh2{ch} = sum(imageCh2{ch}, 1);
        else
            f1 = frame1(1):frame1(end);
        end
        
        for f = f1
            for ch = 1:nCh
                loc1A = loc1(frame1 == f);
                y2 = y1(frame1 == f);
                loc2 = loc1A + (ch-1) * state.acq.linesPerFrame;
                if focus
                    spc.stack.image1F{f}(:, loc2, :) = imageCh2{ch}(:, y2, :);
                else
                    spc.stack.image1{f}(:, loc2, :) = imageCh2{ch}(:, y2, :);
                end
            end
        end

        state.spc.internal.saveImage = imageCh1;
        state.spc.internal.lineCounter = state.spc.internal.lineCounter + acqLines;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%