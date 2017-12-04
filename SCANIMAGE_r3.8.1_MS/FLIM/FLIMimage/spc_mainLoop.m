function out=spc_mainLoop;

	global state gh
	
	setStatusString('Looping...');
    set(gh.spc.FLIMimage.grab, 'Visible', 'off');
    set(gh.spc.FLIMimage.focus, 'Visible', 'off');
    set(gh.spc.FLIMimage.loop, 'String', 'STOP');
    state.spc.acq.timer.looptimer =timer('TimerFcn','spc_loopFcn','ExecutionMode', 'fixedSpacing','Period',state.standardMode.repeatPeriod, 'Tag', 'im_loop');
	
	start(state.spc.acq.timer.looptimer);