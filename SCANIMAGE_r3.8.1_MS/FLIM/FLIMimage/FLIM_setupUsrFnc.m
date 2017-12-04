function FLIM_setupUsrFnc
global state gh

fName = getFullFileName('FLIM_Measurement.m');
state.userFcns.currentUserFcnId = 1;
allKeys = keys(state.userFcns.hEventMapUSR);
state.userFcns.saveTarget = 'USR';
for i = 1:length(state.userFcns.hEventMapUSR)
    addUserFcn(fName, allKeys{i});
end

fName2 = getFullFileName('start_spc_FLIMImage_yphys_AF.m');
addUSROnlyFcn(fName2, 'appOpen');

    function fileName1 = getFullFileName(fileN)
        fid = fopen(fileN);
        [fileName1,~, ~] = fopen(fid);
        %[pathstr,~,~] = fileparts(fileName1);
        fclose(fid);
    end

    function addUserFcn(fileName,key)

        hEvntMap = state.userFcns.(['hEventMap' state.userFcns.saveTarget]);
        evntStruct = hEvntMap(key);
        userFcnIdx = state.userFcns.currentUserFcnIdx;
        
        [pname,fnameNoExt] = fileparts(fileName);
        
        %Construct function 'kernel'
        if isempty(pname) %Built-in
            userFcnKernel = str2func(fnameNoExt);
        else
            prevPath = addpath(pname,'-begin','-frozen');
            userFcnKernel = str2func(fnameNoExt);
            path(prevPath);
        end
        
        %Update event structure record,
        evntStruct(userFcnIdx).userFcnName = fileName;
        evntStruct(userFcnIdx).userFcnKernel = userFcnKernel;
        
        %Update Event Map
        hEvntMap(key) = evntStruct;
        
        %Update listener & state vars
        updateUserFunctionState('updateListener','UserFcns',key,userFcnIdx);
        updateUserFunctionState('storeStateVars','UserFcns',[],userFcnIdx);
        
        %Update GUI (table data)
        updateUserFunctionsGUI('UserFcns',key);
        set(gh.userFunctionsGUI.pbAddUserFcns,'Enable','off');
        
        selectedTableCells('userFcns',[]);
    end


    function addUSROnlyFcn(filename,key)
        %global state gh;
        
        hUSROnlyMap = state.userFcns.hEventMapUSRONLY;
        usrOnlyStruct = hUSROnlyMap(key);
        
        [pname,filenameNoExtension] = fileparts(filename);
        
        %Construct function handle
        if isempty(pname) %Built-in
            hUSROnlyFcn = str2func(filenameNoExtension);
        else
            prevPath = addpath(pname,'-begin','-frozen');
            hUSROnlyFcn = str2func(filenameNoExtension);
            path(prevPath);
        end
        
        %Update event structure record,
        usrOnlyStruct.userFcnName = fullfile(pname,[filenameNoExtension '.m']);
        usrOnlyStruct.userFcnKernel = hUSROnlyFcn;
        hUSROnlyMap(key) = usrOnlyStruct;
        
        %Update listener & state vars
        updateUserFunctionState('updateListener','USROnlyFcns',key);
        updateUserFunctionState('storeStateVars','USROnlyFcns',[]);
        
        % Update the GUI
        updateUserFunctionsGUI('USROnlyFcns',key);
        set(gh.userFunctionsGUI.pbAddUsrOnlyFcns,'Enable','off');
        
        selectedTableCells('usrOnlyFcns',[]);
    end

end

