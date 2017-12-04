function spc_set_msPerLine(val)

global gh;
global state;

val = round(log2(val))+1;
if val > 4
    val = 4;
end
set(gh.advancedConfigurationGUI.msPerLine, 'Value', val)
genericCallback(gh.advancedConfigurationGUI.msPerLine);
setAcquisitionParameters;
applyConfigurationSettings;
val = 2^(val-1);
disp(['msPerLine ws set to ', num2str(val), ' msec']);