function FLIM_restart
global spc;
global state;
global gui;
global gh;



try
	if state.spc.acq.timer.timerRatesEVER
        if isvalid(state.spc.acq.timer.timerRates)==1
            stop(state.spc.acq.timer.timerRates);
            delete(state.spc.acq.timer.timerRates);
        end
	end
    disp('Timers are disabled');
catch
end

error = 0;
try
    FLIM_getParameters;
catch
    error = 1;
end

if error == 0
	SPCdata = state.spc.acq.SPCdata;
	fid = fopen('spcm.ini');
	[fileName,permission, machineormat] = fopen(fid);
	[pathstr,name,ext,versn] = fileparts(fileName);
	fclose(fid);
	save([pathstr, '\spc_init.mat'], 'SPCdata');
end
handles = gh.spc.FLIMimage;
hObject = handles.output
FLIM_Init(hObject,handles);
out1=calllib(state.spc.init.dllname,'SPC_clear_rates',state.spc.acq.module);
state.spc.acq.timer.timerRatesEVER=true;
state.spc.acq.timer.timerRates=timer('TimerFcn','FLIM_TimerFunctionRates','ExecutionMode','fixedSpacing','Period',2.0);
start(state.spc.acq.timer.timerRates);
