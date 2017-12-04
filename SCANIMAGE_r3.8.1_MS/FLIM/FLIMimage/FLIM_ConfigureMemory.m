function FLIM_ConfigureMemory

global state

data=libstruct('s_SPCMemConfig');
data.max_block_no=0;
switch state.spc.acq.SPCdata.mode
	case 0  
        [out1, state.spc.acq.SPCMemConfig]=calllib(state.spc.init.dllname,'SPC_configure_memory',state.spc.acq.module,state.spc.acq.SPCdata.adc_resolution,0,data);
	case {2,3}
        [out1, state.spc.acq.SPCMemConfig]=calllib(state.spc.init.dllname,'SPC_configure_memory',-1,-1,0,data);
       %%% short CVICDECL SPC_configure_memory (short mod_no, short
       %%% adc_resolution, short no_of_routing_bits, SPCMemConfig
       %%% *mem_info)
       %%% no_of_routing_bits: 0-14 for SPC-7xx)
       [armed, measure, wait, timerout, filled] = FLIM_decode_test_state(0); %Just to test...
    case {5}
        return;
    otherwise
end

if out1 ~= 0
    error = FLIM_get_error_string (out1);    
    disp(['Memory config error:', error]);
end