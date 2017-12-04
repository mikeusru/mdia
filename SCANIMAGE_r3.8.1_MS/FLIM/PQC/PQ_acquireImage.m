function PQ_acquireImage
global state gh spc

if strcmp(get(gh.mainControls.focusButton, 'String'), 'ABORT')
    focus = 1;
else
    focus = 0;
end

maxLifetime = state.spc.acq.SPCdata.adc_resolution - 1;

value = state.spc.internal.hPQ.readBuffer;

if state.spc.internal.lineCounter == 0
    values = value;
else
    values = [state.spc.internal.previousLine, value];
end
[true_nsyncA, channelA, specialA, dtimeA, eventsA] = PQ_read(values);
photons = dtimeA(specialA == 0);
nPhoton = length(photons);
lifetime = mean(photons*250);
nEvents = sum(eventsA);
chars = dec2bin(channelA);
photonEvents = specialA == 0;

%pixels = (chars(:,6) == '1' & chars(:,1) == '0');
try
    lines = (chars(:,4) == '1' & chars(:,1) == '0');
    frames = (chars(:,3) == '1' & chars(:,1) == '0');
catch
    return;
end

lineN = find(lines);
lineC = cumsum(lines)';

if ~numel(lineN) || isempty(lines)
    no_line = 1;
    %disp('No line');
else
    no_line = 0;
end

if ~no_line
    lineC(lineC == 0) = 1;
    try
        diff2 = true_nsyncA - true_nsyncA(lineN(lineC));
    catch
       display('**********************************')
       display('**********************************')
       warning('Problem in image acquisition. Report to Ryohei!');
       fprintf('Size true_nsyncA %d, lineC(end) %d\n',  length(true_nsyncA), lineC(end));
    end
    if length(lineN) > 3
        state.spc.internal.lineSpace = round(mean(true_nsyncA(lineN(2:3))-true_nsyncA(lineN(1:2))));
    end
else
    diff2 = true_nsyncA*0;
end

if state.spc.internal.lineCounter == 0
    if ~no_line
        diff2(1:lineN(1)-1) = -1;
        photonEvents(1:lineN(1)-1) = 0;
    else
        return;
    end
end
%fprintf('N-photon = %d, line = %d\n', sum(photonEvents(:)), state.spc.internal.lineCounter);

state.spc.internal.previousLine = values(lineN(end):end);

%fprintf('%d, %d\n', lineN(1), lineN(end));
if ~focus
    NFrames = state.acq.numberOfFrames;
else
    NFrames = 2;
end

x_all = diff2(photonEvents);
t1_all = dtimeA(photonEvents);
y_all = lineC(photonEvents);
ch_all = channelA(photonEvents);

for ch = 0:state.spc.acq.SPCdata.n_channels-1
    for y = 1:lineC(end)
        if (y ~= lineC(end)) | (y == lineC(end) & ...
                state.acq.linesPerFrame*NFrames == state.spc.internal.lineCounter + lineC(end))
            x = x_all(y_all == y & ch_all == ch);
            t1 = t1_all(y_all == y & ch_all == ch);
            %ch = ch_all(y_all == y);
            frac1 = 0; %(state.acq.scanDelay + state.acq.acqDelay)/state.acq.msPerLine * 1000 - 0.09;
            frac2 = state.acq.fillFraction+frac1;
            edgex = [0,frac1:(frac2-frac1)/(state.acq.pixelsPerLine):frac2, 1]*state.spc.internal.lineSpace;
            edget = [0:maxLifetime];
            cct = hist3([t1(:), x(:)], 'Edges', {edget, edgex});
            cct = cct(:, 2:end-2);
            siz = size(cct);
            cct = reshape(cct, [siz(1), 1, siz(2)]);
            y2 = y + state.spc.internal.lineCounter + 1;
            frame = ceil(y2 / state.acq.linesPerFrame);
            y3 = y2 - (frame-1) * state.acq.linesPerFrame;
            if focus
                frame = mod(frame-1, 2) + 1;
            end
            if frame <= NFrames
                %spc.stack.stackF(:, y3+ch*state.acq.linesPerFrame, :, frame) = cct; 
                spc.stack.image1{frame}(:, 3+ch*state.acq.linesPerFrame, :) = cct;
            end
        end
    end
end

if state.acq.linesPerFrame*NFrames == state.spc.internal.lineCounter + lineC(end)
    state.spc.internal.lineCounter = state.spc.internal.lineCounter + lineC(end);
else
    state.spc.internal.lineCounter = state.spc.internal.lineCounter + lineC(end)-1;
end



%fprintf('%d\n', state.spc.internal.lineCounter);