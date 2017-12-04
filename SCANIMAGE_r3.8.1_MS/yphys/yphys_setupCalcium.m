function yphys_setupCalcium
global yphys
global gh
global state

numberOfSlices = 1;
numberOfFrames = 15;
repeatPeriod = 15;

str =  'yphys_calcium.m';
    if sum(strcmp(state.UserFcnGUI.UserFcnSelected, str))
    else
        if isempty(state.UserFcnGUI.UserFcnSelected)
            state.UserFcnGUI.UserFcnSelected={str};
        elseif iscellstr(state.UserFcnGUI.UserFcnSelected)
                state.UserFcnGUI.UserFcnSelected{length(state.UserFcnGUI.UserFcnSelected)+1}=...
                str;
        end
        set(gh.UserFcnGUI.UserFcnSelected,'String',state.UserFcnGUI.UserFcnSelected);
    end

    val = round(log2(128))-3;
set(gh.basicConfigurationGUI.pixelsPerLine, 'Value', val);
state.acq.pixelsPerLineGUI = get(gh.basicConfigurationGUI.pixelsPerLine,'Value');
state.acq.pixelsPerLine = str2num(getMenuEntry(gh.basicConfigurationGUI.pixelsPerLine, state.acq.pixelsPerLineGUI));
genericCallback(gh.basicConfigurationGUI.pixelsPerLine);

set(gh.basicConfigurationGUI.linesPerFrame, 'String', '32');
genericCallback(gh.basicConfigurationGUI.linesPerFrame);
%setAcquisitionParameters;
applyConfigurationSettings;


set(gh.yphys.stimScope.ap, 'Value', 1);
set(gh.yphys.stimScope.Stim, 'Value', 0);
set(gh.yphys.stimScope.Uncage, 'Value', 0);

set(gh.spc.FLIMimage.Uncage, 'Value', 1);
state.spc.acq.uncageBox = 1;

set(gh.spc.FLIMimage.image, 'Value', 1);
state.spc.acq.spc_image = 1;

set(gh.mainControls.shutterDelay, 'String', 1)
genericCallback(gh.mainControls.shutterDelay);
updateShutterDelay;

set(gh.spc.FLIMimage.uncageEveryFrame, 'String', num2str(numberOfFrames));
state.spc.acq.uncageEveryXFrame = numberOfFrames;

set(gh.spc.FLIMimage.flimcheck, 'Value', 0);
state.spc.acq.spc_takeFLIM = 0;

set(gh.standardModeGUI.repeatPeriod, 'String', num2str(repeatPeriod));
genericCallback(gh.standardModeGUI.repeatPeriod);

set(gh.standardModeGUI.numberOfSlices, 'String', num2str(numberOfSlices));
genericCallback(gh.standardModeGUI.numberOfSlices);
state.acq.numberOfZSlices=state.standardMode.numberOfZSlices;
updateGuiByGlobal('state.acq.numberOfZSlices');
preallocateMemory;

set(gh.standardModeGUI.numberOfFrames, 'String', num2str(numberOfFrames));
genericCallback(gh.standardModeGUI.numberOfFrames);
state.acq.numberOfFrames=state.standardMode.numberOfFrames;
updateGuiByGlobal('state.acq.numberOfFrames');
preAllocateMemory;
alterDAQ_NewNumberOfFrames;

set(gh.standardModeGUI.averageFrames, 'Value', 0);
genericCallback(gh.standardModeGUI.averageFrames);
state.acq.averaging=state.standardMode.averaging;
updateHeaderString('state.acq.averaging');
preallocateMemory;

state.acq.scaleXShift = 0;
state.acq.ScaleYShift = 0;
updateGUIByGlobal('state.acq.scaleXShift');
updateGUIByGlobal('state.acq.scaleYShift');

scanRotation = 0;
h = gh.mainControls.scanRotation;
set(h, 'String', num2str(scanRotation));
genericCallback(h);
setScanProps(h);
