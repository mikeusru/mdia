function spc_set_Npixels(val1, val2)

global gh;
global state;
str = num2str(val2);
val = round(log2(val1))-3;
if val < 1
    val = 1;
end
if val > 7
    val = 7;
end
%state.internal.configurationChanged=1;
if val1 > val2
    xamp = str2num(get(gh.basicConfigurationGUI.xScanAmplitude, 'String'));
    yamp = str2num(get(gh.basicConfigurationGUI.yScanAmplitude, 'String'));
    yamp = 2.5 * val2 / val1;
    xamp = 2.5;
elseif val1 < val2
    xamp = str2num(get(gh.basicConfigurationGUI.xScanAmplitude, 'String'));
    yamp = str2num(get(gh.basicConfigurationGUI.yScanAmplitude, 'String'));
    xamp = 2.5 * val1 / val2;
    yamp = 2.5;
else val1 == val2
    xamp = 2.5;
    yamp = 2.5;
end
set(gh.basicConfigurationGUI.xScanAmplitude, 'String', num2str(xamp));
set(gh.basicConfigurationGUI.yScanAmplitude, 'String', num2str(yamp));
genericCallback(gh.basicConfigurationGUI.xScanAmplitude);
genericCallback(gh.basicConfigurationGUI.yScanAmplitude);

state.internal.aspectRatioChanged==1;

set(gh.basicConfigurationGUI.pixelsPerLine, 'Value', val);
state.acq.pixelsPerLineGUI = get(gh.basicConfigurationGUI.pixelsPerLine,'Value');
state.acq.pixelsPerLine = str2num(getMenuEntry(gh.basicConfigurationGUI.pixelsPerLine, state.acq.pixelsPerLineGUI));
genericCallback(gh.basicConfigurationGUI.pixelsPerLine);

set(gh.basicConfigurationGUI.linesPerFrame, 'String', str);
genericCallback(gh.basicConfigurationGUI.linesPerFrame);
%setAcquisitionParameters;
applyConfigurationSettings;

val = 2^(val+3);
disp(['N of pixels was set to ', num2str(val), 'x', str]);