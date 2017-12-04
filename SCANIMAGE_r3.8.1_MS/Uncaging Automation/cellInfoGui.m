function varargout = cellInfoGui(varargin)
% CELLINFOGUI MATLAB code for cellInfoGui.fig
%      CELLINFOGUI, by itself, creates a new CELLINFOGUI or raises the existing
%      singleton*.
%
%      H = CELLINFOGUI returns the handle to a new CELLINFOGUI or the handle to
%      the existing singleton*.
%
%      CELLINFOGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CELLINFOGUI.M with the given input arguments.
%
%      CELLINFOGUI('Property','Value',...) creates a new CELLINFOGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cellInfoGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cellInfoGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cellInfoGui

% Last Modified by GUIDE v2.5 27-Jul-2015 13:11:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cellInfoGui_OpeningFcn, ...
                   'gui_OutputFcn',  @cellInfoGui_OutputFcn, ...
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


% --- Executes just before cellInfoGui is made visible.
function cellInfoGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cellInfoGui (see VARARGIN)

% Choose default command line output for cellInfoGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global dia
dia.handles.cellInfo=handles;
fpath=which('cellInfoGuiValues.mat');
load(fpath);
dia.acq.cellInfo=saveInfo;

% UIWAIT makes cellInfoGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cellInfoGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function addGenoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to addGenoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
a=get(hObject,'String');
dia.acq.cellInfo.genotypeList=[dia.acq.cellInfo.genotypeList;a];
set(dia.handles.cellInfo.genoPopupmenu,'String',dia.acq.cellInfo.genotypeList);
set(hObject,'String','');
fpath=which('cellInfoGuiValues.mat');
saveInfo=dia.acq.cellInfo;
save(fpath,'saveInfo');


% Hints: get(hObject,'String') returns contents of addGenoEdit as text
%        str2double(get(hObject,'String')) returns contents of addGenoEdit as a double


% --- Executes during object creation, after setting all properties.
function addGenoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addGenoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in genoPopupmenu.
function genoPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to genoPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
a=get(hObject,'String');
dia.acq.cellInfo.genotype=a{get(hObject,'Value')};
% Hints: contents = cellstr(get(hObject,'String')) returns genoPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from genoPopupmenu


% --- Executes during object creation, after setting all properties.
function genoPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to genoPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
ind=find(strcmp(dia.acq.cellInfo.genotypeList,dia.acq.cellInfo.genotype));
set(hObject,'String',dia.acq.cellInfo.genotypeList,'Value',ind);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.cellInfo.div=str2double(get(hObject,'String'));
fpath=which('cellInfoGuiValues.mat');
saveInfo=dia.acq.cellInfo;
save(fpath,'saveInfo');
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.cellInfo.div));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function addConditionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to addConditionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
a=get(hObject,'String');
dia.acq.cellInfo.conditionList=[dia.acq.cellInfo.conditionList;a];
set(dia.handles.cellInfo.conditionPopupmenu,'String',dia.acq.cellInfo.conditionList);
set(hObject,'String','');
fpath=which('cellInfoGuiValues.mat');
saveInfo=dia.acq.cellInfo;
save(fpath,'saveInfo');
% Hints: get(hObject,'String') returns contents of addConditionEdit as text
%        str2double(get(hObject,'String')) returns contents of addConditionEdit as a double


% --- Executes during object creation, after setting all properties.
function addConditionEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addConditionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in conditionPopupmenu.
function conditionPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to conditionPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
a=get(hObject,'String');
dia.acq.cellInfo.condition=a{get(hObject,'Value')};
% Hints: contents = cellstr(get(hObject,'String')) returns conditionPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from conditionPopupmenu


% --- Executes during object creation, after setting all properties.
function conditionPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to conditionPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
ind=find(strcmp(dia.acq.cellInfo.conditionList,dia.acq.cellInfo.condition));
set(hObject,'String',dia.acq.cellInfo.conditionList,'Value',ind);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function notesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to notesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.cellInfo.notes=get(hObject,'String');
fpath=which('cellInfoGuiValues.mat');
saveInfo=dia.acq.cellInfo;
save(fpath,'saveInfo');

% Hints: get(hObject,'String') returns contents of notesEdit as text
%        str2double(get(hObject,'String')) returns contents of notesEdit as a double


% --- Executes during object creation, after setting all properties.
function notesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',dia.acq.cellInfo.notes);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function transDateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to transDateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia

dia.acq.cellInfo.transDate=get(hObject,'String');
fpath=which('cellInfoGuiValues.mat');
saveInfo=dia.acq.cellInfo;
save(fpath,'saveInfo');

% Hints: get(hObject,'String') returns contents of transDateEdit as text
%        str2double(get(hObject,'String')) returns contents of transDateEdit as a double


% --- Executes during object creation, after setting all properties.
function transDateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transDateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',dia.acq.cellInfo.transDate);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on notesEdit and none of its controls.
function notesEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to notesEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in sendEmailCheckbox.
function sendEmailCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to sendEmailCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia

dia.guiStuff.emailWhenDone=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of sendEmailCheckbox



function emailEdit_Callback(hObject, eventdata, handles)
% hObject    handle to emailEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.cellInfo.email=get(hObject,'String');
% Hints: get(hObject,'String') returns contents of emailEdit as text
%        str2double(get(hObject,'String')) returns contents of emailEdit as a double


% --- Executes during object creation, after setting all properties.
function emailEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emailEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia

if isfield(dia.acq.cellInfo,'email')
   set(hObject,'String',dia.acq.cellInfo);
end

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function sendEmailCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sendEmailCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia

if ~isfield(dia.guiStuff,'emailWhenDone')
%     dia.acq.cellInfo.email=get(dia.handles.cellInfo.emailEdit,'String');
% else
    dia.guiStuff.emailWhenDone=0;
end

set(hObject,'Value',dia.guiStuff.emailWhenDone);
