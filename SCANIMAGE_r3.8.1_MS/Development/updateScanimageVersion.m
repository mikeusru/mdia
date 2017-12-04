function updateScanimageVersion
%%update scanimage version
checkFileList={...
    'internal.ini';...
    'standard_model.ini';...
    'defaults.ini';...
    'standard_user.usr';...
    'flim_ini.m';...
    'spcm_ry.ini';...
    'spc_init.mat';...
    'yphys_init.mat';...
    };

%% popup window allowing user to set options
f=figure('Name','Set Upgrade Options','MenuBar','none');
fPos = get(f,'Position');
fPos = [fPos(1),fPos(2),300,400];
set(f,'Position',fPos);
p=[30,fPos(4)-30,130,20];
uicontrol(f,'Style','text','String','Select Files to Keep','Position',p);
p(2) = p(2) - 30;
for i=1:length(checkFileList)
    cb(i) = uicontrol(f,'Style','checkbox','String',checkFileList{i,1},'Value',1,'Position',p);
    p(2) = p(2) - 30;
end

pb(1) =  uicontrol(f,'Style','pushbutton','String','Select Old Directory','Position',p,'Callback',@setFolderOrigin);
p(2) = p(2) - 30;
pb(2) = uicontrol(f,'Style','pushbutton','String','Select New Directory','Position',p,'Callback',@setFolderNew);
p(2) = p(2) - 30;

%finish button
pb(3) = uicontrol(f,'Style','pushbutton','String','Done','Position',p,'Callback','uiresume(gcbf)');
p(2) = p(2) - 30;

uiwait(f); %wait until 'done' is pressed

ind = false(size(checkFileList));
for i=1:length(checkFileList)
    ind(i) = get(cb(i),'Value');
end
checkFileList = checkFileList(ind);

close(f);


%% backup original directory
fileListOrigin = getAllFiles(folderOrigin);

[a,b,c] = fileparts(folderOrigin);
backup_folder=[a,'\scanimage_Backup_Old\',date,'\',b,c];
disp(['Backing Up Old Version to ',backup_folder]);

fileTargetListBackup = fileListOrigin;
fileTargetListBackup = cellfun(@(x) strrep(x,folderOrigin,backup_folder),...
    fileTargetListBackup,'UniformOutput',false);

%backup original folder
copyOrDeleteFilesFromList(fileListOrigin,fileTargetListBackup,'backup');

%delete all but saved files
for i=1:length(checkFileList)
    ind=find(~cellfun(@isempty,strfind(fileListOrigin,checkFileList{i})));
    if ~isempty(ind)
        for j=1:length(ind)
            disp(['ignoring ', fileListOrigin{ind(j)}]);
        end
        fileListOrigin(ind)=[];
    end
end

%Delete Old Files
copyOrDeleteFilesFromList(fileListOrigin,[],'delete');

fileListNew = getAllFiles(folderNew);

%remove files which don't need to be re-written from new list
for i=1:length(checkFileList)
    ind=find(~cellfun(@isempty,strfind(fileListNew,checkFileList{i})));
    if ~isempty(ind)
        for j=1:length(ind)
            disp(['ignoring ', fileListNew{ind(j)}]);
        end
        fileListNew(ind)=[];
    end
end

[a,b,c] = fileparts(folderNew);
target_folder=[a,'\scanimage_Backup_Old\',date,'\',b,c];
disp(['Copying New Files To ',folderOrigin]);

fileTargetListNew = fileListNew;
fileTargetListNew = cellfun(@(x) strrep(x,folderNew,folderOrigin),...
    fileTargetListNew,'UniformOutput',false);

copyOrDeleteFilesFromList(fileListNew,fileTargetListNew,'copy');

disp('');
disp('');
disp('');
disp('');
disp('Done!');
disp('');
disp('');
disp('');
disp('');
    function copyOrDeleteFilesFromList(fileList,fileTargetList,copyOrDelete)
        switch copyOrDelete
            case 'backup'
                waitBarName = 'Backing Up Files...';
                justDoCopy = true;
            case 'copy'
                waitBarName = 'Copying Files...';
                justDoCopy = true;
            case 'delete'
                waitBarName = 'Deleting Files...';
                justDoCopy = false;
                fileTargetList = fileList;
        end
        
        %% copy files
        h=waitbar(0,'...','Name',waitBarName,'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        maxbar=length(fileList);
        for i=1:maxbar
            %check cancel button press
            if getappdata(h,'canceling')
                break
            end
            % Report current file being copied
            [folderName,fileName,ext]=fileparts(fileTargetList{i});
            if justDoCopy && ~exist(folderName,'dir')
                mkdir(folderName)
            end
            waitbar(i/maxbar,h,[fileName,ext]);
            if justDoCopy
                % copy the file
                [status,message] = copyfile(fileList{i},folderName,'f');
                if ~status
                    disp(message)
                    return
                end
            else
                delete(fileList{i});
            end
        end
        delete(h)       % DELETE the waitbar; don't try to CLOSE it.
    end


%% functions for buttons

    function setFolderOrigin(~,~,~)
        folderOrigin = uigetdir('','Select Old ''SCANIMAGE_r3.8...'' Version Folder');
    end

    function setFolderNew(~,~,~)
        folderNew = uigetdir('','Select New Version Folder');
    end

%%

end
