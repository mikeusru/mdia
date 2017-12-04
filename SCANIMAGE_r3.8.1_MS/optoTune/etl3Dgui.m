function varargout = etl3Dgui(varargin)
% ETL3DGUI MATLAB code for etl3Dgui.fig
%      ETL3DGUI, by itself, creates a new ETL3DGUI or raises the existing
%      singleton*.
%
%      H = ETL3DGUI returns the handle to a new ETL3DGUI or the handle to
%      the existing singleton*.
%
%      ETL3DGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETL3DGUI.M with the given input arguments.
%
%      ETL3DGUI('Property','Value',...) creates a new ETL3DGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etl3Dgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etl3Dgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etl3Dgui

% Last Modified by GUIDE v2.5 25-Feb-2016 15:43:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etl3Dgui_OpeningFcn, ...
                   'gui_OutputFcn',  @etl3Dgui_OutputFcn, ...
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


% --- Executes just before etl3Dgui is made visible.
function etl3Dgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etl3Dgui (see VARARGIN)

% Choose default command line output for etl3Dgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global dia
dia.handles.etl3Dgui=handles;
switch dia.etl.acq.voltCalcMode
    case 1
        set(dia.handles.etl3Dgui.voltToUmCalcUipanel,'SelectedObject',dia.handles.etl3Dgui.constant);
    case 2
        set(dia.handles.etl3Dgui.voltToUmCalcUipanel,'SelectedObject',dia.handles.etl3Dgui.poly);
end

preview3Dimage;
% UIWAIT makes etl3Dgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = etl3Dgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function fovSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fovSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia

dia.etl.acq.fovSizeUm = str2double(get(hObject,'String'));
preview3Dimage;
setScanProps(hObject);

% Hints: get(hObject,'String') returns contents of fovSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of fovSizeEdit as a double


% --- Executes during object creation, after setting all properties.
function fovSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fovSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
if ~isfield(dia.etl.acq,'fovSizeUm')
    dia.etl.acq.fovSizeUm=240;
end
set(hObject,'String',num2str(dia.etl.acq.fovSizeUm));
    
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minVoltageEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minVoltageEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
zBase=str2double(get(hObject,'String'));
dia.etl.acq.voltageMin=zBase;
set(dia.handles.etl3Dgui.baseVoltSlider,'Value',zBase);
preview3Dimage;
setScanProps(hObject);
% Hints: get(hObject,'String') returns contents of minVoltageEdit as text
%        str2double(get(hObject,'String')) returns contents of minVoltageEdit as a double


% --- Executes during object creation, after setting all properties.
function minVoltageEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minVoltageEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
if ~isfield(dia,'etl') || ~isfield(dia.etl, 'acq') || ~isfield(dia.etl.acq,'voltageMin')
dia.etl.acq.voltageMin=0;
end 
set(hObject,'String',num2str(dia.etl.acq.voltageMin));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function voltageRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to voltageRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
vRange=str2double(get(hObject,'String'));
dia.etl.acq.voltageRange=vRange;
set(dia.handles.etl3Dgui.voltRangeSlider,'Value',vRange);
preview3Dimage;
setScanProps(hObject);

% Hints: get(hObject,'String') returns contents of voltageRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of voltageRangeEdit as a double


% --- Executes during object creation, after setting all properties.
function voltageRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltageRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
if ~isfield(dia,'etl') || ~isfield(dia.etl, 'acq') || ~isfield(dia.etl.acq,'voltageRange')
dia.etl.acq.voltageRange=0;
end 

set(hObject,'String',num2str(dia.etl.acq.voltageRange));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function scanPlaneAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanPlaneAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate scanPlaneAxes



function voltToUmConstantEdit_Callback(hObject, eventdata, handles)
% hObject    handle to voltToUmConstantEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.etl.acq.voltToUm=str2double(get(hObject,'String'));
preview3Dimage;
setScanProps(hObject);

% Hints: get(hObject,'String') returns contents of voltToUmConstantEdit as text
%        str2double(get(hObject,'String')) returns contents of voltToUmConstantEdit as a double


% --- Executes during object creation, after setting all properties.
function voltToUmConstantEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltToUmConstantEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.etl.acq.voltToUm));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function voltRangeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to voltRangeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
vRange=get(hObject,'Value');
dia.etl.acq.voltageRange=vRange;
preview3Dimage;
set(dia.handles.etl3Dgui.voltageRangeEdit,'String',num2str(vRange));
setScanProps(hObject);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function voltRangeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltRangeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'Value',dia.etl.acq.voltageRange);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function baseVoltSlider_Callback(hObject, eventdata, handles)
% hObject    handle to baseVoltSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
vBase=get(hObject,'Value');
dia.etl.acq.voltageMin=vBase;
preview3Dimage;
set(dia.handles.etl3Dgui.minVoltageEdit,'String',num2str(vBase));
setScanProps(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function baseVoltSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseVoltSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'Value',dia.etl.acq.voltageMin,'Max',dia.init.etl.voltageRange);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in useETLcb.
function useETLcb_Callback(hObject, eventdata, handles)
% hObject    handle to useETLcb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useETLcb


% --- Executes on button press in setMotorEtlLimitpb.
function setMotorEtlLimitpb_Callback(hObject, eventdata, handles)
% hObject    handle to setMotorEtlLimitpb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etlZlimed_Callback(hObject, eventdata, handles)
% hObject    handle to etlZlimed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etlZlimed as text
%        str2double(get(hObject,'String')) returns contents of etlZlimed as a double


% --- Executes during object creation, after setting all properties.
function etlZlimed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etlZlimed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etlRangeed_Callback(hObject, eventdata, handles)
% hObject    handle to etlRangeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etlRangeed as text
%        str2double(get(hObject,'String')) returns contents of etlRangeed as a double


% --- Executes during object creation, after setting all properties.
function etlRangeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etlRangeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in voltToUmCalcUipanel.
function voltToUmCalcUipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in voltToUmCalcUipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global dia

switch get(eventdata.NewValue,'tag')
    case 'constant'
        dia.etl.acq.voltCalcMode=1;
    case 'poly'
        dia.etl.acq.voltCalcMode=2;
end


function polyValEdit_Callback(hObject, eventdata, handles)
% hObject    handle to polyValEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia

dia.etl.acq.umToVoltPoly=str2num(get(hObject,'String'))';
% Hints: get(hObject,'String') returns contents of polyValEdit as text
%        str2double(get(hObject,'String')) returns contents of polyValEdit as a double


% --- Executes during object creation, after setting all properties.
function polyValEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to polyValEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.etl.acq.umToVoltPoly,'%10.5e'));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function voltToUmCalcUipanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltToUmCalcUipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function loadStretchCMenu_Callback(hObject, eventdata, handles)
% hObject    handle to loadStretchCMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
[FileName,PathName,~] = uigetfile('Hfit.mat');
S=load([PathName,FileName]);
fname=fieldnames(S);
H=S.(fname{1});
mainDir=readMainDir;
save([mainDir,'/User Settings/','Hfit.mat'],'H');
dia.etl.acq.Htransform=H;


% --- Executes on button press in scanMirrorTransformCheckbox.
function scanMirrorTransformCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to scanMirrorTransformCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
if isfield(dia.etl.acq,'Htransform')
    dia.etl.acq.doMirrorTransform=get(hObject,'value');
else
    disp('Load Hfit File First');
    set(hObject,'value',0);
end
dia.etl.acq.doMirrorTransform = get(hObject,'value');
% Hint: get(hObject,'Value') returns toggle state of scanMirrorTransformCheckbox


% --- Executes during object creation, after setting all properties.
function scanMirrorTransformCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanMirrorTransformCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'value',dia.etl.acq.doMirrorTransform);

function loadCurrentHfit
global dia
mainDir=readMainDir;
if exist([mainDir,'/User Settings/','Hfit.mat'],'file')
    S=load([mainDir,'/User Settings/','Hfit.mat'],'H');
    fname=fieldnames(S);
    H=S.(fname{1});
    dia.etl.acq.Htransform=H;
end