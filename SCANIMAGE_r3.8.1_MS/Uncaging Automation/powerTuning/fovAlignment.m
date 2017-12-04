function varargout = fovAlignment(varargin)
% FOVALIGNMENT MATLAB code for fovAlignment.fig
%      FOVALIGNMENT, by itself, creates a new FOVALIGNMENT or raises the existing
%      singleton*.
%
%      H = FOVALIGNMENT returns the handle to a new FOVALIGNMENT or the handle to
%      the existing singleton*.
%
%      FOVALIGNMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FOVALIGNMENT.M with the given input arguments.
%
%      FOVALIGNMENT('Property','Value',...) creates a new FOVALIGNMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fovAlignment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fovAlignment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fovAlignment

% Last Modified by GUIDE v2.5 19-Nov-2015 10:29:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fovAlignment_OpeningFcn, ...
                   'gui_OutputFcn',  @fovAlignment_OutputFcn, ...
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


% --- Executes just before fovAlignment is made visible.
function fovAlignment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fovAlignment (see VARARGIN)

% Choose default command line output for fovAlignment
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global dia
dia.handles.fovAlignment=handles;

% UIWAIT makes fovAlignment wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fovAlignment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in enablePockelCellAlignmentCheckbox.
function enablePockelCellAlignmentCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to enablePockelCellAlignmentCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.init.doBeamPowerTransform=get(hObject,'Value');
setScanProps(hObject);
% Hint: get(hObject,'Value') returns toggle state of enablePockelCellAlignmentCheckbox


% --- Executes on button press in tuneCurrentBeamPushbutton.
function tuneCurrentBeamPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to tuneCurrentBeamPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tunePowerToBrightness;



% --- Executes during object creation, after setting all properties.
function lastTunedDateText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastTunedDateText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
if isfield(dia.init,'powerMod') && isfield(dia.init.powerMod,'tuneDate')
    set(hObject,'String',dia.init.powerMod.tuneDate);
else
    set(hObject,'String','Never');
end


% --- Executes during object creation, after setting all properties.
function enablePockelCellAlignmentCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enablePockelCellAlignmentCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'Value',dia.init.doBeamPowerTransform);



function maxPowerEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxPowerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.init.powerMod.maxPower=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of maxPowerEdit as text
%        str2double(get(hObject,'String')) returns contents of maxPowerEdit as a double


% --- Executes during object creation, after setting all properties.
function maxPowerEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxPowerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
if ~isfield(dia.init,'powerMod')
    dia.init.powerMod.maxPower=50;
end
set(hObject,'String',num2str(dia.init.powerMod.maxPower));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
