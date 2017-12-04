function varargout = timelineSetupGui(varargin)
% TIMELINESETUPGUI MATLAB code for timelineSetupGui.fig
%      TIMELINESETUPGUI, by itself, creates a new TIMELINESETUPGUI or raises the existing
%      singleton*.
%
%      H = TIMELINESETUPGUI returns the handle to a new TIMELINESETUPGUI or the handle to
%      the existing singleton*.
%
%      TIMELINESETUPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIMELINESETUPGUI.M with the given input arguments.
%
%      TIMELINESETUPGUI('Property','Value',...) creates a new TIMELINESETUPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before timelineSetupGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to timelineSetupGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help timelineSetupGui

% Last Modified by GUIDE v2.5 14-Jul-2017 13:27:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @timelineSetupGui_OpeningFcn, ...
                   'gui_OutputFcn',  @timelineSetupGui_OutputFcn, ...
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


% --- Executes just before timelineSetupGui is made visible.
function timelineSetupGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to timelineSetupGui (see VARARGIN)

% Choose default command line output for timelineSetupGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%add context menu
c = uicontextmenu('Parent',handles.figure1);
set(handles.timelineUIT,'UIContextMenu', c);
m1 = uimenu(c,'Label','Insert Step','Callback',@insertTimelineStepCallback);

global dia
dia.handles.timelineGui=handles;
resetTimelineGuiBoxes(handles);

% UIWAIT makes timelineSetupGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = timelineSetupGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function durationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to durationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia

% Hints: get(hObject,'String') returns contents of durationEdit as text
%        str2double(get(hObject,'String')) returns contents of durationEdit as a double


% --- Executes during object creation, after setting all properties.
function durationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to durationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function periodEdit_Callback(hObject, eventdata, handles)
% hObject    handle to periodEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of periodEdit as text
%        str2double(get(hObject,'String')) returns contents of periodEdit as a double


% --- Executes during object creation, after setting all properties.
function periodEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to periodEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addStepPushbutton.
function addStepPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to addStepPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hPos.addTimelineStep(handles);
%clear all values in gui
resetTimelineGuiBoxes(handles);


function stepNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stepNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepNameEdit as text
%        str2double(get(hObject,'String')) returns contents of stepNameEdit as a double


% --- Executes during object creation, after setting all properties.
function stepNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exclusiveCB.
function exclusiveCB_Callback(hObject, eventdata, handles)
% hObject    handle to exclusiveCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of exclusiveCB

function resetTimelineGuiBoxes(handles)
global dia
set(handles.stepNameEdit,'String','');
set(handles.durationEdit,'String','');
set(handles.periodEdit,'String','');
set(handles.exclusiveCB,'Value',0);
set(handles.pageAcqCB,'Value',0);
dia.hPos.makeTimelineTableGui(handles);


% --- Executes on button press in removeStepPB.
function removeStepPB_Callback(hObject, eventdata, handles)
% hObject    handle to removeStepPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
s=get(handles.timelineUIT,'UserData');
dia.hPos.timelineSetup(s(:,1))=[];
dia.hPos.makeTimelineTableGui(handles);

% --- Executes when selected cell(s) is changed in timelineUIT.
function timelineUIT_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to timelineUIT (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'UserData',eventdata.Indices)




function staggerED_Callback(hObject, eventdata, handles)
% hObject    handle to staggerED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hPos.staggerTime=str2double(get(hObject,'String'));
dia.hPos.drawTimeline(handles);
% Hints: get(hObject,'String') returns contents of staggerED as text
%        str2double(get(hObject,'String')) returns contents of staggerED as a double


% --- Executes during object creation, after setting all properties.
function staggerED_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staggerED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.hPos.staggerTime));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uncageDurationED_Callback(hObject, eventdata, handles)
% hObject    handle to uncageDurationED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.uncagingTimeEst=str2double(get(hObject,'String'));
dia.hPos.drawTimeline(handles);
% Hints: get(hObject,'String') returns contents of uncageDurationED as text
%        str2double(get(hObject,'String')) returns contents of uncageDurationED as a double


% --- Executes during object creation, after setting all properties.
function uncageDurationED_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uncageDurationED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.uncagingTimeEst));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in ActionUipanel1.
function ActionUipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ActionUipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(eventdata.NewValue,'Tag'),'imagingRB')
    enableOrDisableHandles(0,handles);
else
    enableOrDisableHandles(1,handles);
end


function enableOrDisableHandles(uncaging,handles)

if uncaging
    enCells={'off','off','off','on'};
else
    enCells={'on','on','on','off'};
end
set(handles.durationEdit,'Enable',enCells{1});
set(handles.periodEdit,'Enable',enCells{2});
set(handles.exclusiveCB,'Enable',enCells{3});
set(handles.pageAcqCB,'Enable',enCells{4});




% --- Executes during object creation, after setting all properties.
function uncagingRB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uncagingRB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pageAcqCB.
function pageAcqCB_Callback(hObject, eventdata, handles)
% hObject    handle to pageAcqCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pageAcqCB


% --------------------------------------------------------------------
function timelineUIT_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to timelineUIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% h=hObject;


% --- Executes on button press in collectFOVatEndCB.
function collectFOVatEndCB_Callback(hObject, eventdata, handles)
% hObject    handle to collectFOVatEndCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hPos.collectFOVstackWhenDone = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function collectFOVatEndCB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to collectFOVatEndCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'Value',dia.hPos.collectFOVstackWhenDone);
