function yphys_stimLoopFcn
global state
global gh ua dia

%disp(['waiting =', num2str(state.yphys.internal.waiting)]);
%get(gh.yphys.stimScope);
if  state.yphys.internal.waiting 
    return;
else
    state.yphys.internal.waiting = 1;
end
set(gh.yphys.stimScope.start, 'Enable', 'Off');
nstim = state.yphys.acq.nstim;
freq = state.yphys.acq.freq;
dwell = state.yphys.acq.dwell;
amp = state.yphys.acq.amp;
delay = state.yphys.acq.delay;
sLength = state.yphys.acq.sLength(state.yphys.acq.pulseN);

ntrain = state.yphys.acq.ntrain(state.yphys.acq.pulseN);
interval = state.yphys.acq.interval(state.yphys.acq.pulseN);
theta = state.yphys.acq.theta;


ext = get(gh.yphys.stimScope.ext, 'value');
ap = get(gh.yphys.stimScope.ap, 'value'); %state.yphys.acq.ap;
uncage=get(gh.yphys.stimScope.Uncage, 'value');   %state.yphys.acq.uncage;
stim = get(gh.yphys.stimScope.Stim, 'value');


cycleSet = str2num(get(gh.yphys.stimScope.cycleSet, 'String'));
if ~isempty(cycleSet)
        cyclePos = mod(state.yphys.acq.phys_counter, length(cycleSet))+1;
        cycleStr = num2str(cycleSet(cyclePos));
        set(gh.yphys.stimScope.pulseN, 'String', cycleStr);
        yphys_setupParameters;
        yphys_generic;
        yphys_loadAverage;
else
        set(gh.yphys.stimScope.pulseN, 'String', num2str(state.yphys.acq.pulseN));
        state.yphys.acq.pulseN;
        yphys_setupParameters;
        yphys_generic;
end




state.yphys.acq.loopCounter = state.yphys.acq.loopCounter + 1;
if ~uncage
    yphys_sendStim;
else
    yphys_uncage;
end


if ext
    set(gh.yphys.stimScope.counter, 'String', ['Looping: ', num2str(state.yphys.acq.loopCounter), '/Inifite']);
else
    set(gh.yphys.stimScope.counter, 'String', ['Looping: ', num2str(state.yphys.acq.loopCounter), '/', num2str(state.yphys.acq.ntrain((state.yphys.acq.pulseN)))]);
    if state.yphys.acq.loopCounter >= state.yphys.acq.ntrain(state.yphys.acq.pulseN)
            stop(state.yphys.timer.stim_timer);
            delete(state.yphys.timer.stim_timer);
            set(gh.yphys.stimScope.start, 'String', 'Start');
            finishUAuncaging; %MISHA
    end
end
%toc;
set(gh.yphys.stimScope.start, 'Enable', 'On');
