function FLIM_TimerFunction

global state;
global gh;


[armed, measuring, waiting, timerout1] = FLIM_decode_test_state (0);
figure(gh.spc.single_plot);
        
if timerout1 == 1
    disp('Finished measurement.');
    FLIM_time_stop_during_experiment;
end
if armed && measuring
        tempData(state.spc.acq.SPCMemConfig.block_length)=0.0;
        pageNumber=0;
        out1=calllib(state.spc.init.dllname,'SPC_pause_measurement',state.spc.acq.module);
        if out1 < 0
            error = FLIM_get_error_string (out1);    
            disp(['Error during pause measurement:', error]);
            return;
        end

        [out1, state.spc.acq.mData]=calllib(state.spc.init.dllname,'SPC_read_data_block',state.spc.acq.module,0,pageNumber,1,0,state.spc.acq.SPCMemConfig.block_length-1,tempData);
        if out1 < 0
            error = FLIM_get_error_string (out1);    
            disp(['Error during read data block:', error]);
            return;
        end
        out1 = calllib(state.spc.init.dllname,'SPC_restart_measurement',state.spc.acq.module);
        if out1 < 0
            error = FLIM_get_error_string (out1);    
            disp(['Error during restart measurement:', error]);
            return;
        end

        %disp('-----------------------');
        FLIM_UpdateTimeDisplay;

        plot(state.spc.acq.mData);

        if (state.spc.acq.ifInactive)
            set(gh.spc.FLIMimage.focus,'Enable','On');
            state.spc.acq.ifInactive=false;
        end

else  %%%%Not running
    %FLIM_time_stop_during_experiment;
end


function FLIM_time_stop_during_experiment
global state;
global gh;

tempData(state.spc.acq.SPCMemConfig.block_length)=0.0;
pageNumber=0;
ismainControls = isfield(gh, 'mainControls');

tag = get(gh.spc.FLIMimage.focus, 'Tag');
focus = strcmp(tag, 'focus');

if ismainControls
    if focus
        spc_executeFocus;
    else
        spc_executeGrabOne;
    end
end

stop(state.spc.acq.mtSingle);
error1= FLIM_StopMeasurement;

[out1, state.spc.acq.mData]=calllib(state.spc.init.dllname,'SPC_read_data_block',state.spc.acq.module,0,pageNumber,1,0,state.spc.acq.SPCMemConfig.block_length-1,tempData);
if out1 < 0
    error = FLIM_get_error_string (out1);    
    disp(['Error during read data block:', error]);
    return;
end
        
set(gh.spc.FLIMimage.focus,'String','FOCUS');
set(gh.spc.FLIMimage.grab,'String','GRAB');

set(gh.spc.FLIMimage.status, 'String', 'Waiting for next operation');    
set(gh.spc.FLIMimage.focus,'Enable','on');
set(gh.spc.FLIMimage.focus, 'Visible', 'on');
set(gh.spc.FLIMimage.grab, 'Visible', 'on');
set(gh.spc.FLIMimage.loop,'Visible','On');
set(gh.spc.FLIMimage.focus,'Enable','On');
set(gh.spc.FLIMimage.grab,'Enable','On');
set(gh.spc.FLIMimage.loop,'Enable','On');

if  ismainControls
    set(gh.mainControls.focusButton, 'Visible', 'On');
    set(gh.mainControls.startLoopButton, 'Visible', 'On');
    set(gh.mainControls.grabOneButton, 'Visible', 'On');
    set(gh.mainControls.focusButton, 'Enable', 'On');
    set(gh.mainControls.startLoopButton, 'Enable', 'On');
    set(gh.mainControls.grabOneButton, 'Enable', 'On');
end

