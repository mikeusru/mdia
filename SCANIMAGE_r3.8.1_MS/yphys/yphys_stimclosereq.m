function yphys_stimclosereq
global state gh


yphys_setting = state.yphys.acq;

fid = fopen('yphys_setup.m');
[fileName,permission, machineormat] = fopen(fid);
[pathstr,name,ext] = fileparts(fileName);
fclose(fid);

save([pathstr, '\yphys_init.mat'], 'yphys_setting');

hideGUI(gh.yphys.stimScope.figure1);
%closereq;