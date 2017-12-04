function status = FLIM_get_sequencer_state
global state

status = 0;
[out, status] = calllib(state.spc.init.dllname, 'SPC_get_sequencer_state', state.spc.acq.module, status);

if status > 0
    status_str = dec2bin(status, 2);

    fprintf('Seqencer enabled: %s  ', status_str(end));
    fprintf('Seqencer Running: %s\n', status_str(end-1));
end

if (out~=0)
    error = FLIM_get_error_string (out);    
    disp(['error during get sequencer:', error]);
end

