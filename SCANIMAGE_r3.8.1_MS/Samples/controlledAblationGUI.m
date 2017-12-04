function varargout = controlledAblationGUI(varargin)
% CONTROLLEDABLATIONGUI MATLAB code for controlledAblationGUI.fig
%      CONTROLLEDABLATIONGUI, by itself, creates a new CONTROLLEDABLATIONGUI or raises the existing
%      singleton*.
%
%      H = CONTROLLEDABLATIONGUI returns the handle to a new CONTROLLEDABLATIONGUI or the handle to
%      the existing singleton*.
%
%      CONTROLLEDABLATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROLLEDABLATIONGUI.M with the given input arguments.
%
%      CONTROLLEDABLATIONGUI('Property','Value',...) creates a new CONTROLLEDABLATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before controlledAblationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to controlledAblationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help controlledAblationGUI

% Last Modified by GUIDE v2.5 17-May-2013 13:09:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @controlledAblationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @controlledAblationGUI_OutputFcn, ...
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


% --- Executes just before controlledAblationGUI is made visible.
function controlledAblationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to controlledAblationGUI (see VARARGIN)

% Choose default command line output for controlledAblationGUI
handles.output = hObject;

handles.pcAblationProps = most.gui.control.PropertyTable(handles.tblAblationProps);
handles.pcAblationProps.alphabetize = false;
set(handles.tblAblationProps,'UserData',handles.pcAblationProps); % xxx this does not get set automatically by Controller probably b/c there is no "propbinding"


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes controlledAblationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = controlledAblationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbAblate.
function pbAblate_Callback(hObject, eventdata, handles)
% hObject    handle to pbAblate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.start();

% --- Executes on selection change in pmAblationMode.
function pmAblationMode_Callback(hObject, eventdata, handles)
% hObject    handle to pmAblationMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmAblationMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmAblationMode
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function pmAblationMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmAblationMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in tblAblationProps.
function tblAblationProps_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tblAblationProps (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.hController.updateModel(hObject,eventdata,handles);


function etROINumber_Callback(hObject, eventdata, handles)
% hObject    handle to etROINumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etROINumber as text
%        str2double(get(hObject,'String')) returns contents of etROINumber as a double
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function etROINumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etROINumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbShowIntensity.
function pbShowIntensity_Callback(hObject, eventdata, handles)
% hObject    handle to pbShowIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.showInputData();

% --- Executes on button press in pbSaveIntensity.
function pbSaveIntensity_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.saveInputData();



function etROIZoom_Callback(hObject, eventdata, handles)
% hObject    handle to etROIZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etROIZoom as text
%        str2double(get(hObject,'String')) returns contents of etROIZoom as a double
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function etROIZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etROIZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etROINumLines_Callback(hObject, eventdata, handles)
% hObject    handle to etROINumLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etROINumLines as text
%        str2double(get(hObject,'String')) returns contents of etROINumLines as a double
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function etROINumLines_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etROINumLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
