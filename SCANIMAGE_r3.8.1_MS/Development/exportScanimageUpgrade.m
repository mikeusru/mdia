function exportScanimageUpgrade
%%Copy directory while ignoring certain files

% ignoreFileList={...
%     'test workspace';...
%     'internal.ini';...
%     'standard_model.ini';...
%     'defaults.ini';...
%     'standard_user.usr';...
%     };

folder_name=uigetdir;
fileList = getAllFiles(folder_name);
% 
% for i=1:length(ignoreFileList)
%     ind=find(~cellfun(@isempty,strfind(fileList,ignoreFileList{i})));
%     if ~isempty(ind)
%         for j=1:length(ind)
%             disp(['ignoring ', fileList{ind(j)}]);
%         end
%         fileList(ind)=[];
%     end
% end


[a,b,c] = fileparts(folder_name);

target_folder=[a,'\upgradeExport\',b,c];
disp(['Exporting to ',target_folder]);

fileTargetList = fileList;
% fileList = cellfun(@(x) strrep(x,'\','/'),...
%     fileList,'UniformOutput',false);
% fileTargetList = cellfun(@(x) strrep(x,'\','/'),...
%     fileTargetList,'UniformOutput',false);
fileTargetList = cellfun(@(x) strrep(x,folder_name,target_folder),...
    fileTargetList,'UniformOutput',false);


%% copy files
h=waitbar(0,'...','Name','Copying Files...','CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');
maxbar=length(fileList);
for i=1:maxbar
    %check cancel button press
    if getappdata(h,'canceling')
        break
    end
    % Report current file being copied
    [folderName,fileName,ext]=fileparts(fileTargetList{i});
    if ~exist(folderName,'dir')
        mkdir(folderName)
    end
    waitbar(i/maxbar,h,[fileName,ext]);
    % copy the file
    [status,message] = copyfile(fileList{i},folderName,'f');
    if ~status
        disp(message)
        break
    end
end
delete(h)       % DELETE the waitbar; don't try to CLOSE it.
disp('DONE');