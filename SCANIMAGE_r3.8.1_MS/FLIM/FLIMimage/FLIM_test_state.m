function status = FLIM_test_state
global state;

status=0;
[out status]=calllib(state.spc.init.dllname,'SPC_test_state',state.spc.acq.module,status);
