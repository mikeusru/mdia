function save_autoSetting(flag);
global state;
global gh;
global spc;


autoSetting.basename = state.files.baseName;
autoSetting.savePath = state.files.savePath;
autoSetting.repeatPeriod = state.acq.repeatPeriod;
autoSetting.numberOfSlices = state.acq.numberOfZSlices;
autoSetting.zStepPerSlice = state.acq.zStepSize;
autoSetting.numberOfFrames = state.acq.numberOfFrames;
%autoSetting.power = state.init.eom.maxPower(state.init.eom.scanLaserBeam);

autoSetting.zoomtens = state.acq.zoomtens;
autoSetting.zoomones = state.acq.zoomones;
autoSetting.zoomhundreds = state.acq.zoomhundreds;
autoSetting.scanRotation = state.acq.scanRotation;
autoSetting.scaleXShift = state.acq.scaleXShift;
autoSetting.scaleYShift = state.acq.scaleYShift;

autoSetting.fileCounter = state.files.fileCounter;


autoSetting.configName = state.standardMode.configName;
autoSetting.configPath = state.standardMode.configPath;

fid = fopen('spcm.ini');
[fileName,permission, machineormat] = fopen(fid);
[pathstr,name,ext,versn] = fileparts(fileName);
fclose(fid);
save([pathstr, '\autoSetting.mat'], 'autoSetting');

spc_filename = spc.filename;
save([pathstr, '\spc_backup.mat'], 'spc_filename');

spc_saveSPCSetting;

if nargin
    if flag
        saveCurrentUserSettings;
        %save([pathstr, '\state.mat'], 'state');
    end
end