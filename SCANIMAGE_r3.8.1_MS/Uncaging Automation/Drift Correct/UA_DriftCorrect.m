function varargout = UA_DriftCorrect(varargin)
% UA_DRIFTCORRECT MATLAB code for UA_DriftCorrect.fig
%      UA_DRIFTCORRECT, by itself, creates a new UA_DRIFTCORRECT or raises the existing
%      singleton*.
%
%      H = UA_DRIFTCORRECT returns the handle to a new UA_DRIFTCORRECT or the handle to
%      the existing singleton*.
%
%      UA_DRIFTCORRECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UA_DRIFTCORRECT.M with the given input arguments.
%
%      UA_DRIFTCORRECT('Property','Value',...) creates a new UA_DRIFTCORRECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UA_DriftCorrect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UA_DriftCorrect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UA_DriftCorrect

% Last Modified by GUIDE v2.5 01-Sep-2015 11:52:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @UA_DriftCorrect_OpeningFcn, ...
    'gui_OutputFcn',  @UA_DriftCorrect_OutputFcn, ...
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


% --- Executes just before UA_DriftCorrect is made visible.
function UA_DriftCorrect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UA_DriftCorrect (see VARARGIN)

% Choose default command line output for UA_DriftCorrect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global ua
ua.drift.handles=handles;

updateUAgui;

% UIWAIT makes UA_DriftCorrect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UA_DriftCorrect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.drift.refChannel=get(hObject,'Value');
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global state ua
try % try to set channel picket to proper array count. if state variable isn't open yet, just set it to two as a default.
    channelarray=sprintf('Channel %d|',1:state.init.maximumNumberOfInputChannels);
catch
    channelarray=sprintf('Channel %d|',1:2);
end
channelarray(end)=[];
set(hObject,'String',channelarray);
try
    set(hObject,'Value',ua.drift.refChannel)
catch
    ua.drift.refchannel=1;
    set(hObject,'Value',ua.drift.refChannel)
end
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% UA_Drift_AddImage;
global dia ua
posID = ua.drift.selectedPosID;
dia.hPos.addRefImg(posID);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global ua dia
if numel(eventdata.Indices)>0 %check if something is selected
    sc=eventdata.Indices;
    sc=sc(1);
    a=get(ua.drift.handles.uitable1,'data');
    posID=a(sc,1);
    posID=cell2mat(posID);
    
    try
        I = dia.hPos.allPositionsDS.refImg{dia.hPos.allPositionsDS.posID==posID};
        I_zoomout = dia.hPos.allPositionsDS.refImgZoomOut{dia.hPos.allPositionsDS.posID==posID};
    catch
        I=ones(128);
        I_zoomout = ones(128);
    end
    
    %display image to axes
    axes(ua.drift.handles.axes1);
    colormap(gray);
    imagesc(I);
    axis off
    
    %% set 2nd image to axes
    axes(ua.drift.handles.axes2);
    colormap(gray);
    imagesc(I_zoomout);
    axis off
    
    %show appropriate ROIs
    UA_Drift_RoiDisp( posID )
    ua.drift.selectedPosID=posID;
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.drift.driftON=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.drift.zoomOutDrift=get(hObject,'Value');
if ua.drift.zoomOutDrift
    set(handles.edit1,'enable','on');
else
    set(handles.edit1,'enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes during object creation, after setting all properties.
function checkbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'Value',ua.drift.zoomOutDrift);



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.drift.zoomfactor=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.drift.zoomfactor));
if ua.drift.zoomOutDrift
    set(hObject,'enable','on');
else
    set(hObject,'enable','off');
end
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function checkbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'Value',ua.drift.driftON);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
find_dendrites_slider_GUI;


% --- Executes on button press in correctRoisCheckbox.
function correctRoisCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to correctRoisCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of correctRoisCheckbox
global dia
dia.acq.correctRois=get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function correctRoisCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correctRoisCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'Value',dia.acq.correctRois);
