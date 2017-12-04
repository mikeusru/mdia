function varargout = yphys_scope(varargin)
% YPHYS_SCOPE M-file for yphys_scope.fig
%      YPHYS_SCOPE, by itself, creates a new YPHYS_SCOPE or raises the existing
%      singleton*.
%
%      H = YPHYS_SCOPE returns the handle to a new YPHYS_SCOPE or the handle to
%      the existing singleton*.
%
%      YPHYS_SCOPE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in YPHYS_SCOPE.M with the given input arguments.
%
%      YPHYS_SCOPE('Property','Value',...) creates a new YPHYS_SCOPE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before yphys_scope_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to yphys_scope_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help yphys_scope

% Last Modified by GUIDE v2.5 06-Jul-2010 15:16:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @yphys_scope_OpeningFcn, ...
                   'gui_OutputFcn',  @yphys_scope_OutputFcn, ...
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


% --- Executes just before yphys_scope is made visible.
function yphys_scope_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to yphys_scope (see VARARGIN)

% Choose default command line output for yphys_scope
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes yphys_scope wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global state;
global gh;

gh.yphys.scope = handles;

if ~isfield(state, 'yphys')
    state.yphys = [];
end

if ~isfield(state.yphys, 'acq')
    state.yphys.acq = [];
end

if ~isfield(state.yphys.acq, 'vamplitude')
    state.yphys.acq.vamplitude = -5;
end

if ~isfield(state.yphys.acq, 'camplitude')
    state.yphys.acq.camplitude = 1000;
end

if ~isfield(state.yphys.acq, 'vwidth')
    vphase(1:3) = [50,50,50];  %milisecond
    state.yphys.acq.vwidth = 50;
    vamplitude = -5; %mV
else
    vphase = [state.yphys.acq.vwidth, state.yphys.acq.vwidth, state.yphys.acq.vwidth];
end

if ~isfield(state.yphys.acq, 'cwidth')
	cphase(1:3) = [4,4,4]; %milisecond
    state.yphys.acq.cwidth = 4;
    state.yphys.acq.camplitude = 1000;
else
    cphase = [state.yphys.acq.cwidth, state.yphys.acq.cwidth, state.yphys.acq.cwidth];
end

if ~isfield(state.yphys.acq, 'vperiod')
   state.yphys.acq.vperiod = 0.3;
end
if ~isfield(state.yphys.acq, 'cperiod')
	state.yphys.acq.cperiod = 10;
else
    ctimerperiod = state.yphys.acq.cperiod;
end
state.yphys.acq.data = zeros(sum(vphase(:))*state.yphys.acq.inputRate/1000, 2);
yphys_updateGUI;

axes(handles.trace);
gh.yphys.patchPlot = plot(zeros(32,1));
%yphys_setup;

% --- Outputs from this function are returned to the command line.
function varargout = yphys_scope_OutputFcn(hObject, eventdata, handles)
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
yphys_patch;

% --- Executes on button press in nowincell.
function nowincell_Callback(hObject, eventdata, handles)
% hObject    handle to nowincell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yphys_nowincell;

% --- Executes during object creation, after setting all properties.
function rin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rin_Callback(hObject, eventdata, handles)
% hObject    handle to rin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rin as text
%        str2double(get(hObject,'String')) returns contents of rin as a double


% --- Executes during object creation, after setting all properties.
function rs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rs_Callback(hObject, eventdata, handles)
% hObject    handle to rs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rs as text
%        str2double(get(hObject,'String')) returns contents of rs as a double


% --- Executes during object creation, after setting all properties.
function cm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function cm_Callback(hObject, eventdata, handles)
% hObject    handle to cm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cm as text
%        str2double(get(hObject,'String')) returns contents of cm as a double


% --- Executes during object creation, after setting all properties.
function vwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function vwidth_Callback(hObject, eventdata, handles)
% hObject    handle to vwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vwidth as text
%        str2double(get(hObject,'String')) returns contents of vwidth as a double

global state;
state.yphys.acq.vwidth = str2num(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function vamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function vamp_Callback(hObject, eventdata, handles)
% hObject    handle to vamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vamp as text
%        str2double(get(hObject,'String')) returns contents of vamp as a double
global state;
state.yphys.acq.vamplitude = str2num(get(hObject, 'String'));

% --- Executes during object creation, after setting all properties.
function cwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function cwidth_Callback(hObject, eventdata, handles)
% hObject    handle to cwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cwidth as text
%        str2double(get(hObject,'String')) returns contents of cwidth as a double

global state;
state.yphys.acq.cwidth = str2num(get(hObject, 'String'));

% --- Executes during object creation, after setting all properties.
function camp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function camp_Callback(hObject, eventdata, handles)
% hObject    handle to camp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of camp as text
%        str2double(get(hObject,'String')) returns contents of camp as a double

global state;
state.yphys.acq.camplitude = str2num(get(hObject, 'String'));

% --- Executes during object creation, after setting all properties.
function vperiod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vperiod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function vperiod_Callback(hObject, eventdata, handles)
% hObject    handle to vperiod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vperiod as text
%        str2double(get(hObject,'String')) returns contents of vperiod as a double

global state;
state.yphys.acq.vperiod = str2num(get(hObject, 'String'));

% --- Executes during object creation, after setting all properties.
function cperiod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cperiod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function cperiod_Callback(hObject, eventdata, handles)
% hObject    handle to cperiod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cperiod as text
%        str2double(get(hObject,'String')) returns contents of cperiod as a double


global state;
state.yphys.acq.cperiod = str2num(get(hObject, 'String'));


% --- Executes on button press in vclamp.
function vclamp_Callback(hObject, eventdata, handles)
% hObject    handle to vclamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vclamp
global state;
global gh;
vclamp = get(gh.yphys.scope.vclamp, 'Value');
state.yphys.acq.cclamp = ~vclamp;
putvalue(state.yphys.init.vclampLine, vclamp);
if strcmp(get(gh.yphys.scope.start, 'String'), 'STOP')
    pause(0.1);
    yphys_patch;
    pause(0.1);
    yphys_patch;
end


% --- Executes on selection change in gain.
function gain_Callback(hObject, eventdata, handles)
% hObject    handle to gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns gain contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gain

global gh;
if strcmp(get(gh.yphys.scope.start, 'String'), 'STOP')
    pause(0.1);
    yphys_patch;
    pause(0.1);
    yphys_patch;
end

% --- Executes during object creation, after setting all properties.
function gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in AutoS.
function AutoS_Callback(hObject, eventdata, handles)
% hObject    handle to AutoS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoS

global gh
value = get(hObject, 'Value');
if value
    set(gh.yphys.scope.trace, 'YLimMode', 'Auto')
else
    set(gh.yphys.scope.trace, 'YLimMode', 'Manual')
end









% --- Executes on button press in fft.
function fft_Callback(hObject, eventdata, handles)
% hObject    handle to fft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fft


