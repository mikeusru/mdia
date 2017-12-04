function SJ_calcium_Depolarization
%%% taken from r_calcium_Depolarization on March 3, 2010
%%% if you set shutter delay to 1ms, then shutter is closed for the first
%%% 64ms. In this case, uncaging should happen at 320ms because, first two
%%% images + 8 base line images = 10(frames)*32(lines)*1(time per line)

global state;
global gh;


if state.files.fileCounter == 4
    sr = get(state.yphys.init.phys_patch, 'SampleRate');
    set(state.yphys.init.phys_patch, 'TriggerType', 'HwDigital');
    %depolarize at 128ms
    nF = state.acq.numberOfFrames;
    nLine = state.acq.linesPerFrame;
    a1 = zeros(8*1*nLine/1000*sr, 1); %Twoframes;%8 frames, 1 ms base line.
    %%% 8 frames 1ms nLine divide by 1000 to conver to sec since sr is
    %%% frequency per sec
    a2 = ones(8*1*nLine/1000*sr, 1)*65/state.yphys.acq.commandSensV;
    %%% doesn't matter if the number here is 8 or something else... send
    %%% command once and it keeps at that voltage
    %%% state.yphys.acq.commandSensV is "gain" by the MultiClamp 700B, so
    %%% must divide by 20.
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

    
% elseif state.files.fileCounter == 4
%     set(gh.spc.FLIMimage.Uncage, 'Value', 1);
%     state.spc.acq.uncageBox = 1;
% elseif state.files.fileCounter == 34
%     putsample(state.yphys.init.phys_patch, 0/state.yphys.acq.commandSensV);
%     set(gh.spc.FLIMimage.Uncage, 'Value', 0);
%     state.spc.acq.uncageBox = 0;
end