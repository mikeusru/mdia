function yphys_patchLoop
global state;

try
    a = state.yphys.acq.patchdata;

    yphys_getGain;
    yphys_stopAll;
    %input setting
    nSamples = round(length(a)*state.yphys.acq.inputRate/state.yphys.acq.outputRate);
    state.yphys.init.phys_inputPatch.set('sampQuantSampPerChan', nSamples);
    %state.yphys.init.phys_inputPatch.set('everyNSamples', nSamples);

    state.yphys.init.phys_patch.writeAnalogData(a(:));
    pause(0.05);
    state.yphys.init.phys_patch.start();
    state.yphys.init.phys_inputPatch.start();
    state.spc.yphys.triggertime = datenum(now);
    %trigger([state.yphys.init.phys_input, state.yphys.init.phys_patch]);
    dioTrigger;
    %state.yphys.init.phys_inputPatch.waitUntilTaskDone(0.35);
    %yphys_getData_patch(state.yphys.init.phys_inputPatch.readAnalogData());
    %a = state.yphys.init.phys_inputPatch.readAnalogData()
end