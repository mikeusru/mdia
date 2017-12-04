function varargout = yphys_stimScope(varargin)
% YPHYS_STIMSCOPE M-file for yphys_stimScope.fig
%      YPHYS_STIMSCOPE, by itself, creates a new YPHYS_STIMSCOPE or raises the existing
%      singleton*.
%
%      H = YPHYS_STIMSCOPE returns the handle to a new YPHYS_STIMSCOPE or
%      the handle to
%      the existing singleton*.
%
%      YPHYS_STIMSCOPE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in YPHYS_STIMSCOPE.M with the given input arguments.
%
%      YPHYS_STIMSCOPE('Property','Value',...) creates a new YPHYS_STIMSCOPE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before yphys_stimScope_OpeningFunction gets
%      called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to yphys_stimScope_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help yphys_stimScope

% Last Modified by GUIDE v2.5 06-Jul-2010 22:46:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @yphys_stimScope_OpeningFcn, ...
                   'gui_OutputFcn',  @yphys_stimScope_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before yphys_stimScope is made visible.
function yphys_stimScope_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to yphys_stimScope (see VARARGIN)

% Choose default command line output for yphys_stimScope
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes yphys_stimScope wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global state gh
gh.yphys.stimScope = handles;

% if findobj('Tag', 'stimPlotFig')
%     gh.yphys.stimPlotFig = findobj('Tag', 'stimPlotFig');
% else
%     gh.yphys.stimPlotFig = figure('Tag', 'stimPlotFig');
% end
% figure(gh.yphys.stimPlotFig);
% gh.yphys.stimPlot = plot(zeros(32, 1));

axes(handles.axes1);
gh.yphys.pulsePlot1 = plot(zeros(32, 1));
ylabel(handles.axes1, 'Patch (mV/pA)');
xlabel(handles.axes1, 'Time (ms)');

axes(handles.axes2);
gh.yphys.pulsePlot2 = plot(zeros(32, 1));
ylabel(handles.axes2, 'Stim (mV/pA)');
xlabel(handles.axes2, 'Time (ms)');

axes(handles.axes3);
gh.yphys.pulsePlot3 = plot(zeros(32, 1));
ylabel(handles.axes3, 'Power (%)');
xlabel(handles.axes3, 'Time (ms)');



yphys_setupGraphics;
try
    if isfield(state.yphys, 'init')
        if isfield(state.yphys.init, 'multiClampFileName')
            yphys_setup(1, 0);
        else
            yphys_setup(1, 1);
        end
    else
        yphys_setup(1, 1);
    end
end
yphys_setupParameters;
%yphys_generic;
%yphys_mkPulse(rate, nstim, dwell, amp2, delay)

state.yphys.acq.phys_counter = 1;

% --- Outputs from this function are returned to the command line.
function varargout = yphys_stimScope_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state;
global gh;
global ua dia;

yphys_generic;

ntrain = state.yphys.acq.ntrain(state.yphys.acq.pulseN);
interval = state.yphys.acq.interval(state.yphys.acq.pulseN);
theta = state.yphys.acq.theta;


ext = get(gh.yphys.stimScope.ext, 'value');
ap = get(gh.yphys.stimScope.ap, 'value'); %state.yphys.acq.ap;
uncage=get(gh.yphys.stimScope.Uncage, 'value');   %state.yphys.acq.uncage;
stim = get(gh.yphys.stimScope.Stim, 'value');


try
    stop(state.yphys.init.phys);
    stop(state.yphys.init.phys_patch);
    stop(state.yphys.init.phys_input);
    try
        stop(state.yphys.init.phys_setting);
    end
    try
        set(gh.yphys.scope.start, 'String', 'START');
    end
    try
        stop(state.yphys.timer.patch_timer);
    end
    delete(state.yphys.timer.patch_timer);
end

%yphys_mkPulse(freq, nstim, dwell, amp, delay);

if strcmp(get(gh.yphys.stimScope.start, 'String'), 'Start')
	set(gh.yphys.stimScope.start, 'String', 'Stop');
    set(gh.yphys.stimScope.start, 'Enable', 'Off');
    cycleSet = str2num(get(gh.yphys.stimScope.cycleSet, 'String'));
    if ~isempty(cycleSet)
        cyclePos = mod(state.yphys.acq.phys_counter-1, length(cycleSet))+1;
        cycleStr = num2str(cycleSet(cyclePos));
        set(gh.yphys.stimScope.pulseN, 'String', cycleStr);
        yphys_setupParameters;
        yphys_generic;
        yphys_loadAverage;
    else
        set(gh.yphys.stimScope.pulseN, 'String', num2str(state.yphys.acq.pulseN));
        %state.yphys.acq.pulseN
        yphys_setupParameters;
        yphys_generic;
    end
	if ntrain < 2
        state.yphys.acq.ing = 0;
        if ~uncage
% 			if theta & ap                
%                 yphys_thetaAP;
% 			else
%                 yphys_sendStim;
% 			end
            yphys_sendStim;
        else
            yphys_uncage;
            finishUAuncaging; %MISHA
        end
        set(gh.yphys.stimScope.start, 'String', 'Start');
	else
        state.yphys.acq.looping = 1;
        state.yphys.acq.loopCounter = 0;
        state.yphys.internal.waiting = 0;
        %tic;
        yphys_getGain;
        if ext
            interval = 1;
        end
        state.yphys.timer.stim_timer =timer('TimerFcn','yphys_stimLoopFcn','ExecutionMode','fixedSpacing','Period', interval, 'Tag', 'stim');
        start(state.yphys.timer.stim_timer);
	end
else %(STOP)
    if state.yphys.acq.looping
        try
            stop(state.yphys.timer.stim_timer);
            delete(state.yphys.timer.stim_timer);
        end
        state.yphys.acq.looping = 0;
    end
    set(gh.yphys.stimScope.start, 'String', 'Start');
    set(gh.yphys.stimScope.start, 'Enable', 'On');
end





% --- Executes during object creation, after setting all properties.
function nstim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nstim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function nstim_Callback(hObject, eventdata, handles)
% hObject    handle to nstim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nstim as text
%        str2double(get(hObject,'String')) returns contents of nstim as a double

yphys_generic;


% --- Executes during object creation, after setting all properties.
function freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function freq_Callback(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq as text
%        str2double(get(hObject,'String')) returns contents of freq as a double
yphys_generic;



% --- Executes during object creation, after setting all properties.
function delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function delay_Callback(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay as text
%        str2double(get(hObject,'String')) returns contents of delay as a double

yphys_generic;

% --- Executes during object creation, after setting all properties.
function dwell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dwell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dwell_Callback(hObject, eventdata, handles)
% hObject    handle to dwell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dwell as text
%        str2double(get(hObject,'String')) returns contents of dwell as a double

yphys_generic;


function AddPulse_Callback(hObject, eventdata, handles)
% hObject    handle to AddPulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AddPulse as text
%        str2double(get(hObject,'String')) returns contents of AddPulse as a double


yphys_generic;


% --- Executes during object creation, after setting all properties.
function AddPulse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AddPulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ntrain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ntrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ntrain_Callback(hObject, eventdata, handles)
% hObject    handle to ntrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ntrain as text
%        str2double(get(hObject,'String')) returns contents of ntrain as a double
yphys_generic

% --- Executes during object creation, after setting all properties.
function interval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function interval_Callback(hObject, eventdata, handles)
% hObject    handle to interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of interval as text
%        str2double(get(hObject,'String')) returns contents of interval as a double
yphys_generic;

% --- Executes during object creation, after setting all properties.
function amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function amp_Callback(hObject, eventdata, handles)
% hObject    handle to amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp as text
%        str2double(get(hObject,'String')) returns contents of amp as a double
yphys_generic;

% --- Executes on button press in ext.
function ext_Callback(hObject, eventdata, handles)
% hObject    handle to ext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ext
yphys_generic;

% --- Executes on button press in ap.
function ap_Callback(hObject, eventdata, handles)
% hObject    handle to ap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ap
yphys_generic;

% --- Executes on button press in Stim.
function Stim_Callback(hObject, eventdata, handles)
% hObject    handle to Stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Stim
yphys_generic;

% --- Executes on button press in Theta.
function Theta_Callback(hObject, eventdata, handles)
% hObject    handle to Theta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Theta
yphys_generic;

% --- Executes on button press in theta.
function theta_Callback(hObject, eventdata, handles)
% hObject    handle to theta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of theta
yphys_generic;

% --- Executes on button press in Uncage.
function Uncage_Callback(hObject, eventdata, handles)
% hObject    handle to Uncage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Uncage
yphys_generic;

% --- Executes on button press in saveCheck.
function saveCheck_Callback(hObject, eventdata, handles)
% hObject    handle to saveCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveCheck
yphys_generic;

function Length_Callback(hObject, eventdata, handles)
% hObject    handle to Length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Length as text
%        str2double(get(hObject,'String')) returns contents of Length as a double
yphys_generic;

% --------------------------------------------------------------------
function RoiMenue_Callback(hObject, eventdata, handles)
% hObject    handle to RoiMenue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MakeRoi1_Callback(hObject, eventdata, handles)
% hObject    handle to MakeRoi1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_makeRoi(1);

% --------------------------------------------------------------------
function MakeRoi2_Callback(hObject, eventdata, handles)
% hObject    handle to MakeRoi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_makeRoi(2);

% --------------------------------------------------------------------
function MakeRoi3_Callback(hObject, eventdata, handles)
% hObject    handle to MakeRoi3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_makeRoi(3);


% --------------------------------------------------------------------
function MakeRoi4_Callback(hObject, eventdata, handles)
% hObject    handle to MakeRoi4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_makeRoi(4);

% --------------------------------------------------------------------
function MakeRoi5_Callback(hObject, eventdata, handles)
% hObject    handle to MakeRoi5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_makeRoi(5);

% --------------------------------------------------------------------
function MakeRoi6_Callback(hObject, eventdata, handles)
% hObject    handle to MakeRoi6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_makeRoi(6);

% --------------------------------------------------------------------
function MakeRoi7_Callback(hObject, eventdata, handles)
% hObject    handle to MakeRoi7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg('ROI Number', 'Creating ROI', 1, {'7'});
answer = str2num(answer{1});
yphys_makeRoi(answer);
% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Cal1_Callback(hObject, eventdata, handles)
% hObject    handle to Cal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_calibrateEom(1);
showCalibrationCurve(1);
% --------------------------------------------------------------------
function Cal2_Callback(hObject, eventdata, handles)
% hObject    handle to Cal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

yphys_calibrateEom(2);
showCalibrationCurve(2);




% --- Executes on button press in StimRadio.
function StimRadio_Callback(hObject, eventdata, handles)
% hObject    handle to StimRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StimRadio
mutual_exclude(hObject, handles);

% --- Executes on button press in PatchRadio.
function PatchRadio_Callback(hObject, eventdata, handles)
% hObject    handle to PatchRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PatchRadio
mutual_exclude(hObject, handles);


% --- Executes on button press in UncageRadio.
function UncageRadio_Callback(hObject, eventdata, handles)
% hObject    handle to UncageRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UncageRadio
mutual_exclude(hObject, handles);

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yphys_setupGraphics
global state
global gh

handles = gh.yphys.stimScope;


set(handles.start, 'String', 'Start')
if exist('yphys_init.mat')
    load('yphys_init.mat');
    try
        radio_on=find(state.yphys.acq.radio_on);
        if radio_on == 3
            set(handles.UncageRadio, 'Value', 1);
        elseif radio_on == 2
            set(handles.StimRadio, 'Value', 1);
        elseif radio_on == 1
            set(handles.PatchRadio, 'Value', 1);
        end
    catch
        set(handles.UncageRadio, 'Value', 1);
    end
    %mutual_exclude(handles.UncageRadio, handles);
    try
        state.yphys.acq = yphys_setting;
        state.yphys.acq.phys_counter = 1;
		set(handles.freq, 'String', num2str(state.yphys.acq.freq));
		set(handles.nstim, 'String', num2str(state.yphys.acq.nstim));
		set(handles.dwell, 'String', num2str(state.yphys.acq.dwell));
		set(handles.delay, 'String', num2str(state.yphys.acq.delay));	
		set(handles.amp, 'String', num2str(state.yphys.acq.amp));
        %
        if length(state.yphys.acq.interval) > 1
            set(handles.interval, 'String', num2str(state.yphys.acq.interval(state.yphys.acq.pulseN)));
            set(handles.ntrain, 'String', num2str(state.yphys.acq.ntrain(state.yphys.acq.pulseN)));
            set(handles.Length, 'String', num2str(state.yphys.acq.sLength(state.yphys.acq.pulseN)));
        else
            set(handles.interval, 'String', num2str(state.yphys.acq.interval));
            set(handles.ntrain, 'String', num2str(state.yphys.acq.ntrain));
            set(handles.Length, 'String', num2str(state.yphys.acq.sLength));        
        end
        %
        if isfield(state.yphys.acq, 'addP')
            set(handles.AddPulse, 'String', num2str(state.yphys.acq.addP));
        else
            set(handles.AddPulse, 'String', num2str(-1));
        end
        if isfield(state.yphys.acq, 'pulseName')
            set(handles.pulseName, 'String', state.yphys.acq.pulseName{state.yphys.acq.pulseN});
        else
            set(handles.pulseName, 'String', 'Pulse Name');
        end
        set(handles.ext, 'Value', state.yphys.acq.ext);
		set(handles.ap, 'Value', state.yphys.acq.ap);
        set(handles.Stim, 'Value', state.yphys.acq.stim);
		set(handles.theta, 'Value', state.yphys.acq.theta);
        set(handles.Uncage, 'Value', state.yphys.acq.uncage);
        set(handles.saveCheck, 'Value', state.yphys.acq.autoSave);
        set(handles.pulseN, 'String', state.yphys.acq.pulseN);
        set(handles.epochN, 'String', state.yphys.acq.epochN);
        set(handles.cycleSet, 'String', num2str(state.yphys.acq.cycleSet));
    catch
            beep; beep; beep;
            disp('Setting was not loaded');
        	set(handles.freq, 'String', '50');
			set(handles.nstim, 'String', '1');
			set(handles.dwell, 'String', '1');
			set(handles.delay, 'String', '50');
			set(handles.interval, 'String', '10');
			set(handles.ntrain, 'String', '1');
			set(handles.amp, 'String', '5');
            set(handles.Length, 'String', '150');
            set(handles.AddPulse, 'String', '-1');
			set(handles.ext, 'Value', 0);
			set(handles.ap, 'Value', 0);
			set(handles.theta, 'Value', 0);
            set(handles.saveCheck, 'Value', 0);
            set(handles.pulseName, 'String', 'Pulse Name');
    end
else
	set(handles.freq, 'String', '50');
	set(handles.nstim, 'String', '1');
	set(handles.dwell, 'String', '1');
	set(handles.delay, 'String', '50');
	set(handles.interval, 'String', '10');
	set(handles.ntrain, 'String', '1');
	set(handles.amp, 'String', '5');
    set(handles.Length, 'String', '150');
    set(handles.AddPulse, 'String', '-1');
    set(handles.pulseName, 'String', 'Pulse Name');
	set(handles.ext, 'Value', 0);
	set(handles.ap, 'Value', 0);
    set(handles.stim, 'Value', 0);
	set(handles.theta, 'Value', 0);
    set(handles.saveCheck, 'Value', 0);
end


% --------------------------------------------------------------------
function Restart_Callback(hObject, eventdata, handles)
% hObject    handle to Restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state;
pos = get(gcf, 'Position');
yphys_stimclosereq;
yphys_stimScope;
set(gcf, 'Position', pos);
state.yphys.acq.phys_counter = 0;

% --------------------------------------------------------------------
function mutual_exclude(h, handles)
Radiobuttons = [handles.UncageRadio,handles.StimRadio, handles.PatchRadio];
off = (Radiobuttons == h);
set(Radiobuttons(~off),'Value',0);
yphys_setupParameters;
yphys_generic;
% --------------------------------------------------------------------
function on = Radiobutton_values (handles)

on(1) = get(handles.PatchRadio, 'Value');
on(2) = get(handles.StimRadio, 'Value');
on(3) = get(handles.UncageRadio, 'Value');



% --- Executes during object creation, after setting all properties.
function Length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Open_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Open_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global yphys

[fname,pname] = uigetfile('*.mat','Select wave');
if pname~=0 %Misha 0405215 - just so there's no error when cancel is pressed
    cd (pname);
    filestr = [pname, fname];
    yphys_loadYphys(filestr);
end

% --- Executes on button press in Pre.
function Pre_Callback(hObject, eventdata, handles)
% hObject    handle to Pre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global yphys
global state

if isfield(yphys, 'filename')
    try
        [pathstr,filenamestr,extstr] = fileparts(yphys.filename);
         num = str2num(filenamestr(end-2: end)) - 1;
         numchar = num2str(num);
            for i=1:3-length(numchar)
                numchar = ['0', numchar];
            end
            filenamestr = ['yphys', numchar];
    catch
        num = 1;
        numchar = num2str(num);
        pathstr = [state.files.savePath, 'spc'];
        filenamestr = ['yphys', numchar];
    end
end
if exist([pathstr, '\', filenamestr, extstr])
    yphys_loadYphys([pathstr, '\', filenamestr, extstr]);
end

% --- Executes on button press in Post.
function Post_Callback(hObject, eventdata, handles)
% hObject    handle to Post (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global yphys
if isfield(yphys, 'filename')
    [pathstr,filenamestr,extstr] = fileparts(yphys.filename);
     num = str2num(filenamestr(end-2: end)) + 1;
     numchar = num2str(num);
        for i=1:3-length(numchar)
            numchar = ['0', numchar];
        end
		filenamestr = ['yphys', numchar];
end
if exist([pathstr, '\', filenamestr, extstr])
    yphys_loadYphys([pathstr, '\', filenamestr, extstr]);
end

% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global yphys

yphys.aveData = yphys.data.data;
yphys.aveString = [];
yphys.aveString{1} = yphys.filename;
fave = imfilter(yphys.aveData(:,2), ones(yphys.fwindow, 1)/yphys.fwindow);
set(yphys.figure.avePlot, 'XData', yphys.data.data(:,1), 'YData', fave, 'color', 'red');
yphys_updateAverage;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileN_Callback(hObject, eventdata, handles)
global yphys

numchar = get(hObject, 'String');

if isfield(yphys, 'filename')
    [pathstr,filenamestr,extstr] = fileparts(yphys.filename);
        for i=1:3-length(numchar)
            numchar = ['0', numchar];
        end
		filenamestr = ['yphys', numchar];
end
if exist([pathstr, '\', filenamestr, extstr])
    yphys_loadYphys([pathstr, '\', filenamestr, extstr]);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1

%%%%%%%%%%%%%%%%%%%%%%%
%PULSE SET CONTROLS
%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in postSet.
function postSet_Callback(hObject, eventdata, handles)
% hObject    handle to postSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pulseN = str2num(get(handles.pulseN, 'String'));
if pulseN > 0
    set(handles.pulseN, 'String', num2str(pulseN+1));
    try
        yphys_setupParameters;
    catch
        set(handles.pulseN, 'String', num2str(pulseN));
    end
end
yphys_generic;
yphys_loadAverage;
%yphys_generic;

% --- Executes on button press in preSet.
function preSet_Callback(hObject, eventdata, handles)
% hObject    handle to preSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pulseN = str2num(get(handles.pulseN, 'String'));
if pulseN > 1
    yphys_setupParameters
    set(handles.pulseN, 'String', num2str(pulseN-1));
    try
        yphys_setupParameters;
    catch
        set(handles.pulseN, 'String', num2str(pulseN));
    end
end

yphys_generic;
yphys_loadAverage;
%yphys_generic;

% --- Executes during object creation, after setting all properties.
function cycleSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cycleSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in newSet.
function newSet_Callback(hObject, eventdata, handles)
% hObject    handle to newSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in delSet.
function delSet_Callback(hObject, eventdata, handles)
% hObject    handle to delSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function cycleSet_Callback(hObject, eventdata, handles)
% hObject    handle to cycleSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cycleSet as text
%        str2double(get(hObject,'String')) returns contents of cycleSet as a double

yphys_generic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in Reject.
function Reject_Callback(hObject, eventdata, handles)
% hObject    handle to Reject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global yphys;
global gh;
if ~isfield(yphys, 'aveData')
    yphys.aveData = yphys.data.data;
    yphys.aveString{1} = yphys.filename;
end
tmpData = yphys.data.data;

[pathstr, filenamestr, extstr]=fileparts(yphys.filename);
for i=1:length(yphys.aveString); c(i) = ~isempty(findstr(filenamestr, yphys.aveString{i})); end

if find(c)
        if find(c) == 1
            yphys.aveString = yphys.aveString([2:end]);
        elseif find(c) < length(yphys.aveString)
            yphys.aveString = yphys.aveString([1:find(c)-1, find(c)+1:end]);
        else
            yphys.aveString = yphys.aveString([1:end-1]);
        end
        yphys.aveData(:, 2) = (-tmpData(:, 2) + yphys.aveData(:, 2)*(length(yphys.aveString)+1))/length(yphys.aveString);
        if ishandle(yphys.figure.avePlot)
		    set(yphys.figure.avePlot, 'XData', yphys.aveData(:,1), 'YData', yphys.aveData(:,2), 'color', 'green');
        end
end
yphys_updateAverage;
yphys_generic;

% --- Executes on button press in preEpoch.
function preEpoch_Callback(hObject, eventdata, handles)
% hObject    handle to preEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num = str2num(get(handles.epochN, 'String'));
if num > 1
    num = num-1;
end
set (handles.epochN, 'String', num2str(num));
yphys_generic;
yphys_loadAverage;


% --- Executes on button press in postEpoch.
function postEpoch_Callback(hObject, eventdata, handles)
% hObject    handle to postEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num = str2num(get(handles.epochN, 'String'));
set (handles.epochN, 'String', num2str(num+1));
yphys_generic;
yphys_loadAverage;


% --- Executes on button press in ave.
function ave_Callback(hObject, eventdata, handles)
% hObject    handle to ave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_generic;
yphys_averageData;



% --------------------------------------------------------------------
function scope_Callback(hObject, eventdata, handles)
% hObject    handle to scope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

yphys_scope;


% --------------------------------------------------------------------
function calcium_Callback(hObject, eventdata, handles)
% hObject    handle to calcium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function ImagesToAverage_Callback(hObject, eventdata, handles)
% hObject    handle to ImagesToAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global yphys;
global state;

prompt = {'Enter image numbers to average in matlab format (i.e. [1,2,3:5])'};
dlg_title = 'Image numbers';
num_lines= 1;
def     = {num2str(yphys.image.aveImage)};
answer  = inputdlg(prompt,dlg_title,num_lines,def);

yphys.image.aveImage = str2num(answer{1});

yphys_showImageTraces;
filenamestr2 = ['e', num2str(state.yphys.acq.epochN), 'p', num2str(state.yphys.acq.pulseN), '_int'];
saveAverage.average = yphys.image.average;
saveAverage.aveImage = yphys.image.aveImage;
evalc([filenamestr2, '=saveAverage']);
save(filenamestr2, filenamestr2);

% --------------------------------------------------------------------
function PreImage_Callback(hObject, eventdata, handles)
% hObject    handle to PreImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global yphys;
yphys.image.currentImage = yphys.image.currentImage-1;
yphys_showImageTraces;

% --------------------------------------------------------------------
function PostImage_Callback(hObject, eventdata, handles)
% hObject    handle to PostImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global yphys;

yphys.image.currentImage = yphys.image.currentImage+1;
yphys_showImageTraces;

% --------------------------------------------------------------------
function RejectFromAverage_Callback(hObject, eventdata, handles)
% hObject    handle to RejectFromAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function LoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_loadImage;
yphys_loadAverage;
try
    yphys_showImageTraces;
catch
end
% --------------------------------------------------------------------
function CurrentImage_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global yphys;
prompt = {'Enter calcium trace'};
dlg_title = 'Image numbers';
num_lines= 1;
def     = {num2str(yphys.image.currentImage)};
answer  = inputdlg(prompt,dlg_title,num_lines,def);

%yphys.image.aveImage = str2num(answer{1});
yphys.image.currentImage = str2num(answer{1});
yphys_showImageTraces;


% --------------------------------------------------------------------
function SetupCalciumImaging_Callback(hObject, eventdata, handles)
% hObject    handle to SetupCalciumImaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

yphys_setupCalcium;



% --------------------------------------------------------------------
function pageControls_Callback(hObject, eventdata, handles)
% hObject    handle to pageControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_pageControls;


% --------------------------------------------------------------------
function Reset_Counter_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_Counter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state;
global ysum;
global yphys;

yphys.data = [];
yphys.aveData = [];

%clear global yphys;
state.yphys.acq.phys_counter = 0;
if isfield (state, 'files')
   spcfolder = [state.files.savePath, 'spc'];
   if ~(exist(spcfolder) == 7)
       mkdir(spcfolder);
   end
end
ysum = [];






function pulseName_Callback(hObject, eventdata, handles)
% hObject    handle to pulseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pulseName as text
%        str2double(get(hObject,'String')) returns contents of pulseName as a double
yphys_generic;

% --- Executes during object creation, after setting all properties.
function pulseName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pulseN_Callback (hObject, eventdata, handles)
global state
pulseN = str2num(get(handles.pulseN, 'String'));
if pulseN > 0
    set(handles.pulseN, 'String', num2str(pulseN));
    try
        yphys_setupParameters;
    catch
        set(handles.pulseN, 'String', num2str(state.yphys.acq.pulseN));
    end
else
    set(handles.pulseN, 'String', num2str(state.yphys.acq.pulseN));
end
yphys_generic;
yphys_loadAverage;


