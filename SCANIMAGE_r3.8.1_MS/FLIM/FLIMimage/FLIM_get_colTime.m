function col_time = FLIM_get_colTime
global state

col_time = 0;
[out1, col_time]=calllib(state.spc.init.dllname,'SPC_get_actual_coltime',state.spc.acq.module,col_time);
disp(sprintf('Acquisition time: %f s', col_time));
