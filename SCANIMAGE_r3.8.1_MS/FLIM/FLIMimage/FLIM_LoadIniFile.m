function FLIM_LoadIniFile(hObject,handles,filename)

calllib(state.spc.init.dllname,'SPC_set_mode',0,1,[0 0 0 0 0 0 0 0]);

disp(sprintf('Loading ini file: %s',filename));
error_code=calllib(state.spc.init.dllname,'SPC_init',filename);
disp(sprintf('Loading status: %s',FLIM_get_error_string (error_code)));

if error_code<0
    result = calllib(state.spc.init.dllname,'SPC_set_mode',730,1,[1 0 0 0 0 0 0 0]);
    if result>=0
        disp(sprintf('Entering simulation mode: %i',result));
    end
end

disp('Testing modules:');
j=0;
for i=0:7
    error_code_1=calllib(state.spc.init.dllname,'SPC_test_id',i);
    error_code_2=calllib(state.spc.init.dllname,'SPC_get_init_status',i);
    if (error_code_1>0)&(error_code_2==0)
        disp(sprintf('\tModule %i: %i',i,error_code_1));
        ModInfo=libstruct('s_SPCModInfo');
        ModInfo.module_type=0;
        [out1 SPCModInfo]=calllib(state.spc.init.dllname,'SPC_get_module_info',i,ModInfo);
        disp(sprintf('\t\tModule type:\t%i',SPCModInfo.module_type));
        disp(sprintf('\t\tBus number:\t\t%i',SPCModInfo.bus_number));
        disp(sprintf('\t\tSlot number:\t%i',SPCModInfo.slot_number));
        disp(sprintf('\t\tIn use:\t\t\t%i',SPCModInfo.in_use));
        disp(sprintf('\t\tInit:\t\t\t%i',SPCModInfo.init));
        disp(sprintf('\t\tBase address:\t%i',SPCModInfo.base_adr));
        if SPCModInfo.in_use==1
            state.spc.acq.module=i;
        end
        state.spc.acq.SPCModInfo = SPCModInfo;
        j=j+1;
    end
end
if (j==0)
    disp('  No modules found');
else
    disp(sprintf('Active module: %i',state.spc.acq.module));
end

handles=FLIM_getParameters(hObject,handles);
guidata(hObject,handles);
FLIM_FillParameters(handles);
