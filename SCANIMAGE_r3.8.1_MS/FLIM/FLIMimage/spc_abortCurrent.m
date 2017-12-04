function spc_abortCurrent

global state;
global gh;

try
    spc_stopGrab;
    spc_stopFocus;
    if state.spc.acq.spc_dll
        FLIM_StopMeasurement;
    end
end

% if isfield(state, 'yphys') 
%     yphys_setup(1,1);
% end

yphys_stopAll;

%%%%%%%%%%%%%%%%
try
    state.internal.usePage = get(gh.spc.FLIMimage.pageScan, 'value');
end
state.spc.acq.spc_average = state.internal.usePage;

state.spc.internal.ifstart = 0;
a = timerfind;
for i = 1:length(a)
    if strcmp(get(a(i), 'TimerFcn'), 'spc_loopFcn')
        stop(a(i));
        delete(a(i));
    end
end

try
    stop(state.spc.acq.mt);
    delete(state.spc.acq.mt);
catch
end
try
    stop(state.spc.acq.timer.looptimer);
    delete(state.spc.acq.timer.looptimer);
catch
end


%MP285Clear;
try
    scim_parkLaser;
end
try        
    flushAOData; 
end


set(gh.mainControls.focusButton, 'Visible', 'On');
set(gh.mainControls.startLoopButton, 'Visible', 'On');
set(gh.mainControls.grabOneButton, 'Visible', 'On');
set(gh.mainControls.focusButton, 'Enable', 'On');
set(gh.mainControls.startLoopButton, 'Enable', 'On');
set(gh.mainControls.grabOneButton, 'Enable', 'On');
set(gh.mainControls.focusButton, 'String', 'FOCUS');
set(gh.mainControls.grabOneButton, 'String', 'GRAB');
set(gh.mainControls.startLoopButton, 'String', 'LOOP');
turnOnMenus;

abortCurrent;