function error = FLIM_get_error_string (out1)
global state

maxlength = 62;
dest_string(1:maxlength)='a';
[out2, error]=calllib(state.spc.init.dllname,'SPC_get_error_string',out1,dest_string, maxlength);
