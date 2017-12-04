function result = FLIM_Init(hObject,handles)
global state

result = 0;
state.spc.acq.ifStart = false;
state.spc.acq.ifInactive = true;

if (exist('spc_init.mat') == 2)
    fid = fopen('spc_init.mat');
    [fileName,permission, machineormat] = fopen(fid);
    fclose(fid);
    state.spc.files.iniFile = fileName;
    load (fileName);
    state.spc.acq.SPCdata = SPCdata;
end

disp('FLIMimage v3.0');
disp('---------------');

if libisloaded(state.spc.init.dllname)
    unloadlibrary(state.spc.init.dllname);
end
FLIM_LoadLibrary();

if libisloaded(state.spc.init.dllname)
    
else
    error('Failed loading DLL!');
end

if strcmp(state.spc.init.dllname, 'TH260lib')
    result = PQ_init(hObject, handles);
    if result < 0
        error('Device Th260 was correctly installed');
    end
else
    BH_init(hObject, handles);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Timer seating

state.spc.acq.mt=timer('TimerFcn','FLIM_image_timer','ExecutionMode','fixedSpacing','Period',1.0);
state.spc.acq.mtSingle=timer('TimerFcn','FLIM_TimerFunction','ExecutionMode','fixedSpacing','Period',1.0);

end

function BH_init(hObject, handles)

global state

p=mfilename('fullpath'); %MISHA - Load settings from spcm_ry.ini in current FLIMimage directory
[path,~,~]=fileparts(p);
path=[path, '\spcm_ry.ini'];
[fid, message]=fopen(path);
%[fid, message]=fopen('C:\Program Files (x86)\BH\SPCM\spcm.ini');

if fid<0
    fileName = 'spcm.ini';
    disp(['Error opening ' fileName ': ' message]);
    return
end


[fileName,permission, machineormat] = fopen(fid);
fclose(fid);
disp(['*** CURRENT INI FILE = ' fileName ' ***']);
error_code=calllib(state.spc.init.dllname,'SPC_init',fileName);
error_string = FLIM_get_error_string(error_code);
disp(sprintf('Initialization: %s',error_string));

if error_code < 0
    state.spc.acq.SPCModInfo.module_type = 150;
    disp('Failed to initialize SPC');
    [result, inuse] = calllib(state.spc.init.dllname,'SPC_set_mode',state.spc.acq.SPCModInfo.module_type,1,[1 0 0 0 0 0 0 0]);
    if result>=0 || inuse ~= 1
        disp(sprintf('Entering simulation mode: %i',result));
    end
end

disp('Testing modules: 0');
j=0;
i = 0;
ModInfo=libstruct('s_SPCModInfo');
ModInfo.module_type=0;
[out1, SPCModInfo]=calllib(state.spc.init.dllname,'SPC_get_module_info',i,ModInfo);
if SPCModInfo.in_use==1
        state.spc.acq.module=i;
elseif SPCModInfo.in_use == -1
    disp('Failed to initialize SPC. Forcing to use the hardware...');
    state.spc.acq.module = i;
    result = calllib(state.spc.init.dllname,'SPC_set_mode',SPCModInfo.module_type,1,[1 0 0 0 0 0 0 0]);
    [out1 SPCModInfo]=calllib(state.spc.init.dllname,'SPC_get_module_info',i,ModInfo);   
    if SPCModInfo.in_use == 1
        disp('Done');
        if result>=0
            disp(sprintf('Entering simulation mode: %i',result));
        end
    elseif SPCModInfo.in_use == -1
          disp('Module is in use. SPC module is forced to turn on -- 2nd trial!');
          result = calllib(state.spc.init.dllname,'SPC_set_mode',SPCModInfo.module_type,1,[1 0 0 0 0 0 0 0]);
          [out1 SPCModInfo]=calllib(state.spc.init.dllname,'SPC_get_module_info',i,ModInfo);
           pause(0.1);
           if SPCModInfo.in_use == 1
                disp('Done');
                if result>=0
                    disp(sprintf('Entering simulation mode: %i',result));
                end; 
           elseif SPCModInfo.in_use == -1
                disp('Module is in use. SPC module is not installed');
                return;
           end
    end
end


error_code_1=calllib(state.spc.init.dllname,'SPC_test_id',i);
error_code_2=calllib(state.spc.init.dllname,'SPC_get_init_status',i);
if (error_code_1>0)&&(error_code_2==0)
    state.spc.acq.SPCModInfo = SPCModInfo;
    j=j+1;
    disp(sprintf('\tModule %i: %i',i,error_code_1));
    disp(sprintf('\t\tModule type:\t%i',SPCModInfo.module_type));
    disp(sprintf('\t\tBus number:\t\t%i',SPCModInfo.bus_number));
    disp(sprintf('\t\tSlot number:\t%i',SPCModInfo.slot_number));
    disp(sprintf('\t\tIn use:\t\t\t%i',SPCModInfo.in_use));
    disp(sprintf('\t\tInit:\t\t\t%i',SPCModInfo.init));
    disp(sprintf('\t\tBase address:\t%i',SPCModInfo.base_adr));
end

    
if (j==0)
    disp('  No modules found');
    return;
else
    disp(sprintf('Active module: %i',state.spc.acq.module));
end
state.spc.acq.module = 0;
handles=FLIM_getParameters(hObject,handles);
guidata(hObject,handles);

%set(handles.edit1, 'String', '00:00');

% if (exist('spc_init.mat') == 2)
%     fid = fopen('spc_init.mat');
%     [fileName,permission, machineormat] = fopen(fid);
%     fclose(fid);
%     state.spc.files.iniFile = fileName;
%     load (fileName);
%     state.spc.acq.SPCdata = SPCdata;
%     FLIM_setParameters;
%     FLIM_getParameters;
% end


end
