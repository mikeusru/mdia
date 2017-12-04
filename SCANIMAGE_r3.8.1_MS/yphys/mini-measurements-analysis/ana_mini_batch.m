% pathNs = {'C:\data\Ana\ac113\ac113b\spc', 'C:\data\Ana\ac113\ac113c\spc', 'C:\data\Ana\ac113\ac113d\spc', ...
%     'C:\data\Ana\ac114\ac114a\spc', 'C:\data\Ana\ac114\ac114b\spc', 'C:\data\Ana\ac115\ac115a\spc'}
pathNs = {pwd};
for j = 1:length(pathNs)
    cd (pathNs{j});
    yphys_mini_scanFolder;
    warning off;
    mini = yphys_mini_statFolder;
end