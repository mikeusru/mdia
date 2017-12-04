function FLIM_image_timer
global state;
global gh;

if state.spc.acq.spc_image
	if ~state.spc.internal.ifstart
        measure = FLIM_draw_state;
        FLIM_UpdateTimeDisplay;
    	set(gh.mainControls.grabOneButton, 'Visible', 'off');
		set(gh.mainControls.startLoopButton, 'Visible', 'off');
		if ~strcmp(get(gh.spc.FLIMimage.loop, 'String'), 'STOP')
            set(gh.mainControls.focusButton, 'Visible', 'off');
		end
	end
else
    measure = FLIM_draw_state;
    FLIM_UpdateTimeDisplay;
	set(gh.mainControls.grabOneButton, 'Visible', 'off');
	set(gh.mainControls.startLoopButton, 'Visible', 'off');
	if ~strcmp(get(gh.spc.FLIMimage.loop, 'String'), 'STOP')
        set(gh.mainControls.focusButton, 'Visible', 'off');
	end
end