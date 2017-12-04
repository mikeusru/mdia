function spc_endAcquisition_NoChannel;
global state;
global gh;


closeShutter;
stopGrab;

if state.internal.abortActionFunctions
	abortInActionFunction;
	return
end

if (state.acq.numberOfFrames == 1 | state.acq.averaging == 1) & state.acq.numberOfChannelsMax > 0 
	if state.internal.keepAllSlicesInMemory % BSMOD 1/18/2
		position = state.internal.zSliceCounter + 1;
	else
		position = 1;
    end
end

if state.internal.zSliceCounter + 1 == state.acq.numberOfZSlices
% Done Acquisition.

    
%Ryohei for FLIM
    if state.spc.init.spc_on == 1
        spc_read;
    end
%End ryohei

	if state.files.autoSave		% BSMOD - Check status of autoSave option
		status=state.internal.statusString;
		setStatusString('Writing data...');
		setStatusString(status);
%Ryohei forFLIM
        if state.spc.init.spc_on == 0
		    state.files.fileCounter=state.files.fileCounter+1;%(Original)
        else
            state.files.fileCounter=state.files.fileCounter+state.acq.numberOfZSlices;
        end
%end Ryohei
		updateGUIByGlobal('state.files.fileCounter');
		updateFullFileName(0);
	end
    
	parkLaser;
	putData;
	
	state.internal.zSliceCounter = state.internal.zSliceCounter + 1;
	updateGUIByGlobal('state.internal.zSliceCounter');
    
	if state.acq.numberOfZSlices > 1
		%mp285FinishMove(1);	% check that movement worked during stack
		executeGoHome;
	end				

	if state.internal.looping==1
		setStatusString('Resuming Loop....');
		resumeLoop;
	else
		setStatusString('Ending Grab...');
		set(gh.mainControls.focusButton, 'Visible', 'On');
		set(gh.mainControls.startLoopButton, 'Visible', 'On');
		set(gh.mainControls.grabOneButton, 'String', 'GRAB');
		set(gh.mainControls.grabOneButton, 'Visible', 'On');
		turnOnMenus;
		setStatusString('');
	end
	
elseif state.internal.zSliceCounter < state.acq.numberOfZSlices - 1
% Between Acquisitions or ZSlices
	setStatusString('Next Slice...');


	if state.acq.numberOfZSlices > 1
		startMoveStackFocus; 	% start movement - focal plane down one step
	end    
%Ryohei for FLIM
    if state.spc.init.spc_on == 1
        spc_read; 
    end
%End ryohei


	state.internal.zSliceCounter = state.internal.zSliceCounter + 1;
	updateGUIByGlobal('state.internal.zSliceCounter');

	state.internal.frameCounter = 1;
	updateGUIByGlobal('state.internal.frameCounter');
	
	setStatusString('Acquiring...');

	putData;
	
	mp285FinishMove(0);	% check that movement worked
	if (strcmp(get(gh.mainControls.grabOneButton, 'String'), 'GRAB') ...
			& strcmp(get(gh.mainControls.grabOneButton, 'Visible'),'on'))
		set(gh.mainControls.grabOneButton, 'enable', 'off');
		set(gh.mainControls.grabOneButton, 'enable', 'on');
	elseif (strcmp(get(gh.mainControls.startLoopButton, 'String'), 'LOOP') ...
			& strcmp(get(gh.mainControls.startLoopButton, 'Visible'),'on'))
		set(gh.mainControls.startLoopButton, 'enable', 'off');
		state.internal.abort=1;
		set(gh.mainControls.startLoopButton, 'enable', 'on');
	else
		startGrab;
		openShutter;
		diotrigger;
	end
	
else
end
