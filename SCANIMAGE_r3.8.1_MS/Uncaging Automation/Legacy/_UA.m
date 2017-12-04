function varargout = UA(varargin)
% UA MATLAB code for UA.fig
%      UA, by itself, creates a new UA or raises the existing
%      singleton*.
%
%      H = UA returns the handle to a new UA or the handle to
%      the existing singleton*.
%
%      UA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UA.M with the given input arguments.
%
%      UA('Property','Value',...) creates a new UA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UA

% Last Modified by GUIDE v2.5 24-Apr-2015 15:05:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @UA_OpeningFcn, ...
    'gui_OutputFcn',  @UA_OutputFcn, ...
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


% --- Executes just before UA is made visible.
function UA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UA (see VARARGIN)

% Choose default command line output for UA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global ua
ua.handles=handles;
set(findall(handles.uipanel2, '-property', 'enable'), 'enable', 'off');
updateUAgui;

% UIWAIT makes UA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
defineROICallback;

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'String'),'Start')
    startButtonCallback;
else
    UA_Abort;
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua gh
ua.positions=struct; %clear ua positions structure
ua.roiTotal=0;
% clear all ROIs in image
for i=find(ishandle(gh.yphys.figure.yphys_roi))
    a=findobj('Tag', num2str(i));
    delete(a);
end
updateUAgui;



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.secondaryFreq=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.params.secondaryFreq));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.secondaryTime=str2double(get(hObject,'String'));
disp(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.params.secondaryTime));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.primaryTime=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.params.primaryTime));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.primaryFreq=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.params.primaryFreq));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GoToCallback;


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global ua
if numel(eventdata.Indices)>0 %check if something is selected
    selectedCell=eventdata.Indices;
    a=get(ua.handles.uitable1,'data');
    ua.SelectedSpine=a(selectedCell(1),1);
    ua.SelectedPosition=a(selectedCell(1),2);
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deleteROICallback;
updateUAgui;


% --- Executes on button press in drift_corr_button.
function drift_corr_button_Callback(hObject, eventdata, handles)
% hObject    handle to drift_corr_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UA_DriftCorrect;


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateUAposition;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveInifileAFUA;


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SaveIni_Callback(hObject, eventdata, handles)
% hObject    handle to SaveIni (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveInifileAFUA;


% --------------------------------------------------------------------
function LoadIni_Callback(hObject, eventdata, handles)
% hObject    handle to LoadIni (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadInifileAFUA;
reloadUAAF;


% --- Executes on button press in pageacq_checkbox.
function pageacq_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to pageacq_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua gh state

value=get(hObject,'Value');
ua.params.pageacq=value;
state.internal.usePage=value;
state.spc.acq.spc_average = 1;
% set value to FLIMimage window
if ishandle(gh.spc.FLIMimage.pageScan)
    set(gh.spc.FLIMimage.pageScan,'Value',value);
    if value
        set(gh.spc.FLIMimage.frameScan,'Value',0);
    end
end

% disable timers if page acq mode is being used
if value
    set(findall(handles.uipanel1, '-property', 'enable'), 'enable', 'off');
    %     set(findall(handles.uipanel2, '-property', 'enable'), 'enable', 'off');
else
    set(findall(handles.uipanel1, '-property', 'enable'), 'enable', 'on');
    %     set(findall(handles.uipanel2, '-property', 'enable'), 'enable', 'on');
end
% Hint: get(hObject,'Value') returns toggle state of pageacq_checkbox


% --- Executes during object creation, after setting all properties.
function pageacq_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pageacq_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
if isfield(ua.params,'pageacq')
    set(hObject,'Value',ua.params.pageacq);
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state ua
a=which('loadInifileAFUA'); %use same directory as ini file
[filepath,~,~]=fileparts(a);
fname='UAROIs';
if isfield(ua.drift,'T'); %check if drift database exists
    driftlist=ua.drift.T;
else
    driftlist=[];
end
positions=ua.positions;
roitotal=ua.roiTotal;
fpath=[filepath,'\',fname];
save(fpath,'driftlist','positions','roitotal');
state.hSI.roiSaveAs();



% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state ua
state.hSI.roiLoad();
fpath=which('UAROIs.mat'); %use same directory as ini file
load(fpath)
if ~isempty(driftlist)
    ua.drift.T=driftlist;
end
ua.positions=positions;
ua.roiTotal=roitotal;
updateUAgui;



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
global ua state
ua.params.zRoof=state.motor.hMotor.positionAbsolute(3);
set(ua.handles.edit6,'String',num2str(ua.params.zRoof));


% --- Executes on button press in fovGroup_pushbutton.
function fovGroup_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fovGroup_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
groupRoisByFOV;
