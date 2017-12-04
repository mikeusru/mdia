function FLIM_LoadLibrary
global state

%
if (~libisloaded(state.spc.init.dllname))
    if strcmp(state.spc.init.dllname, 'TH260lib')
        loadlibrary('th260lib64.dll', 'th260lib.h', 'alias', 'TH260lib');
    else
        addpath('C:\Program Files (x86)\BH\SPCM\DLL');
        loadlibrary(state.spc.init.dllname,'Spcm_def.h', 'includepath', 'C:\Program Files (x86)\BH\SPCM\DLL');
    end
end
