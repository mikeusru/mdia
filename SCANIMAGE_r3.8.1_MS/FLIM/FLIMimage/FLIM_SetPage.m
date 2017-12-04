function FLIM_SetPage (pageNumber)

global state;

%pageNumber=0;

out1=calllib(state.spc.init.dllname,'SPC_set_page',state.spc.acq.module,pageNumber);

if out1 ~= 0
    error = FLIM_get_error_string (out1);    
    disp(['Set page error:', error]);
end