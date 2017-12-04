function spc_goto(n)
global state;
global gh;
global spc_d;

str = ['autoSetting = spc_d.def', num2str(n)];
eval(str);

repeatPeriod = autoSetting.repeatPeriod;
numberOfSlices = autoSetting.numberOfSlices;
zStepPerSlice = autoSetting.zStepPerSlice;
numberOfFrames = autoSetting.numberOfFrames;
power = autoSetting.power;

scanRotation = autoSetting.scanRotation;
state.acq.zoomtens=autoSetting.zoomtens;
state.acq.zoomones=autoSetting.zoomones;
state.acq.zoomhundreds = autoSetting.zoomhundreds;

set(gh.standardModeGUI.repeatPeriod, 'String', num2str(repeatPeriod));
genericCallback(gh.standardModeGUI.repeatPeriod);

set(gh.standardModeGUI.numberOfSlices, 'String', num2str(numberOfSlices));
genericCallback(gh.standardModeGUI.numberOfSlices);
state.acq.numberOfZSlices=state.standardMode.numberOfZSlices;
updateGuiByGlobal('state.acq.numberOfZSlices');
preallocateMemory;

set(gh.standardModeGUI.zStepPerSlice, 'String', num2str(zStepPerSlice));
genericCallback(gh.standardModeGUI.zStepPerSlice);
state.acq.zStepSize=state.standardMode.zStepPerSlice;
updateHeaderString('state.acq.zStepSize');
    
set(gh.standardModeGUI.numberOfFrames, 'String', num2str(numberOfFrames));
genericCallback(gh.standardModeGUI.numberOfFrames);
state.acq.numberOfFrames=state.standardMode.numberOfFrames;
updateGuiByGlobal('state.acq.numberOfFrames');
preAllocateMemory;
alterDAQ_NewNumberOfFrames;

set(gh.powerControl.maxPower_Slider, 'value', power);
genericCallback(gh.powerControl.maxPower_Slider);
state.init.eom.maxPower(state.init.eom.beamMenu) = round(state.init.eom.maxPowerDisplaySlider);
state.init.eom.changed(state.init.eom.beamMenu)=1;
ensureEomGuiStates;

updateGUIByGlobal('state.acq.zoomones');
updateGUIByGlobal('state.acq.zoomtens');
updateGUIByGlobal('state.acq.zoomhundreds');
state.acq.zoomFactor=str2num([num2str(round(state.acq.zoomhundreds))...
        num2str(round(state.acq.zoomtens)) num2str(round(state.acq.zoomones))]);
if state.acq.zoomFactor < 1
    state.acq.zoomFactor=1;
    state.acq.zoomones=1;
    updateGUIByGlobal('state.acq.zoomones');
end
setScanProps(gh.mainControls.zoomonesslider);

h = gh.mainControls.scanRotation;
set(h, 'String', num2str(scanRotation));
genericCallback(h);
setScanProps(h);

set(gh.motorGUI.positionSlider, 'Value', n);
genericCallback(gh.motorGUI.positionSlider);
	global gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	gotoPosition;
	turnOnMotorButtons;
