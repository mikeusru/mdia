function spc_loopFcn
global state;
global spc;
global gh;

hObject = gh.spc.FLIMimage.grab;
handles = gh.spc.FLIMimage;

if state.spc.acq.SPCdata.mode == 2
	state.spc.acq.SPCdata.trigger = 1;
    if FLIM_setupScanning(0)
        return;
    end
	state.internal.whatToDo=2;
    state.spc.acq.page = 0;
	FLIM_Measurement(hObject, handles);
end