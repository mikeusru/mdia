function Yphys_theta;
%dwell in milisecond.

global state;

nstim=10;
nstimIn=10;
rate = 100;
Dhight = 5.05;
outputRate = 2000; %dwell = 0.5ms.
thetatime = 0.2;

yphys_setup;
yphys_getGain;

set(state.yphys.init.phys, 'SampleRate', outputRate);
set(state.yphys.init.phys, 'RepeatOutput', nstim); 
%samplelength = ceil(state.acq.outputRate*seconds);
binfactor = round(outputRate/ rate);
a = zeros(binfactor, 1);
a(1) = Dhight;

a = repmat(a, nstimIn, 1);
blank = zeros(outputRate*thetatime-length(a), 1);
a= [a; blank];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%input setting.
set(state.yphys.init.phys_input, 'SampleRate', state.yphys.acq.inputRate);
state.yphys.init.phys_data = addchannel(state.yphys.init.phys_input, state.yphys.init.phys_dataIndex);
set(state.yphys.init.phys_input, 'SamplesPerTrigger', round(length(a)*state.yphys.acq.inputRate/outputRate*nstim*1.2));
set(state.yphys.init.phys_input, 'StopFcn', 'yphys_getData');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

putdata(state.yphys.init.phys, a(:));

start([state.yphys.init.phys, state.yphys.init.phys_input]);
trigger([state.yphys.init.phys_input, state.yphys.init.phys]);
%