function yphys_setupParameters
global state;
global gh;
handles = gh.yphys.stimScope;
Radio_on = Radiobutton_values(handles);
pulseN = str2num(get(handles.pulseN, 'String'));
try
    pulseName = state.yphys.acq.pulseName{pulseN};
catch
    pulseName = 'pulseName';
end
try
    sLength = state.yphys.acq.sLength(pulseN);
    if sLength == 0
        sLength = 250;
    end
catch
    sLength = 250;
end
try
    interval = state.yphys.acq.interval(pulseN);
    if interval == 0
        interval = 5;
    end
catch
    interval = 5;
end
try
    ntrain = state.yphys.acq.ntrain(pulseN);
    if ntrain == 0
        ntrain = 1;
    end
catch
    ntrain= 1;
end

stimtype = find(Radio_on);

for i=1:3
    try
		freq = state.yphys.acq.pulse{i, pulseN}.freq;
		nstim = state.yphys.acq.pulse{i, pulseN}.nstim;
		dwell = state.yphys.acq.pulse{i, pulseN}.dwell;
		amp = state.yphys.acq.pulse{i, pulseN}.amp;
		delay = state.yphys.acq.pulse{i, pulseN}.delay;
		%sLength = state.yphys.acq.pulse{i, pulseN}.sLength;
        if ~isfield(state.yphys.acq.pulse{i, pulseN}, 'addP')
            state.yphys.acq.pulse{i, pulseN}.addP = -1;
            addP = -1;
        else
            addP = state.yphys.acq.pulse{i, pulseN}.addP;
        end
    catch
        state.yphys.acq.pulse{i, pulseN}.freq = 50;
        state.yphys.acq.pulse{i, pulseN}.nstim = 1;
        state.yphys.acq.pulse{i, pulseN}.dwell = 100;
        state.yphys.acq.pulse{i, pulseN}.amp = 1;
        state.yphys.acq.pulse{i, pulseN}.delay = 50;
        %state.yphys.acq.pulse{i, pulseN}.sLength = 250;
        state.yphys.acq.pulse{i, pulseN}.addP = -1;
        %
        freq = state.yphys.acq.pulse{i, pulseN}.freq;
		nstim = state.yphys.acq.pulse{i, pulseN}.nstim;
		dwell = state.yphys.acq.pulse{i, pulseN}.dwell;
		amp = state.yphys.acq.pulse{i, pulseN}.amp;
		delay = state.yphys.acq.pulse{i, pulseN}.delay;
		%sLength = state.yphys.acq.pulse{i, pulseN}.sLength;
        addP = state.yphys.acq.pulse{i, pulseN}.addP;
    end

    switch i
		case 1
            yphys_mkPulse(freq, nstim, dwell, amp, delay, sLength, addP, 'ap');
		case 2
            yphys_mkPulse(freq, nstim, dwell, amp, delay, sLength, addP, 'stim');
		case 3
            yphys_mkPulse(freq, nstim, dwell, amp, delay, sLength, addP, 'uncage');
		otherwise
    end
end

freq = state.yphys.acq.pulse{stimtype, pulseN}.freq;
nstim = state.yphys.acq.pulse{stimtype, pulseN}.nstim;
dwell = state.yphys.acq.pulse{stimtype, pulseN}.dwell;
amp = state.yphys.acq.pulse{stimtype, pulseN}.amp;
delay = state.yphys.acq.pulse{stimtype, pulseN}.delay;
addP = state.yphys.acq.pulse{i, pulseN}.addP;
%
%sLength = state.yphys.acq.pulse{stimtype, pulseN}.sLength;


set(handles.freq, 'String', num2str(freq));
set(handles.amp, 'String', num2str(amp));
set(handles.nstim, 'String', num2str(nstim));
set(handles.dwell, 'String', num2str(dwell));
set(handles.delay, 'String', num2str(delay));
set(handles.AddPulse, 'String', num2str(addP));
%
set(handles.interval, 'String', num2str(interval));
set(handles.ntrain, 'String', num2str(ntrain));
set(handles.Length, 'String', num2str(sLength));
set(handles.pulseName, 'String', pulseName);
state.yphys.acq.radio_on = Radiobutton_values (handles);


%%%%%%%%%%%%%%%%%%%%%%%%
function on = Radiobutton_values (handles)

on(1) = get(handles.PatchRadio, 'Value');
on(2) = get(handles.StimRadio, 'Value');
on(3) = get(handles.UncageRadio, 'Value');