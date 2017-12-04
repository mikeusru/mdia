function [spc_finalDataOutput, shutterOut] = spc_makeDataOutput()

global state


uncageP = state.yphys.init.eom.uncageP;
data1 = makePockelsCellDataOutput(state.init.eom.grabLaserList, 1);
data2 = data1;
if ~state.spc.acq.spc_average
    if state.spc.acq.uncageBox
        if state.spc.init.infinite_Nframes && ~strcmp(state.spc.init.dllname, 'TH260lib')
            for beamCounter=1:state.init.eom.numberOfBeams %EVERY OTHER FRAME.
                data2(:, beamCounter)=data1(:, beamCounter)*0 + state.init.eom.lut(beamCounter, state.init.eom.min(beamCounter));
            end

            if state.spc.init.numSlicesPerFrames > 1
                if state.spc.acq.spc_takeFLIM
                    data2 = repmat(data2, [state.spc.init.numSlicesPerFrames-1, 1]);
                else
                    data2 = data1;
                end
            end
            spc_finalDataOutput = repmat([data1; data2], [round(state.acq.numberOfFrames/state.spc.init.numSlicesPerFrames), 1]); 
        else
            spc_finalDataOutput = repmat(data1, [state.acq.numberOfFrames, 1]);        
        end
        %Put minimum values for uncaging laser throughout the protocol.
        spc_finalDataOutput(:, uncageP) =  state.init.eom.lut(uncageP, state.init.eom.min(uncageP));
        shutterOut = spc_finalDataOutput(:, 1)*0 + state.yphys.shutter.close;

        if ~isempty(findobj('Tag', '1'))
            pulse0 = yphys_mkPulse;
            pulse1 = pulse0 > 1; %%Note: 1 is minimum value.
            dPulse = diff(pulse1);
            pOn = find(dPulse > 0);
            pOff = find(dPulse < 0);
            pulseOn = round (pOn * state.acq.outputRate / state.yphys.acq.outputRate);
            pulseOff = round (pOff * state.acq.outputRate / state.yphys.acq.outputRate);
            nstim = length(pulseOn);
            sDelay = state.yphys.init.shutter_delay;
            
            for roiN = 1:nstim
                PulsePos12 = pulseOn(roiN):pulseOff(roiN);
                PulsePos3 = pulseOn(roiN) - round(sDelay*state.acq.outputRate /1000) : pulseOff(roiN);
                if PulsePos3(1) > 0 && PulsePos3(end) <= size(spc_finalDataOutput, 1)
                    for beamCounter=1:state.init.eom.numberOfBeams
                        lutVal = state.init.eom.lut(beamCounter, state.init.eom.min(beamCounter));
                        spc_finalDataOutput(PulsePos3, beamCounter) = lutVal;
                    end
                    
                    ampc = pulse0(pOn(roiN)+1);
                    uncageVal = state.init.eom.lut(uncageP, ampc);
                    spc_finalDataOutput(PulsePos12, uncageP) = uncageVal;
                    shutterOut(PulsePos3) = state.yphys.shutter.open;
                end                
            end

        else
            disp('Position error');
        end
    else %UncageBox;
        if strcmp(state.spc.init.dllname, 'TH260lib')
            spc_finalDataOutput = data1;
        else
            for beamCounter=1:state.init.eom.numberOfBeams
                data2(:, beamCounter)=data1(:, beamCounter)*0 + state.init.eom.lut(beamCounter, state.init.eom.min(beamCounter));
            end
            if state.spc.init.numSlicesPerFrames > 1 
                data2 = repmat(data2, [state.spc.init.numSlicesPerFrames-1, 1]);
            end
            spc_finalDataOutput = [data1; data2];
        end        
        shutterOut = spc_finalDataOutput(:, 1)*0 + state.yphys.shutter.close;
    end
else
    spc_finalDataOutput = data1;
    shutterOut = data1(:, 1)*0 + state.yphys.shutter.close;
end
