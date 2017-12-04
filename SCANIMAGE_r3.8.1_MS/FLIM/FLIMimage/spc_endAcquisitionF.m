function spc_endAcquisitionF

global state;
global gui;
global spc;


switch state.spc.acq.SPCdata.mode
%closeShutter;
    case {2, 3}
        %spc_closeShutter;
        spc_stopFocus;
        spc_flushAO;
        error = FLIM_StopMeasurement;
        coltime=0;
        [out coltime]=calllib(state.spc.init.dllname,'SPC_get_actual_coltime',state.spc.acq.module,coltime);
        %disp(['Collection time = ', num2str(coltime), 's']);
            
        %toc; tic
        FLIM_imageAcq(0,1);
        
        if ~state.internal.abortActionFunctions==1;
            FLIM_FillMemory(0);
            spc_putDataFocus (0);          
            FLIM_StartMeasurement;
            spc_startFocus;
            
            [armedB, measureB, waitB, timeroutB] = FLIM_decode_test_state (0);
            a = get(state.spc.init.spc_aoF);
            if length(a.EventLog)~= 1
                disp('****Error??**** 1');
                a.EventLog(2)
            end
            a = get(state.init.ao2F);
            if length(a.EventLog)~= 1
                disp('****Error??**** 2');
                a.EventLog(2)
            end
            
            spc_dioTrigger(0);
            
            [armed, measure, wait, timerout] = FLIM_decode_test_state (0);
            status = FLIM_get_scan_clk_state;
            if armed && status == 6 && waitB && ~wait
                %disp('Imaging triggered.');
            else
                disp('***Trigger Error*******');
                %FLIM_decode_test_state (1);
                pause(0.01);
                state.spc.init.spc_ao
                
            end
            coltime=0;
            [out coltime]=calllib(state.spc.init.dllname,'SPC_get_actual_coltime',state.spc.acq.module,coltime);
            %disp(['Collection time = ', num2str(coltime), 's']);
        end
        set(gui.spc.figure.projectImage, 'CData', spc.project);
    otherwise
end