function FLIM_StartMeasurement

global state;

state.spc.internal.ifstart = 1;

if strcmp(state.spc.init.dllname, 'TH260lib')
    %Tacq = 5000; %1 s for now.
    Tacq = state.acq.numberOfFrames * state.acq.linesPerFrame * state.acq.msPerLine + 500; %millisecond
    ret = calllib('TH260lib', 'TH260_StartMeas', state.spc.acq.module, Tacq);
    disp('Measurement started');
else
    out1=calllib(state.spc.init.dllname,'SPC_start_measurement',state.spc.acq.module);
    if out1 ~= 0
        error = FLIM_get_error_string (out1);
        disp(['Error during start measurement:', error]);
    end
end
% a = FLIM_ifarmed;
% if a
%     disp('Starting FLIM')
% else
%     disp('Error in starting FLIM')
% end