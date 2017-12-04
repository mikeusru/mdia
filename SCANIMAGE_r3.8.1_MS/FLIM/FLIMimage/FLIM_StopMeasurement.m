function error1 = FLIM_StopMeasurement

global state;

if strcmp(state.spc.init.dllname, 'TH260lib')
    try
        state.spc.internal.hPQ.stopMeas;
    catch
        error1 = calllib('TH260lib', 'TH260_StopMeas', state.spc.acq.module); 
    end
else
    error1 = 0;
    %state.spc.internal.ifstart = 0;
    out1=calllib(state.spc.init.dllname,'SPC_stop_measurement',state.spc.acq.module);
    if out1 < 0
        %Try again!!
        j = 0;
        while out1 < 0 && j < 25 
            out1=calllib(state.spc.init.dllname,'SPC_stop_measurement',state.spc.acq.module);
            j = j+1;
        end
        if out1 < 0
            error = FLIM_get_error_string (out1);    
            disp(['Error during stop measurement:', error]);
            error1 = 1;
        end
    else

    end
end