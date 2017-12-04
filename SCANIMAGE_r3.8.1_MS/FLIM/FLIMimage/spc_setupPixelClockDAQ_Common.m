function spc_setupPixelClockDAQ_Common
% Pixel clocks are no longer used. Switches for FLIM control remains.

global state


import dabs.ni.daqmx.*
try
    state.spc.init.ao_flim1.delete;
end
state.spc.init.ao_flim1 = Task(['FLIM switch', num2str(round(rand(1)*10000))]);
state.spc.init.ao_flim1.createAOVoltageChan(state.spc.init.spc_boardIndex, state.spc.init.ao_flim1_index, 'FLIM switch FLIM', -10, 10);
state.spc.init.ao_flim1.createAOVoltageChan(state.spc.init.spc_boardIndex, state.spc.init.ao_flim2_index, 'FLIM switch Image', -10, 10);
state.spc.init.ao_flim1.writeAnalogData([5, 0], 1, true);


