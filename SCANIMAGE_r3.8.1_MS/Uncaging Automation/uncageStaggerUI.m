function varargout = uncageStaggerUI(varargin)
% UNCAGESTAGGERUI MATLAB code for uncageStaggerUI.fig
%      UNCAGESTAGGERUI, by itself, creates a new UNCAGESTAGGERUI or raises the existing
%      singleton*.
%
%      H = UNCAGESTAGGERUI returns the handle to a new UNCAGESTAGGERUI or the handle to
%      the existing singleton*.
%
%      UNCAGESTAGGERUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNCAGESTAGGERUI.M with the given input arguments.
%
%      UNCAGESTAGGERUI('Property','Value',...) creates a new UNCAGESTAGGERUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uncageStaggerUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uncageStaggerUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help uncageStaggerUI

% Last Modified by GUIDE v2.5 27-Oct-2015 16:06:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uncageStaggerUI_OpeningFcn, ...
                   'gui_OutputFcn',  @uncageStaggerUI_OutputFcn, ...
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


% --- Executes just before uncageStaggerUI is made visible.
function uncageStaggerUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to uncageStaggerUI (see VARARGIN)

% Choose default command line output for uncageStaggerUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global dia
dia.handles.staggerUA=handles;

% UIWAIT makes uncageStaggerUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = uncageStaggerUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in staggerUncagingCheckbox.
function staggerUncagingCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to staggerUncagingCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia 
dia.init.staggerOn=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of staggerUncagingCheckbox



function uncageTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to uncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.uncagingTimeEst=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of uncageTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of uncageTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function uncageTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia

set(hObject,'String',num2str(dia.acq.uncagingTimeEst));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function imageAllPositionsTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to imageAllPositionsTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.imagingTimeEst=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of imageAllPositionsTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of imageAllPositionsTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function imageAllPositionsTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageAllPositionsTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.imagingTimeEst));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function postUncageTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to postUncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.postUncageExclusiveTime=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of postUncageTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of postUncageTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function postUncageTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to postUncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.postUncageExclusiveTime));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function postUncagePeriodEdit_Callback(hObject, eventdata, handles)
% hObject    handle to postUncagePeriodEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.postUncageExclusivePeriod=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of postUncagePeriodEdit as text
%        str2double(get(hObject,'String')) returns contents of postUncagePeriodEdit as a double


% --- Executes during object creation, after setting all properties.
function postUncagePeriodEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to postUncagePeriodEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.postUncageExclusivePeriod));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function preUncageTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to preUncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.preUncageExclusiveTime=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of preUncageTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of preUncageTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function preUncageTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preUncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.preUncageExclusiveTime));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function preUncageFrequencyEdit_Callback(hObject, eventdata, handles)
% hObject    handle to preUncageFrequencyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.preUncageExclusivePeriod=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of preUncageFrequencyEdit as text
%        str2double(get(hObject,'String')) returns contents of preUncageFrequencyEdit as a double


% --- Executes during object creation, after setting all properties.
function preUncageFrequencyEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preUncageFrequencyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.preUncageExclusivePeriod));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function staggerUncagingCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staggerUncagingCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'Value',dia.init.staggerOn);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
createExperimentChart;



function initialImagingTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to initialImagingTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.initialImagingTime=str2double(get(hObject,'String'));

% Hints: get(hObject,'String') returns contents of initialImagingTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of initialImagingTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function initialImagingTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initialImagingTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.initialImagingTime));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function initialImagingPeriodEdit_Callback(hObject, eventdata, handles)
% hObject    handle to initialImagingPeriodEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.initialImagingPeriod=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of initialImagingPeriodEdit as text
%        str2double(get(hObject,'String')) returns contents of initialImagingPeriodEdit as a double


% --- Executes during object creation, after setting all properties.
function initialImagingPeriodEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initialImagingPeriodEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.initialImagingPeriod));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
