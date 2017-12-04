function FLIM_restartMeasurement
global state
out1=calllib(state.spc.init.dllname,'SPC_restart_measurement',state.spc.acq.module);