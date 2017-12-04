function status = FLIM_get_scan_clk_state
global state
status = 0;
[out, status]=calllib(state.spc.init.dllname,'SPC_get_scan_clk_state',state.spc.acq.module,status);
pixel_state = dec2bin(status, 3);
disp(sprintf('Frame clock: %s, Line clock: %s, Pixel clock: %s', pixel_state(1), pixel_state(2), pixel_state(3)));
