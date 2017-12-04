function FLIM_FillMemory (page)

global state;

%block = state.spc.acq.SPCMemConfig.blocks_per_frame*state.spc.acq.SPCMemConfig.frames_per_page;
if ~nargin
    page = -1;
end
switch state.spc.acq.SPCdata.mode
	case {0,1}
		for i=0:state.spc.acq.SPCMemConfig.blocks_per_frame-1
            out1=calllib(state.spc.init.dllname,'SPC_fill_memory',state.spc.acq.module,i,0,0);
			if out1 ~= 0
                error = FLIM_get_error_string (out1);    
                disp(['Memory filling error:', error]);
                return;
			end
		end
    case {2,3}   
        block = -1;
        out1=calllib(state.spc.init.dllname,'SPC_fill_memory',state.spc.acq.module,block,page,0);
        blocks_per_frame = state.spc.acq.SPCMemConfig.blocks_per_frame;
        frames_per_page = state.spc.acq.SPCMemConfig.frames_per_page;
        block_length = state.spc.acq.SPCMemConfig.block_length;
        memorysize =  block_length* blocks_per_frame*  frames_per_page;
        pause(memorysize * 1e-7 + 0.05);
        if out1 < 0
            FLIM_get_error_string(out1);
        end

    case {5}
        block = -1;
        page = -1;
        out1=calllib(state.spc.init.dllname,'SPC_fill_memory',state.spc.acq.module,block,page,0);
    otherwise
end

