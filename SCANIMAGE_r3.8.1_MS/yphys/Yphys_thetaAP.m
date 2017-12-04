function Yphys_thetaAP %(AmpFactor, nstimIn, delaytime, ext);
%dwell in milisecond.

global state;
global gh;

yphys_setup;
yphys_getGain;

ext = get(gh.yphys.stimScope.ext, 'value');
ap = get(gh.yphys.stimScope.ap, 'value'); %state.yphys.acq.ap;
uncage=get(gh.yphys.stimScope.Uncage, 'value');   %state.yphys.acq.uncage;
stim = get(gh.yphys.stimScope.Stim, 'value');

if ap
    param = state.yphys.acq.pulse{1,state.yphys.acq.pulseN};
else
    param = state.yphys.acq.pulse{2,state.yphys.acq.pulseN};
end

rate = param.freq;
nstim = param.nstim;
dwell = param.dwell;
amp = param.amp;
delay = param.delay;
sLength = param.sLength;
nstimIn = 5;

if ~state.yphys.acq.cclamp
    disp('Set to Current Clamp !!!');
    return;
end

if ap
    a = yphys_mkPulse(rate, nstim, dwell, amp, 1, sLength, 'ap');
else
    a = yphys_mkPulse(rate, nstim, dwell, amp, 1, sLength, 'stim');
end

a = repmat(a, [nstimIn, 1]);
% blank = zeros(round(delaytime*outputRate/1000), 1);
% a = [blank; a; blank];

if ap  %%%ap means patch clamp!!!!!!
    if ~state.yphys.acq.cclamp
        a = a/state.yphys.acq.commandSensV;
    else
        a = a/state.yphys.acq.commandSensC;
	end

	set(state.yphys.init.phys_patch, 'SampleRate', state.yphys.acq.outputRate);
	set(state.yphys.init.phys_patch, 'RepeatOutput', 0); 

else

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%input setting.
set(state.yphys.init.phys_input, 'SamplesPerTrigger', round(length(a)*state.yphys.acq.inputRate/state.yphys.acq.outputRate));
set(state.yphys.init.phys_input, 'StopFcn', 'yphys_getData');


state.yphys.acq.physOutputData = a;
state.spc.yphys.triggertime = datenum(now);

if ap
    putdata(state.yphys.init.phys_patch, a(:));
    state.yphys.internal.waiting = 1;
    start([state.yphys.init.phys_patch, state.yphys.init.phys_input]);
    if ~ext
		yphys_diotrigger;
	end
else
	putdata(state.yphys.init.phys, a(:));
    state.yphys.internal.waiting = 1;
	start([state.yphys.init.phys, state.yphys.init.phys_input]);
    if ~ext
        yphys_diotrigger;
    end
end