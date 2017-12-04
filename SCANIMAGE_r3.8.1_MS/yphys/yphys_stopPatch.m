function yphys_stopPatch;
global state;

try
	stop(state.spc.timer.patch_timer);
	delete(state.spc.timer.patch_timer);
catch
end