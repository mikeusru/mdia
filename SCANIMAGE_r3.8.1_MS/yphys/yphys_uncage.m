function yphys_uncage (page)
%dwell in milisecond.
global state;
global gh;


%%%%%%%%%%%
bleaching = 0;  %%% If you want to bleach sample during uncaging, put 1.
bleachingP = 100;
%%%%%%%%%%%


laserP = state.yphys.init.eom.laserP;
uncageP = state.yphys.init.eom.uncageP;
shutter_delay = state.yphys.init.shutter_delay;


if ~nargin
    page = 0;
end

yphys_stopAll;
si_parkOrPointLaser('soft');

param = state.yphys.acq.pulse{3,state.yphys.acq.pulseN};
rate = param.freq;
nstim = param.nstim;
dwell = param.dwell;
ampc = param.amp;
delay = param.delay;
if ampc > 99
    ampc = 99;
elseif ampc < 1
    ampc = 1;
end

sLength = state.yphys.acq.sLength(state.yphys.acq.pulseN);
if isfield(param, 'addP')
    addP = param.addP;
else
    addP = -1;
end
%%%%%%%%%%%%%%%%%

ap = get(gh.yphys.stimScope.ap, 'value'); %state.yphys.acq.ap;
stim = get(gh.yphys.stimScope.Stim, 'value');


%Uncaging setup;
if ~page
    yphys_getGain;
end
%%%%%%%%%%%%%%%%%%%
amp2 = 5;
pockelsOutput2 = yphys_mkPulse(rate, nstim, dwell, amp2, delay, sLength, addP, 'uncage');
%Temporal output2 to define length and so on.

%%%%%%%%%%%%%%%%%%%%%%%%

pockelsOutput3_A = pockelsOutput2 > 1;
dxx = diff(pockelsOutput3_A);
startPs = find(dxx > 0);
endPs = find(dxx < 0);
startPs = round(startPs - shutter_delay/1000*state.yphys.acq.outputRate);
startPs(startPs < 1) = 1;
for i=1:length(startPs)
    if length(endPs) < length(startPs)
        endPs(end+1) = length(pockelsOutput3_A);
    end
    pockelsOutput3_A(startPs(i):endPs(i)) = 1;
end


if state.yphys.shutter.open == 0
    pockelsOutput3_tmp = amp2*(1 - pockelsOutput3_A);
else
    pockelsOutput3_tmp = amp2*(pockelsOutput3_A);
end
pockelsOutput3 = state.yphys.shutter.close*ones(length(pockelsOutput2), 1);
pockelsOutput3(1:length(pockelsOutput3_tmp)) = pockelsOutput3_tmp;


state.yphys.acq.uncaging_amp = ampc; %Percent amplitude for uncaging.
pockelsOutput2_t = pockelsOutput2; %050 signal.

if state.init.eom.numberOfBeams > 1
%     pockelsOutput2 = state.init.eom.lut(uncageP, state.init.eom.min(uncageP)) * ones(length(pockelsOutput2_t), 1);
%     pockelsOutput2(pockelsOutput2_t > 0) = state.init.eom.lut(uncageP, ampc); 
    pockelsOutput2 = yphys_mkPulse(rate, nstim, dwell, ampc, delay, sLength, addP, 'uncage');
    pockelsOutput2 = state.init.eom.lut(uncageP, pockelsOutput2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (ap || stim) 
        yphys_putSampleStim; %Put sample for Ephys.
end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %input setting.
    %get(state.yphys.init.phys_input);
    %set(state.yphys.init.phys_input, 'TriggerType', 'HwDigital');
    nSamples = round(length(pockelsOutput2)*state.yphys.acq.inputRate / state.yphys.acq.outputRate);    
    if state.yphys.init.yphys_on && (~page)
        state.yphys.init.phys_input.set('sampClkRate', state.yphys.acq.inputRate);
        state.yphys.init.phys_input.set('sampQuantSampPerChan', nSamples);
    end
    %set(state.yphys.init.phys_input, 'everyNSamples', nSamples);
    %set(state.yphys.init.phys_input, 'everyNSamplesEventCallbacks', @yphys_getData);
    %set(state.yphys.init.phys_input, 'BufferingConfig', [nSample, 2]);
    %set(state.yphys.init.phys_input, 'doneEventCallbacks', @yphys_getData);
    
if ~page    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Image acquisition
    nSamples = round(length(pockelsOutput2)*state.acq.inputRate / state.yphys.acq.outputRate);
    %state.yphys.init.acq_ai.set('sampClkRate', state.acq.inputRate );
    %state.yphys.init.acq_ai.set('sampQuantSampPerChan',nSamples);
    state.yphys.acq.data_On = [delay * state.acq.inputRate/1000, (delay+dwell)*state.acq.inputRate/1000];
else
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Put pockels value to 0 or 100.

if bleaching
    state.yphys.init.laser_ao.writeAnalogData(state.init.eom.lut(laserP, bleachingP), 1, true);
else
    state.yphys.init.laser_ao.writeAnalogData(state.init.eom.lut(laserP, state.init.eom.min(laserP)), 1, true);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.yphys.init.pockels_aoPark.writeAnalogData(state.init.eom.lut(uncageP, state.init.eom.min(uncageP)), 1, true); 
state.yphys.init.shutterAOPark.writeAnalogData(state.yphys.shutter.close, 1, true);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Set scanning positions.
XY = [0, 0];
XYvol = {};

errorS = 1;
NofRoi = 50;
RoiCount = 0;
for roiN = 1:NofRoi;
	[XY, err] = yphys_scanVoltage(roiN, 1);
    if roiN == 1 && err == 1
        disp('You have to choose Roi1 !!!');
        RoiCount = RoiCount + 1;
        XYvol{RoiCount} = [0, 0];
        error(RoiCount) = err;
        %return;
    elseif err

    elseif ~err
        RoiCount = RoiCount + 1;
        XYvol{RoiCount} = XY;
        error(RoiCount) = err;
    end
end
if isempty(XYvol)
    disp('***************Choose ROI****************');
    return;
end


%XYvol
state.yphys.acq.uncage = 1;
state.yphys.acq.XYvol = XYvol;
state.yphys.init.scan_aoPark.writeAnalogData(XYvol{1}, 1, true);
scanOutX = XYvol{1}(1)*ones(length(pockelsOutput2), 1);
scanOutY = XYvol{1}(2)*ones(length(pockelsOutput2), 1);
%RoiCount
if RoiCount >= 2 && nstim >= 2
    for stimCount=2:nstim
        if nstim > RoiCount
            roiN = mod(stimCount-1, RoiCount)+1;
        elseif RoiCount <= nstim
            roiN = stimCount;
        end
        swtichPosition = round(state.yphys.acq.outputRate/1000*(delay + (stimCount-2)*(1/rate*1000) + dwell));
        if swtichPosition < length(scanOutX)
            scanOutX(swtichPosition+1:end) = XYvol{roiN}(1);
            scanOutY(swtichPosition+1:end) = XYvol{roiN}(2);
        end
    end
end
% debug = 0; %%%Create a graph for x, y and shuttering.
% if debug
%     fh = gh.yphys.figure.stim_graph;
%     if ~ishandle (fh)
%         gh.yphys.figure.stim_graph = figure;
%     else
%         figure(fh);
%     end
%     plot(pockelsOutput2/5);
%     hold on;
%     plot(scanOutX, '-r');
%     plot(scanOutY, '-g');
%     plot(pockelsOutput3/50);
%     hold off;
% end

state.yphys.acq.scanOutput = [scanOutX,scanOutY];
%
state.yphys.init.scan_ao.writeAnalogData(state.yphys.acq.scanOutput);
%
state.yphys.init.scan_ao.cfgSampClkTiming(state.yphys.acq.outputRate, 'DAQmx_Val_FiniteSamps', state.yphys.init.scan_ao.get('bufOutputBufSize'));
% state.yphys.init.scan_ao.set('sampClkRate', state.yphys.acq.outputRate);
% state.yphys.init.scan_ao.set('sampQuantSampPerChan', size(state.yphys.acq.scanOutput, 1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


state.yphys.acq.uncagePercentPulses = yphys_mkPulse(rate, nstim, dwell, ampc, delay, sLength, addP, 'uncage');
state.yphys.acq.uncageOutputData = pockelsOutput2(:);
state.yphys.acq.shutterOutputData = pockelsOutput3(:);

state.yphys.init.pockels_ao.writeAnalogData([state.yphys.acq.uncageOutputData, state.yphys.acq.shutterOutputData]);
state.yphys.init.pockels_ao.cfgSampClkTiming(state.yphys.acq.outputRate, 'DAQmx_Val_FiniteSamps', state.yphys.init.pockels_ao.get('bufOutputBufSize'));
% state.yphys.init.pockels_ao.set('sampClkRate', state.yphys.acq.outputRate);
% state.yphys.init.pockels_ao.set('sampQuantSampPerChan', size(state.yphys.acq.uncageOutputData, 1));

%state.yphys.init.shutterAO.writeAnalogData(state.yphys.acq.shutterOutputData);
%state.yphys.init.shutterAO.cfgSampClkTiming(state.yphys.acq.outputRate, 'DAQmx_Val_FiniteSamps', state.yphys.init.shutterAO.get('bufOutputBufSize'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.yphys.init.pockels_ao.start();
state.yphys.init.scan_ao.start();
if state.yphys.init.yphys_on && get(gh.yphys.stimScope.saveCheck, 'value') && (~page)
    state.yphys.init.phys_input.start();
end
if ~page
    %state.yphys.init.acq_ai.start();
end

if (ap || stim) %&& state.yhys.init.yphys_on
    state.yphys.init.phys_both.start();
end


state.spc.yphys.triggertime = datestr(now, 'yyyy-mmm-dd, HH:MM:SS:FFF');
if ~state.yphys.acq.ext
    openShutter;
    dioTrigger;
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~ state.yphys.init.yphys_on || page
    pause(sLength/1000);
    closeShutter;
    yphys_stopAll;
    state.yphys.internal.waiting = 0;
    set(gh.yphys.stimScope.start, 'Enable', 'On');
end


