function Yphys_trainAP(rate, nstim, AmpFactor);
%dwell in milisecond.

global state;

if ~nargin
    AmpFactor = 1;
end

Amplitude = 1000*AmpFactor; %pA
outputRate = state.yphys.acq.outputRate; %2000; %dwell = 0.5ms.
pulsedwell = 2; %msecond
pulsewidth = pulsedwell/1000*outputRate;
thetatime = 0.2;


%yphys_setup;
yphys_getGain;

if ~state.yphys.acq.cclamp
    disp('Set to Current Clamp !!!');
    return;
end

set(state.yphys.init.phys_patch, 'SampleRate', outputRate);
set(state.yphys.init.phys_patch, 'RepeatOutput', 0); 
%samplelength = ceil(state.acq.outputRate*seconds);
binfactor = round(outputRate/ rate);
a = zeros(binfactor, 1);
a(1:pulsewidth) = Amplitude/2000;
a = repmat(a, nstim, 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%input setting.
set(state.yphys.init.phys_input, 'SamplesPerTrigger', round(length(a)*state.yphys.acq.inputRate/outputRate*1.2));
set(state.yphys.init.phys_input, 'StopFcn', 'yphys_getData');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

putdata(state.yphys.init.phys_patch, a(:));

start([state.yphys.init.phys_patch, state.yphys.init.phys_input]);
state.spc.yphys.triggertime = datenum(now);
trigger([state.yphys.init.phys_input, state.yphys.init.phys_patch]);
%