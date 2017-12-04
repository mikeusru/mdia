function r_oneSecTimerFnc
global state
global gh

interval = 2;

state.yphys.timer.r_timerCount = state.yphys.timer.r_timerCount + 1;
etime = datenum(clock) - datenum(state.yphys.timer.r_timerStart);
etime = etime*24*60*60;


if state.yphys.timer.r_timerCount == 1 %%%%%%%%%%%%%%%%%%%%%%%
    set(gh.yphys.stimScope.pulseN, 'String', '8');
    set(gh.yphys.stimScope.saveCheck, 'Value', 1);
    set(gh.yphys.stimScope.epochN, 'String', '1');  
    yphys_setupParameters;
    yphys_generic;
    yphys_loadAverage;
    try
        state.spc.acq.spc_binning = 0;
        set(gh.spc.FLIMimage.checkbox3, 'Value', 0);
    end
    state.acq.numberOfPages = 1;
    state.acq.numberOfBinPages = 1;
    state.yphys.acq.uncagePage = 2;
    state.internal.pageCounter = 0;
    state.internal.binPageCounter = 0;
    state.internal.usePage = 0;
    state.yphys.acq.depolarize = 0;
    state.yphys.acq.startDep = 1;
    state.yphys.acq.stopDep = 1;
    state.acq.numberOfFrames = str2num(get(gh.standardModeGUI.numberOfFrames, 'String'));
    state.acq.numberOfZSlices = 1; %str2num(get(gh.standardModeGUI.numberOfSlices, 'String'));
    state.standardMode.numberOfFrames = str2num(get(gh.standardModeGUI.numberOfFrames, 'String'));
    state.standardMode.numberOfZSlices = str2num(get(gh.standardModeGUI.numberOfSlices, 'String')); 
elseif  state.yphys.timer.r_timerCount >= 2 && state.yphys.timer.r_timerCount <= 8
    if mod(state.yphys.timer.r_timerCount, interval) == 0
        %disp(num2str(state.yphys.timer.r_timerCount));
        yphys_uncage;
    end
elseif state.yphys.timer.r_timerCount == 9
    %%%Start Grab
    if state.spc.acq.SPCdata.mode == 2
        state.spc.acq.SPCdata.trigger = 1;
        if FLIM_setupScanning(0)
            %return;
        end
        state.internal.whatToDo=2;
        state.spc.acq.page = 0;
        FLIM_Measurement(gh.spc.FLIMimage.grab, gh.spc.FLIMimage);
    end
elseif state.yphys.timer.r_timerCount >= 18 && state.yphys.timer.r_timerCount <= 24%%%%%%%%%%%%%%%%%%%%%%%
    set(gh.yphys.stimScope.pulseN, 'String', '8');
    set(gh.yphys.stimScope.saveCheck, 'Value', 1);
    set(gh.yphys.stimScope.epochN, 'String', '2');  
    yphys_setupParameters;
    yphys_generic;
    yphys_loadAverage;    
    if mod(state.yphys.timer.r_timerCount, interval) == 0
        %disp(num2str(state.yphys.timer.r_timerCount));
        yphys_uncage;
    end

elseif state.yphys.timer.r_timerCount == 26 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('start page program');
    set(gh.yphys.stimScope.saveCheck, 'Value', 0);
    set(gh.yphys.stimScope.pulseN, 'String', '9');
    yphys_setupParameters;
    yphys_generic;
    yphys_loadAverage;
    state.acq.numberOfPages = 128;
    state.acq.numberOfBinPages = 16;
    state.yphys.acq.uncagePage = 24:2:113;
    state.internal.pageCounter = 0;
    state.internal.binPageCounter = 0;
    state.internal.usePage = 1;
    state.yphys.acq.depolarize = 1;
    state.yphys.acq.startDep = 8;
    state.yphys.acq.stopDep = 114;
    state.acq.numberOfFrames = 3;
    state.standardMode.numberOfFrames = 3;
    state.acq.numberOfZSlices = 1;
    state.standardMode.numberOfZSlices = 1;
    try
        state.spc.acq.spc_binning = 1;
        set(gh.spc.FLIMimage.checkbox3, 'Value', 1);
    end
    if state.spc.acq.SPCdata.mode == 2
        state.spc.acq.SPCdata.trigger = 1;
        if FLIM_setupScanning(0)
            return;
        end
        state.internal.whatToDo=2;
        state.spc.acq.page = 0;
        FLIM_Measurement(gh.spc.FLIMimage.grab, gh.spc.FLIMimage);
    end    
elseif state.yphys.timer.r_timerCount > 100 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state.internal.pageCounter == 0
        state.acq.numberOfPages = 128;
        state.acq.numberOfBinPages = 8;
        state.yphys.acq.uncagePage = 24:2:113;
        state.internal.pageCounter = 0;
        state.internal.binPageCounter = 0;
        state.internal.usePage = 0;
        state.yphys.acq.depolarize = 1;
        state.yphys.acq.startDep = 8;
        state.yphys.acq.stopDep = 114;
        state.acq.numberOfFrames = 3;
        state.standardMode.numberOfFrames = 3;
        state.acq.numberOfZSlices = 1;
        state.standardMode.numberOfZSlices = 1;
        state.acq.numberOfFrames = str2num(get(gh.standardModeGUI.numberOfFrames, 'String'));
        state.acq.numberOfZSlices = str2num(get(gh.standardModeGUI.numberOfSlices, 'String'));
        state.standardMode.numberOfFrames = str2num(get(gh.standardModeGUI.numberOfFrames, 'String'));
        state.standardMode.numberOfZSlices = str2num(get(gh.standardModeGUI.numberOfSlices, 'String'));

        try
            state.spc.acq.spc_binning = 0;
            set(gh.spc.FLIMimage.checkbox3, 'Value', 0);
        end
        set(gh.yphys.stimScope.saveCheck, 'Value', 1);
        set(gh.yphys.stimScope.pulseN, 'String', '8');
        set(gh.yphys.stimScope.ntrain, 'String', '4');
        set(gh.yphys.stimScope.epochN, 'String', '3');    
        yphys_setupParameters;
        yphys_generic;
        yphys_loadAverage;
        stop(state.yphys.timer.r_timer);
        delete(state.yphys.timer.r_timer);
    end
end

