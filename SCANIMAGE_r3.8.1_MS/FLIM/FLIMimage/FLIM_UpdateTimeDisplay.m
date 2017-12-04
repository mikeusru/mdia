function FLIM_UpdateTimeDisplay

global state;
global gh;

timeDisplay=gh.spc.FLIMimage.edit1;
timeCount=0.0;
if isfield(gh, 'mainControls')
    set(gh.mainControls.focusButton, 'Enable', 'On');
end
switch state.spc.acq.SPCdata.mode
    case {0,1}
        [out2, timeCount]=calllib(state.spc.init.dllname,'SPC_get_time_from_start',state.spc.acq.module,timeCount);
        if (out2 ~= 0)
            error = FLIM_get_error_string(out2);
            disp(['error in timer:', error]);
		end
    case {2,3}
        task = get(state.spc.acq.mt, 'TasksExecuted');
		if task > 2
			ap = get(state.spc.acq.mt, 'AveragePeriod');
			timeCount = ap*task;
		end
        if strcmp(get(gh.spc.FLIMimage.loop, 'String'), 'STOP')
            if timeCount > state.standardMode.repeatPeriod - 2
                if isfield(gh, 'mainControls')
                    if strcmp(get(gh.mainControls.focusButton, 'String'), 'ABORT')
                        beep;
                        executeFocusCallback(gh.mainControls.focusButton);
                    end
                    set(gh.mainControls.focusButton, 'Enable', 'Off');
                    set(gh.mainControls.focusButton, 'Visible', 'Off');
                end
            end
        end
    otherwise
end

if (timeCount>=3600)
    set(timeDisplay,'String','> 1 hr');
else
    secondstot=double(timeCount);
    minutes=floor(secondstot/60);
    seconds=floor(secondstot-60*minutes);
    if (minutes<10)&(seconds<10)
        set(timeDisplay,'String',sprintf('0%i:0%i',minutes,seconds));
    end
    if (minutes<10)&(seconds>=10)
        set(timeDisplay,'String',sprintf('0%i:%i',minutes,seconds));
    end
    if (minutes>=10)&(seconds<10)
        set(timeDisplay,'String',sprintf('%i:0%i',minutes,seconds));
    end
    if (minutes>=10)&(seconds>=10)
        set(timeDisplay,'String',sprintf('%i:%i',minutes,seconds));
    end
        
end

