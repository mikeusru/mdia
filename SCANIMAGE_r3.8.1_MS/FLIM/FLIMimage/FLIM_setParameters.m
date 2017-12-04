function FLIM_setParameters (handles)

global state;

if ~isempty(strfind(state.spc.init.dllname, 'spcm'))
    if nargin
        state.spc.acq.SPCdata = handles.SPCdata;
    end

    out1=calllib(state.spc.init.dllname,'SPC_set_parameters',state.spc.acq.module,state.spc.acq.SPCdata);

    if (out1~=0)
        error = FLIM_get_error_string (out1);    
        disp(['error during setting parameters:', error]);
    end
else

    %[ret] = calllib('TH260lib', 'TH260_Initialize', state.spc.acq.module, state.spc.acq.SPCdata.mode); 
    
    InputTriggerEdge = 1;
    [ret] = calllib('TH260lib', 'TH260_SetSyncDiv', state.spc.acq.module, state.spc.acq.SPCdata.sync_freq_div);
    
    if  strcmp(state.spc.acq.SPCModInfo.module_type, 'TimeHarp 260 N')
        SyncTiggerEdge = 1;
        [ret] = calllib('TH260lib', 'TH260_SetSyncEdgeTrg', state.spc.acq.module, state.spc.acq.SPCdata.sync_threshold, SyncTiggerEdge);
        for i=0:state.spc.acq.SPCdata.n_channels-1 % we use the same input settings for all channels        
            [ret] = calllib('TH260lib', 'TH260_SetInputEdgeTrg', state.spc.acq.module, i, state.spc.acq.SPCdata.cfd_limit_low, InputTriggerEdge);
        end
    end
    
    if strcmp(state.spc.acq.SPCModInfo.module_type, 'TimeHarp 260 P')
        [ret] = calllib('TH260lib', 'TH260_SetSyncCFD', state.spc.acq.module, state.spc.acq.SPCdata.sync_threshold, state.spc.acq.SPCdata.sync_zc_level);
        for i=0:state.spc.acq.SPCdata.n_channels-1             
            [ret] = calllib('TH260lib', 'TH260_SetInputCFD', state.spc.acq.module, i, state.spc.acq.SPCdata.cfd_limit_low, state.spc.acq.SPCdata.cfd_zc_level);
        end
    end
end