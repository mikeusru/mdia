function yphys_patch
global state;
global gh;

out = timerfind('Tag', 'patch');

if isobject(out)
    stop(out);
    delete(out);
    notimer = 0;
else
    notimer = 1;
end

yphys_stopAll;


if notimer
    %yphys_setup;
    state.yphys.acq.vwidth = str2num(get(gh.yphys.scope.vwidth, 'String'));
    state.yphys.acq.cwidth = str2num(get(gh.yphys.scope.cwidth, 'String'));
    state.yphys.acq.vamplitude = str2num(get(gh.yphys.scope.vamp, 'String'));
    state.yphys.acq.camplitude = str2num(get(gh.yphys.scope.camp, 'String'));
    state.yphys.acq.vperiod = str2num(get(gh.yphys.scope.vperiod, 'String'));
    state.yphys.acq.cperiod = str2num(get(gh.yphys.scope.cperiod, 'String'));
    state.yphys.internal.fft_on = get(gh.yphys.scope.fft, 'value');
    if state.yphys.acq.vperiod < state.yphys.acq.vwidth*3/1000+0.2
        state.yphys.acq.vperiod = state.yphys.acq.vwidth*3/1000+0.2;
    end
    if state.yphys.acq.cperiod < state.yphys.acq.cwidth*3/1000+0.2
        state.yphys.acq.cperiod = state.yphys.acq.cwidth*3/1000+0.2;
    end
    if state.yphys.internal.fft_on
        if ~state.yphys.acq.cclamp
            state.yphys.acq.vamplitude = 0;
        else
            state.yphys.acq.camplitude = 0;
        end
    end
    yphys_getGain;
    pause(0.2);
    set(gh.yphys.scope.AutoS, 'Value', 1);
	if state.yphys.acq.cclamp
        state.yphys.acq.cphase = [state.yphys.acq.cwidth, state.yphys.acq.cwidth, state.yphys.acq.cwidth];    
		phase = state.yphys.acq.cphase*state.yphys.acq.outputRate/1000;
        a=zeros(phase(1), 1);
		a = [a; ones(phase(2), 1)];
		a = [a; zeros(phase(3), 1)];
        a = a*state.yphys.acq.camplitude/state.yphys.acq.commandSensC;
        timerperiod = state.yphys.acq.cperiod;
	else
        state.yphys.acq.vphase = [state.yphys.acq.vwidth, state.yphys.acq.vwidth, state.yphys.acq.vwidth];
		phase = state.yphys.acq.vphase*state.yphys.acq.outputRate/1000;    
        a=zeros(phase(1), 1);
		a = [a; ones(phase(2), 1)];
		a = [a; zeros(phase(3), 1)];
		a = a*state.yphys.acq.vamplitude/state.yphys.acq.commandSensV;
        timerperiod = state.yphys.acq.vperiod;
	end
    state.yphys.acq.patchdata = a; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    yphys_settingSpecific_patch;
    try
        axes (gh.yphys.scope.trace);
        gh.yphys.patchPlot = plot(zeros(32,1));
    end
    state.yphys.acq.patchAxes = gh.yphys.scope.trace;
    if ~state.yphys.internal.fft_on   
        xlabel(gh.yphys.scope.trace, 'Time (ms)')
    else
        xlabel(gh.yphys.scope.trace, 'Freq (Hz)')
    end
    
    if state.yphys.acq.cclamp
        ylabel(gh.yphys.scope.trace, 'Voltage (mV)');
    else
        ylabel(gh.yphys.scope.trace, 'Current (pA)');
    end
    if state.yphys.internal.fft_on  
        ylabel(gh.yphys.scope.trace, 'Power');
    end
    %set(gca, 'ButtonDownFcn', 'yphys_Patch');

    set(gh.yphys.scope.start, 'String', 'STOP');
    state.yphys.timer.patch_timer = timer('TimerFcn','yphys_patchLoop','ExecutionMode','fixedSpacing','Period',timerperiod, 'Tag','patch', 'BusyMode', 'Drop');    
    start(state.yphys.timer.patch_timer);
else
    stop(state.yphys.init.phys);
    stop(state.yphys.init.phys_patch);
    stop(state.yphys.init.phys_input);
%     try
%         stop(state.yphys.init.phys_setting);
%     end
    %putdata(state.yphys.init.phys_patch, zeros(50,1));
    %start(state.yphys.init.phys_patch);
    %trigger(state.yphys.init.phys_patch);
    %yphys_diotrigger;
    %axes(state.yphys.acq.patchAxes);
%     if get(state.yphys.init.phys_input, 'SamplesAvailable') >= get(state.yphys.init.phys_input, 'SamplesPerTrigger')
%         data1 = getdata(state.yphys.init.phys_input);
%     end
    set(gh.yphys.scope.start, 'String', 'START');
    try
        stop(state.yphys.timer.patch_timer);
    end
    delete(state.yphys.timer.patch_timer);
end



function yphys_settingSpecific_patch
global state;
a=state.yphys.acq.patchdata;
nSamples = round(length(a)*state.yphys.acq.inputRate/state.yphys.acq.outputRate);
%state.yphys.init.phys_inputPatch.set('everyNSamples', nSamples);
state.yphys.init.phys_inputPatch.set('sampQuantSampPerChan', nSamples);
state.yphys.init.phys_patch.set('sampQuantSampPerChan', nSamples);
%state.yphys.init.phys_inputPatch.set('everyNSamplesEventCallbacks', @yphys_getData_patch);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%