function startFLIM
global state;

openini('flim.ini');
try
	if state.spc.init.spc_on == 1
        stopGrab;
        spc_setupPixelClockDAQ_Common;
        spc_stopGrab;
	end
catch
end

spc_drawInit;
FLIMControl;