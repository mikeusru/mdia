function spc_putData (recalc)
global state

if ~nargin
    recalc = 1;
end
if state.spc.acq.uncageBox == 0
    
    if recalc
        state.spc.acq.mirrorOutputData = makeMirrorDataOutput;
        state.spc.internal.spc_outData = spc_makeDataOutput(1, 1, 0);
    end
    
    if state.spc.acq.spc_takeFLIM
        putdata(state.spc.init.spc_ao, state.spc.internal.spc_outData);
    else
        putdata(state.spc.init.pockels_ao, state.spc.internal.spc_outData(:, 3:5));
    end
    putdata(state.init.ao2, state.spc.acq.mirrorOutputData);
    
else
    %%%%Effort to reduce memory usage!!)
    a = double(5);
    [LineOutput, frameOutput] = spc_makeFrameClock;
    LineOutput = a*double(LineOutput);
    frameOutput = a*double(frameOutput);
    frameLength = length(LineOutput);
    pixel_clock = [LineOutput(:), frameOutput(:)];
    a1 = find(frameOutput);
    startGood = a1(end)+1;
    
    ActualRateOutput2 = get(state.spc.init.spc_ao, 'SampleRate')/1000;
    reducedRate = 5000;
    reducedRate2 = reducedRate/1000;
    
    total_nSample10K = reducedRate * state.acq.msPerLine*state.acq.linesPerFrame*state.acq.numberOfFrames;  %10KHz   
    ratio12 = round(ActualRateOutput2 / reducedRate2);
    frameLength2 = frameLength / ratio12;
    
    pockelsOutput = spc_makeDataOutput(0, 1, 0);
    mirror_outData = makeMirrorDataOutput;
    
    PulsePos12Mark = false(total_nSample10K, 1);
    PulsePos3Mark = false(total_nSample10K, 1);
    LaserPosMark = zeros(total_nSample10K, 1, 'uint8');
    
    
    
    if ~isempty(findobj('Tag', '1'))
        laserP = state.yphys.init.eom.laserP;
        uncageP = state.yphys.init.eom.uncageP;
        para = state.yphys.acq.pulse{3, state.yphys.acq.pulseN};
        nstim = para.nstim;
        freq = para.freq;
        dwell = para.dwell;
        ampc = para.amp;
        delay = para.delay;
        sLength = para.sLength;       
        amp1 = state.init.eom.lut(laserP, 1);
        if state.init.eom.numberOfBeams > 1
            amp2 = state.init.eom.lut(uncageP, ampc);
        else
            amp2 = 0;
        end      
        if state.init.eom.numberOfBeams > 1
            sDelay = 6; %Shutter delay = 6 ms.
        else
            sDelay = 0;
        end
        mirrorDelay = 4;
        for roiN=1:nstim
            PulsePos12 = [round((delay+1000/freq*(roiN-1))*reducedRate2), ...
                round((delay+1000/freq*(roiN-1)+dwell)*reducedRate2)];
            PulsePos3 = [round((delay-sDelay+1000/freq*(roiN-1))*reducedRate2), ...
                round((delay+1000/freq*(roiN-1)+dwell)*reducedRate2)];
            LaserPos = [round((delay- mirrorDelay + 1000/freq*(roiN-1))*reducedRate2),...
                round((delay+1000/freq*(roiN-1)+dwell)*reducedRate2)];
            
            if PulsePos3(1) > 0 && PulsePos3(end) <= total_nSample10K
                    PulsePos12Mark(PulsePos12(1):PulsePos12(2)) = true;
                    PulsePos3Mark( PulsePos3(1):PulsePos3(2)) = true;
                    LaserPosMark(LaserPos(1):LaserPos(2)) = roiN;
            end
        end
        errorS = 1;
        NofRoi = 50;
        RoiCount = 0;
        for roiN = 1:NofRoi;
            [XY, err] = yphys_scanVoltage(roiN);
            if roiN == 1 && err == 1
                disp('You have to choose Roi1 !!!');
                return;
            elseif err
            elseif ~err
                RoiCount = RoiCount + 1;
                XYvol{RoiCount} = XY;
                error(RoiCount) = err;
            end
        end
        NofRoi = RoiCount;
        %roiN1 = mod(roiN-1, NofRoi)+1;
        LaserPosMark(LaserPosMark > 0) = mod(LaserPosMark(LaserPosMark > 0)-1 , NofRoi) + 1;
    else
        disp('You have to choose Roi1 !!!');
        NofRoi = 0;
    end
    
    %requiredFrames = ceil((delay + nstim*1000/freq) / (state.acq.msPerLine * state.acq.linesPerFrame * 1000));
    
    for i=1:state.acq.numberOfFrames
    %for i=1:requiredFrames
        pixel_clock1 = pixel_clock;
        if ~state.spc.acq.spc_average
                if i==1
                    pixel_clock1 (startGood:end, 2)= 0;
                else
                    pixel_clock1 (:, 2) = 0;
                end
        end
        
        pm12 = PulsePos12Mark(frameLength2*(i-1)+1 : frameLength2*i);
        pm3 = PulsePos3Mark(frameLength2*(i-1)+1 : frameLength2*i);
        lpm = LaserPosMark(frameLength2*(i-1)+1 : frameLength2*i);
        %
        pm12A = repmat(pm12, [1,ratio12])';
        pm12A = pm12A(:);
        pm3A =  repmat(pm3, [1,ratio12])';
        pm3A = pm3A(:);
        lpmA = repmat(lpm, [1,ratio12])';
        lpmA = lpmA(:);
        %
        pockelsOutput1 = pockelsOutput;
        if any(pm12A)
            pockelsOutput1 (pm12A, 1) = amp1; 
            pockelsOutput1 (pm12A, 2) = amp2;
        end
        if any(pm3A)
            pockelsOutput1 (pm3A, 3) = 0;
        end
        %
        mirror = mirror_outData;
        if any(lpmA)        
            for roiN=1:NofRoi
                mirror(lpmA==roiN, 1) = XYvol{roiN}(1);
                mirror(lpmA==roiN, 2) = XYvol{roiN}(2);
            end
        end
        
        if state.spc.acq.spc_takeFLIM
            putdata(state.spc.init.spc_ao, [pixel_clock1, pockelsOutput1]);
        else
            putdata(state.spc.init.pockels_ao, pockelsOutput1);
        end
        
        putdata(state.init.ao2, mirror);
    end
end


return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     spc_outData = spc_makeDataOutput(0, 0, 1);  %16bit.
%     mirror_outData = spc_makeMirrorOutput(1); %16bit
%     factor = 10/double(intmax('uint16')); %16bit calculation!!
% 
%     a = double(5);
%     [LineOutput, frameOutput] = spc_makeFrameClock;
%     LineOutput = a*double(LineOutput);
%     frameOutput = a*double(frameOutput);
%     framelength = length(LineOutput);
%     pixel_clock = [LineOutput(:), frameOutput(:)];
%     a1 = find(frameOutput);
%     startGood = a1(end)+1;
% 
%     numberOfMirrorFrames = length(mirror_outData) / framelength;
%     %state.spc.internal.mirror_outData = spc_makeMirrorOutput;
% 
% 
%     len1 = length(mirror_outData);
%     len2 = state.acq.msPerLine*state.acq.linesPerFrame*state.acq.numberOfFrames*state.acq.outputRate;
% 
%     pixel_clock1 = pixel_clock;
% 
%     for i=0:numberOfMirrorFrames -1    
%         if ~state.spc.acq.spc_average
%                 if i==0
%                     pixel_clock1 (startGood:end, 2)= 0;
%                 else
%                     pixel_clock1 (1:end, 2) = 0;
%                 end
%         end
%         pockel = factor*double(spc_outData(i*framelength + 1: i*framelength + framelength, :));
%         mirror = factor*double(mirror_outData(i*framelength + 1: i*framelength + framelength, :)); 
%         if state.spc.acq.spc_takeFLIM
%             putdata(state.spc.init.spc_ao, [pixel_clock1, pockel]);
%         else
%             putdata(state.spc.init.pockels_ao, [pockel]);
%         end
%         putdata(state.init.ao2, mirror);
%     end
% 
%     if len2 > len1
%         rest_of_frames = state.acq.numberOfFrames - numberOfMirrorFrames;
%         pockel1 = spc_makeDataOutput(0,1,0);
%         mirror = makeMirrorDataOutput;
%         pixel_clock1 = pixel_clock;
%         if ~state.spc.acq.spc_average
%                 pixel_clock1 (1:end, 2) = 0;
%         end    
%         for i=1:rest_of_frames
%             if state.spc.acq.spc_takeFLIM
%                 putdata(state.spc.init.spc_ao, [pixel_clock1, pockel1]);
%             else
%                 putdata(state.spc.init.pockels_ao, [pockel]);
%             end
%             putdata(state.init.ao2, mirror);
%         end
%     end
