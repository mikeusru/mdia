function r_calcium_Depolarization
global state;
global gh;
if state.files.fileCounter == 4
    sr = get(state.yphys.init.phys_patch, 'SampleRate');
    set(state.yphys.init.phys_patch, 'TriggerType', 'HwDigital');
    %depolarize at 128ms
    nF = state.acq.numberOfFrames;
    nLine = state.acq.linesPerFrame;
    a1 = zeros(8*1*nLine/1000*sr, 1); %Twoframes;%8 frames, 1 ms base line.
    a2 = ones(8*1*nLine/1000*sr, 1)*65/state.yphys.acq.commandSensV;
    putdata(state.yphys.init.phys_patch, [a1; a2]);
    start(state.yphys.init.phys_patch);
    %putsample(state.yphys.init.phys_patch, 65/state.yphys.acq.commandSensV);
elseif state.files.fileCounter == 12
    set(gh.spc.FLIMimage.Uncage, 'Value', 1);
    state.spc.acq.uncageBox = 1;
elseif state.files.fileCounter == 42
    putsample(state.yphys.init.phys_patch, 0/state.yphys.acq.commandSensV);
    set(gh.spc.FLIMimage.Uncage, 'Value', 0);
    state.spc.acq.uncageBox = 0;
end