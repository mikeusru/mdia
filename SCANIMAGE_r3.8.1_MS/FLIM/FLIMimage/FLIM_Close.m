function FLIM_Close
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
	fid = fopen('FLIMimage.m');
	[fileName,permission, machineormat] = fopen(fid);
	[pathstr,name,ext] = fileparts(fileName);
	fclose(fid);
	save([pathstr, '\spc_init.mat'], 'SPCdata');
end
%spc_saveSPCSetting;

% try
% 	out1 = calllib(state.spc.init.dllname,'SPC_close');
%     if (out1~=0)
%         error = FLIM_get_error_string (out1);    
%         disp(['error during closing SPC:', error]);
%     end
% catch
%     disp('Errors!! during closing SPC');
% end

try
	unloadlibrary (state.spc.init.dllname);
catch
    disp('Errors!! during unloading spcm64');
end

try
    close(gui.spc.figure.project);
    close(gui.spc.figure.lifetimeMap);
    close(gui.spc.figure.lifetime);
    %close(gui.spc.lifetimerange);
end
closereq;
