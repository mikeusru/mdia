function FLIM_pauseMeasurement
global state
out1=calllib(state.spc.init.dllname,'SPC_pause_measurement',state.spc.acq.module);