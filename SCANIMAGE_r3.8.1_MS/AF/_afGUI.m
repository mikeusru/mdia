function varargout = afGUI(varargin)
% AFGUI MATLAB code for afGUI.fig
%      AFGUI, by itself, creates a new AFGUI or raises the existing
%      singleton*.
%
%      H = AFGUI returns the handle to a new AFGUI or the handle to
%      the existing singleton*.
%
%      AFGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AFGUI.M with the given input arguments.
%
%      AFGUI('Property','Value',...) creates a new AFGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before afGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to afGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help afGUI

% Last Modified by GUIDE v2.5 24-Apr-2015 16:50:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @afGUI_OpeningFcn, ...
    'gui_OutputFcn',  @afGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before afGUI is made visible.
function afGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to afGUI (see VARARGIN)

% Choose default command line output for afGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global af
af.handles_afGUI=handles;
set(handles.uipanel5,'SelectedObject',handles.(af.params.mode));

% UIWAIT makes afGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = afGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setspine.
function setspine_Callback(hObject, eventdata, handles)
% hObject    handle to setspine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% declare/access global state and af (autofocus) variable
global af
af.statusGUI='Click on spine of interest';
set(handles.statustext,'String',af.statusGUI);
set_spines(); % run function to set spine
af.statusGUI='-';
set(handles.statustext,'String',af.statusGUI);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Select Autofocus Algorithm dropdown

% --- Executes on selection change in aa_select.
function aa_select_Callback(hObject, eventdata, handles)
% hObject    handle to aa_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% globally declare autofocus structure
global af
% check if an algorithm has been selected
af.algorithm.value=val;
if strcmp(str{val},'Select Autofocus Algorithm')==0
    af.algorithm.selected=1;
    % Set algorithm to global af structure.
    af.algorithm.operator=str{val};
else af.algorithm.selected=0;
end



% Hints: contents = cellstr(get(hObject,'String')) returns aa_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from aa_select


% --- Executes during object creation, after setting all properties.
function aa_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aa_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.algorithm.value);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zrange_Callback(hObject, eventdata, handles)
% hObject    handle to zrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=str2double(get(hObject,'String'));
global af
% add z range to global autofocus parameters
af.params.zrange=str;
if isfield(af.params,'zstep')
    if isa(af.params.zstep,'double')==1 && isa(af.params.zrange,'double')==1 ...
            && isnan(af.params.zstep)==0 && isnan(af.params.zrange)==0
        af.params.scancount=ceil(af.params.zrange/af.params.zstep+1);
        set(handles.scancount, 'String', af.params.scancount);
    else set(handles.scancount, 'String', 'Z step and range must be numbers');
    end
end
% Hints: get(hObject,'String') returns contents of zrange as text
%        str2double(get(hObject,'String')) returns contents of zrange as a double


% --- Executes during object creation, after setting all properties.
function zrange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',num2str(af.params.zrange));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zstep_Callback(hObject, eventdata, handles)
% hObject    handle to zstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=str2double(get(hObject,'String'));
global af
% add z step to global autofocus parameters
af.params.zstep=str;
if isfield(af.params,'zrange')
    if isa(af.params.zstep,'double')==1 && isa(af.params.zrange,'double')==1 ...
            && isnan(af.params.zstep)==0 && isnan(af.params.zrange)==0
        af.params.scancount=ceil(af.params.zrange/af.params.zstep+1);
        set(handles.scancount, 'String', af.params.scancount);
    else set(handles.scancount, 'String', 'Z step and range must be numbers');
    end
end

% Hints: get(hObject,'String') returns contents of zstep as text
%        str2double(get(hObject,'String')) returns contents of zstep as a double


% --- Executes during object creation, after setting all properties.
function zstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',num2str(af.params.zstep));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function run_frequency_Callback(hObject, eventdata, handles)
% hObject    handle to run_frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of run_frequency as text
%        str2double(get(hObject,'String')) returns contents of run_frequency as a double
str=str2double(get(hObject,'String'));
global af
% add z step to global autofocus parameters
af.params.frequency=str;


% --- Executes during object creation, after setting all properties.
function run_frequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to run_frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',num2str(af.params.frequency));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in test_AF.
function test_AF_Callback(hObject, eventdata, handles)
% hObject    handle to test_AF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Move stage, take images, and do autofocus on them.
execute_AF_Callback;


% --- Executes during object creation, after setting all properties.
function scancount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scancount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
if isfield(af.params, 'scancount')
    set(hObject,'String', num2str(af.params.scancount));
else set(hObject,'String', '-');
end



% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.params.isAFon=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on key press with focus on checkbox1 and none of its controls.
function checkbox1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function checkbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.params.isAFon);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over scancount.
function scancount_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to scancount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in af_acquired_checkbox.
function af_acquired_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to af_acquired_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.params.useAcqForAF=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of af_acquired_checkbox


% --- Executes on selection change in channel_select.
function channel_select_Callback(hObject, eventdata, handles)
% hObject    handle to channel_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.params.channel=get(hObject,'Value');
% Hints: contents = cellstr(get(hObject,'String')) returns channel_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_select


% --- Executes during object creation, after setting all properties.
function channel_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global state
try % try to set channel picket to proper array count. if state variable isn't open yet, just set it to two as a default.
    channelarray=sprintf('Channel %d|',1:state.init.maximumNumberOfInputChannels);
catch
    channelarray=sprintf('Channel %d|',1:2);
end
channelarray(end)=[];
set(hObject,'String',channelarray);
try
    set(hObject,'Value',af.params.channel);
end
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.statusGUI='Click on spine of interest';
set(handles.statustext,'String',af.statusGUI);
set_spines(true); % run function to set spines with multiple positions enabled
af.statusGUI='-';
set(handles.statustext,'String',af.statusGUI);


% --- Executes during object creation, after setting all properties.
function statustext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statustext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
if isfield(af,'statusGUI')
    set(hObject,'String',af.statusGUI);
else set(hObject,'String','-');
end


% --- Executes on button press in dispAFimages_checkbox.
function dispAFimages_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to dispAFimages_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.params.displaytoggle=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of dispAFimages_checkbox


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.drift.on=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in tuneThreshPushbutton.
function tuneThreshPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to tuneThreshPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
find_dendrites_slider_GUI


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.statusGUI='Click on reproducible position';
afStatus(af.statusGUI);
tuneDist(); % run function to set spine
af.statusGUI='-';
afStatus(af.statusGUI);


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',af.drift.scale);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
driftCorrect('click');


% --- Executes on button press in loopmode.
function loopmode_Callback(hObject, eventdata, handles)
% hObject    handle to loopmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loopmode


% --- Executes on button press in cyclemode.
function cyclemode_Callback(hObject, eventdata, handles)
% hObject    handle to cyclemode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cyclemode


% --- Executes on button press in uamode.
function uamode_Callback(hObject, eventdata, handles)
% hObject    handle to uamode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of uamode


% --- Executes during object creation, after setting all properties.
function loopmode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loopmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function cyclemode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cyclemode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function uamode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uamode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in uipanel5.
function uipanel5_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel5 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global af
tag=get(hObject,'Tag');
af.params.mode=tag;
    


% --- Executes during object creation, after setting all properties.
function checkbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.drift.on);


% --- Executes during object creation, after setting all properties.
function af_acquired_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to af_acquired_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.params.useAcqForAF);


% --- Executes during object creation, after setting all properties.
function dispAFimages_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispAFimages_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.params.displaytoggle);


% --- Executes during object creation, after setting all properties.
function pushbutton8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uipanel5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
