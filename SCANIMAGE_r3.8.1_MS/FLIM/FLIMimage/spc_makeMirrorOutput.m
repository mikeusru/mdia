function spc_makeMirrorOutput()
global state

makeMirrorDataOutput();
%state.acq.mirrorDataOutput = repmat(state.acq.mirrorDataOutput, [state.acq.numberOfFrames, 1]);
if state.spc.acq.spc_average
    return;
end



if ~state.spc.acq.uncageBox
    state.acq.mirrorDataOutputOrg = repmat(state.acq.mirrorDataOutputOrg, [state.acq.numberOfFrames, 1]);
else
    state.acq.mirrorDataOutputOrg = repmat(state.acq.mirrorDataOutputOrg, [state.acq.numberOfFrames, 1]);
    if ~isempty(findobj('Tag', '1'))
        %Set scanning positions.
        XY = [0, 0];
        errorS = 1;
        NofRoi = 50;
        RoiCount = 0;
        for roiN = 1:NofRoi;
            [XY, err] = yphys_scanVoltage(roiN, 0);
            if roiN == 1 && err == 1
                disp('You have to choose Roi1 !!!');
                return;
            elseif err
                %disp(sprintf('Error in ROI #%d', roiN));
            elseif ~err
                RoiCount = RoiCount + 1;
                XYvol{RoiCount} = XY;
                error(RoiCount) = err;
            end
        end

        pulse1 = yphys_mkPulse > 1; %%Note: 1 is minimum value.
        dPulse = diff(pulse1);
        pulseOn = round (find(dPulse > 0) * state.acq.outputRate / state.yphys.acq.outputRate);
        pulseOff = round (find(dPulse < 0) * state.acq.outputRate / state.yphys.acq.outputRate);
        nstim = length(pulseOn);
        sDelay = state.yphys.init.shutter_delay;

        for roiN = 1:nstim
            PulsePos3 = pulseOn(roiN) - round(sDelay*state.acq.outputRate /1000) : pulseOff(roiN) ;
            if PulsePos3(1) > 0 && PulsePos3(end) <= size(state.acq.mirrorDataOutputOrg, 1)
                roiN2 = mod(roiN-1, RoiCount)+1;
                for xyCounter=1:2
                    state.acq.mirrorDataOutputOrg(PulsePos3, xyCounter) = XYvol{roiN2}(xyCounter);
                end
            end              
        end
%         para = state.yphys.acq.pulse{3, state.yphys.acq.pulseN};
%         nstim = para.nstim;
%         freq = para.freq;
%         dwell = para.dwell;
%         ampc = para.amp;
%         delay = para.delay;
%         sLength = para.sLength;        
%         sDelay = state.yphys.init.shutter_delay; %~4 ms.
%         
%         for roiN=1:nstim
%             %PulsePos12 = round((delay+1000/freq*(roiN-1))*state.acq.outputRate/1000) : round((delay+1000/freq*(roiN-1)+dwell)*state.acq.outputRate/1000);
%             PulsePos3 = round((delay-sDelay+1000/freq*(roiN-1))*state.acq.outputRate/1000) : round((delay+1000/freq*(roiN-1)+dwell)*state.acq.outputRate/1000);
%             if PulsePos3(1) > 0 && PulsePos3(end) <= size(state.acq.mirrorDataOutputOrg, 1)
%                 roiN2 = mod(roiN-1, RoiCount)+1;
%                 for xyCounter=1:2
%                     state.acq.mirrorDataOutputOrg(PulsePos3, xyCounter) = XYvol{roiN2}(xyCounter);
%                 end
%             end
%         end
    else
        disp('Position error');
    end
end
