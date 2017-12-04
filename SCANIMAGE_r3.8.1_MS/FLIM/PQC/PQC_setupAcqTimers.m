function PQC_setupAcqTimers
global state

state.spc.acq.timer.pqc_timerRates=timer('TimerFcn','PQC_TimerFunctionRates','ExecutionMode','fixedSpacing','Period',1.0);

period = state.acq.msPerLine*state.acq.linesPerFrame/state.internal.numberOfStripes/1000;
state.spc.internal.focusTimer = timer('TimerFcn', 'PQC_acqTimerFcn(1)', 'Period', period, 'ExecutionMode', 'fixedDelay');
state.spc.internal.grabTimer = timer('TimerFcn', 'PQC_acqTimerFcn(0)', 'Period', period, 'ExecutionMode', 'fixedDelay');