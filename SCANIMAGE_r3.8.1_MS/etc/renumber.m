% 1. Copy all the files you need renumbered in order into one folder 2. Run
% this script. It will sort all the files by name, create a
% folder called _REnumbered, and all the images will have an extra number
% added on at the end. This code relies on having an equal number of
% regular and .max files so the order should be 001.tif, 001max.tif, 002.tif,
% 002max.tif...

folder_name=uigetdir;
cd(folder_name);
listing=dir('*.tif');
mkdir('_REnumbered');
ds=struct2dataset(listing);
ds=sortrows(ds,'name','ascend');
counter=1;

for id=1:length(ds)
    [~,f] = fileparts(listing(id).name);
    % Convert to number
    if isempty(strfind(f,'Stack'))
        %     for i=1:length(f)
        %         if ~strfind(f,'Stack')')
        %             f(i)='_';
        if ~isempty(strfind(f,'max'))
            copyfile(listing(id).name, ['_REnumbered/','reNum','_',num2str(counter,'%03.0f'),'max','.tif']);
            counter=counter+1;
        else
            copyfile(listing(id).name, ['_REnumbered/','reNum','_',num2str(counter,'%03.0f'),'.tif']);
            
        end
        %         end
        
    end
end
