folder_name=uigetdir;
cd(folder_name);
listing=dir('*.tif');
mkdir('noSpaces');
for id=1:length(listing)
    [~,f] = fileparts(listing(id).name);
    % Convert to number
    for i=1:length(f)
        if strcmp(f(i),' ')
            f(i)='_';
            copyfile(listing(id).name, ['noSpaces/',sprintf(f),'.tif']);
        end
    end
end
