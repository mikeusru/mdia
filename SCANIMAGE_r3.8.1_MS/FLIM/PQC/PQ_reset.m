function PQ_reset

global state gh

try
    spc_stopGrab;
    spc_stopFocus;
end

try
    yphys_stopAll;
end
%MP285Clear;
try
    scim_parkLaser;
end
try        
    flushAOData; 
end

try
    stop(state.spc.acq.timer.pqc_timerRates);
    delete(state.spc.acq.timer.pqc_timerRates);
end

try
    stop(state.spc.internal.grabTimer);
    stop(state.spc.internal.focusTimer);
    delete(state.spc.internal.grabTimer);
    delete(state.spc.internal.focusTimer);
end

state.spc.internal.ifstart = 0;
state.spc.internal.hPQ.closeDevice;
delete(state.spc.internal.hPQ);
%%
state.spc.internal.hPQ = PQC_acquisition(state.spc.acq.module, state.spc.acq.SPCdata.mode);
PQC_fillParameters;
PQC_setParametersGUI(0);
PQC_setupAcqTimers;
start(state.spc.acq.timer.pqc_timerRates);
set(gh.spc.pq_parameters.cb_showrates, 'value', 1);

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