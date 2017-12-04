function yphys_generic
global state
global gh

handles = gh.yphys.stimScope;
if ~ishandle(handles.nstim)
    return;
end
Radio_on = Radiobutton_values(handles);

nstim = str2num(get(handles.nstim, 'String'));
freq = str2num(get(handles.freq, 'String'));
dwell = str2num(get(handles.dwell, 'String'));
amp = str2num(get(handles.amp, 'String'));
delay = str2num(get(handles.delay, 'String'));
%
sLength = str2num(get(handles.Length, 'String'));
ntrain = str2num(get(handles.ntrain, 'String'));
interval = str2num(get(handles.interval, 'String'));

ext = get(handles.ext, 'Value');
ap = get(handles.ap, 'Value');
stim = get(handles.Stim, 'Value');
uncage=get(handles.Uncage, 'Value');
theta = get(handles.theta, 'Value');
saveCheck = get(handles.saveCheck, 'Value');
pulseN = str2num(get(handles.pulseN, 'String'));
epochN = str2num(get(handles.epochN, 'String'));
addP = str2num(get(handles.AddPulse, 'String'));
pulseName = get(handles.pulseName, 'String');

state.yphys.acq.freq = freq;
state.yphys.acq.nstim = nstim;
state.yphys.acq.dwell = dwell;
state.yphys.acq.amp = amp;
state.yphys.acq.delay = delay;
state.yphys.acq.ext = ext;
state.yphys.acq.ap = ap;
state.yphys.acq.stim = stim;
state.yphys.acq.uncage = uncage;
state.yphys.acq.theta = theta;
state.yphys.acq.autoSave = saveCheck;
state.yphys.acq.addP = addP;
state.yphys.acq.pulseN = pulseN;
state.yphys.acq.epochN = epochN;
state.yphys.acq.cycleSet = str2num(get(gh.yphys.stimScope.cycleSet, 'String'));
%
state.yphys.acq.sLength(pulseN) = sLength;
state.yphys.acq.ntrain(pulseN) = ntrain;
state.yphys.acq.interval(pulseN) = interval;
state.yphys.acq.pulseName{pulseN} = pulseName;

if find(Radio_on)
	switch find(Radio_on)
        case 1
                yphys_mkPulse(freq, nstim, dwell, amp, delay, sLength, addP, 'ap');
        case 2
                yphys_mkPulse(freq, nstim, dwell, amp, delay, sLength, addP, 'stim');
        case 3
                yphys_mkPulse(freq, nstim, dwell, amp, delay, sLength, addP, 'uncage');
        otherwise
	end
    %evalc(['state.yphys.acq.pulse', num2str(find(Radio_on)), '_', num2str(pulseN), '=[freq, nstim, dwell, amp, delay, sLength]']);
    state.yphys.acq.pulse{find(Radio_on), pulseN}.freq = freq;
    state.yphys.acq.pulse{find(Radio_on), pulseN}.nstim = nstim;
    state.yphys.acq.pulse{find(Radio_on), pulseN}.dwell = dwell;
    state.yphys.acq.pulse{find(Radio_on), pulseN}.amp = amp;
    state.yphys.acq.pulse{find(Radio_on), pulseN}.delay = delay;
    state.yphys.acq.pulse{find(Radio_on), pulseN}.sLength = sLength;
    state.yphys.acq.pulse{find(Radio_on), pulseN}.addP = addP;
end

yphys_setupParameters;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function on = Radiobutton_values (handles)


on(1) = get(handles.PatchRadio, 'Value');
on(2) = get(handles.StimRadio, 'Value');
on(3) = get(handles.UncageRadio, 'Value');
