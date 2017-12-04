function varargout = yphys_pageControls(varargin)
% YPHYS_PAGECONTROLS M-file for yphys_pageControls.fig
%      YPHYS_PAGECONTROLS, by itself, creates a new YPHYS_PAGECONTROLS or raises the existing
%      singleton*.
%
%      H = YPHYS_PAGECONTROLS returns the handle to a new YPHYS_PAGECONTROLS or the handle to
%      the existing singleton*.
%
%      YPHYS_PAGECONTROLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in YPHYS_PAGECONTROLS.M with the given input arguments.
%
%      YPHYS_PAGECONTROLS('Property','Value',...) creates a new YPHYS_PAGECONTROLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before yphys_pageControls_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to yphys_pageControls_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help yphys_pageControls

% Last Modified by GUIDE v2.5 30-Aug-2013 14:58:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @yphys_pageControls_OpeningFcn, ...
                   'gui_OutputFcn',  @yphys_pageControls_OutputFcn, ...
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


% --- Executes just before yphys_pageControls is made visible.
function yphys_pageControls_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to yphys_pageControls (see VARARGIN)

% Choose default command line output for yphys_pageControls
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes yphys_pageControls wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global state gh


state.internal.pageCounter = 0;
state.internal.binPageCounter = 0;
%state.internal.usePage = 0;

%state.spc.internal.integratePage = 1;
set(handles.Uncaging, 'String', state.yphys.acq.uncagePageText);
set(handles.nPages, 'String', num2str(state.acq.numberOfPages));
set(handles.integP, 'String', num2str(state.acq.numberOfBinPages));
%set(handles.usePageCheck, 'Value', state.internal.usePage);
set(handles.et_frames_per_page, 'String', num2str(state.acq.framesPerPage));
set(handles.etPageInterval, 'String',  num2str(state.acq.pageInterval));

set(handles.dep, 'Value', state.yphys.acq.depolarize);
set(handles.startDep, 'String', num2str(state.yphys.acq.startDep));
set(handles.stopDep, 'String', num2str(state.yphys.acq.stopDep));

gh.yphys.yphys_pageControls = handles;
update_all_values (handles);

% --- Outputs from this function are returned to the command line.
function varargout = yphys_pageControls_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Uncaging_Callback(hObject, eventdata, handles)
% hObject    handle to Uncaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Uncaging as text
%        str2double(get(hObject,'String')) returns contents of Uncaging as a double

update_all_values(handles);


% --- Executes during object creation, after setting all properties.
function Uncaging_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Uncaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPages_Callback(hObject, eventdata, handles)
% hObject    handle to nPages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPages as text
%        str2double(get(hObject,'String')) returns contents of nPages as a double
update_all_values(handles);

% --- Executes during object creation, after setting all properties.
function nPages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function integP_Callback(hObject, eventdata, handles)
% hObject    handle to integP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of integP as text
%        str2double(get(hObject,'String')) returns contents of integP as a double

update_all_values(handles);

% --- Executes during object creation, after setting all properties.
function integP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to integP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in usePageCheck.
function usePageCheck_Callback(hObject, eventdata, handles)
% hObject    handle to usePageCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of usePageCheck
update_all_values(handles);


% --- Executes on button press in dep.
function dep_Callback(hObject, eventdata, handles)
% hObject    handle to dep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dep
update_all_values(handles)


function startDep_Callback(hObject, eventdata, handles)
% hObject    handle to startDep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startDep as text
%        str2double(get(hObject,'String')) returns contents of startDep as a double
update_all_values(handles)

% --- Executes during object creation, after setting all properties.
function startDep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startDep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopDep_Callback(hObject, eventdata, handles)
% hObject    handle to stopDep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopDep as text
%        str2double(get(hObject,'String')) returns contents of stopDep as a double

update_all_values(handles);

% --- Executes during object creation, after setting all properties.
function stopDep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopDep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etPageInterval_Callback(hObject, eventdata, handles)
% hObject    handle to etPageInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etPageInterval as text
%        str2double(get(hObject,'String')) returns contents of etPageInterval as a double

update_all_values(handles);


% --- Executes during object creation, after setting all properties.
function etPageInterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPageInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_frames_per_page_Callback(hObject, eventdata, handles)
% hObject    handle to et_frames_per_page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_frames_per_page as text
%        str2double(get(hObject,'String')) returns contents of et_frames_per_page as a double
update_all_values(handles);

% --- Executes during object creation, after setting all properties.
function et_frames_per_page_CreateFcn(hObject, eventdata, handles)
% hObject    handle to et_frames_per_page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function update_all_values(handles)
global state gh

%state.internal.usePage = get(handles.usePageCheck, 'Value');
%
state.yphys.acq.uncagePage = str2num(get(handles.Uncaging, 'String'));
state.acq.numberOfPages = str2num(get(handles.nPages, 'String'));
state.acq.numberOfBinPages = str2num(get(handles.integP, 'String'));
state.acq.framesPerPage = str2num(get(handles.et_frames_per_page, 'String'));
state.acq.pageInterval = str2num(get(handles.etPageInterval, 'String'));
state.yphys.acq.depolarize = get(handles.dep, 'Value');
state.yphys.acq.startDep = str2num(get(handles.startDep, 'String'));
state.yphys.acq.stopDep = str2num(get(handles.stopDep, 'String'));    
state.yphys.acq.frame_scanning = str2num(get(handles.frameS, 'String'));

%%%Putting correct values:
Est_time = state.acq.linesPerFrame*state.acq.msPerLine/1000*state.acq.framesPerPage + 0.1 + state.yphys.acq.sLength(state.yphys.acq.pulseN)/1000+0.025;
set(handles.message1, 'String', sprintf('must be < %0.2f s\n      Uncaging time = %0.2f s\n      Acq time = %0.2f s', ...
    Est_time, state.yphys.acq.sLength(state.yphys.acq.pulseN)/1000, state.acq.linesPerFrame*state.acq.msPerLine/1000*state.acq.framesPerPage));
if state.acq.pageInterval < Est_time
    %state.acq.pageInterval = Est_time;
    set(handles.message1, 'ForegroundColor', 'red');
else
    set(handles.message1, 'ForegroundColor', 'black');
end

set(handles.et_frames_per_page, 'String', sprintf('%d', round(state.acq.framesPerPage)));
set(handles.etPageInterval, 'String', sprintf('%0.2f', state.acq.pageInterval));

set(handles.total_acq_time, 'String', sprintf('%0.1f s', state.acq.numberOfPages*state.acq.pageInterval));
set(handles.total_Frames_Per_Page, 'String', num2str(round(state.acq.framesPerPage*state.acq.numberOfBinPages)));
set(handles.time_per_avePage, 'String', sprintf('%0.2f s', state.acq.numberOfBinPages*state.acq.pageInterval));

if mod(state.acq.numberOfPages, state.acq.numberOfBinPages)
    state.acq.numberOfPages = state.acq.numberOfBinPages*ceil(state.acq.numberOfPages / state.acq.numberOfBinPages);
    set(handles.nPages, 'String', num2str(state.acq.numberOfPages));
    set(handles.total_ave_page, 'String', sprintf('%d', (state.acq.numberOfPages / state.acq.numberOfBinPages)), 'ForegroundColor', 'red');
    set(handles.er_message, 'String', '#pages / ave pages must be integer!!', 'ForegroundColor', 'red');
    set(handles.nPages,  'ForegroundColor', 'red');
    set(handles.integP, 'ForegroundColor', 'red');
else
    set(handles.total_ave_page, 'String', sprintf('%d', (state.acq.numberOfPages / state.acq.numberOfBinPages)), 'ForegroundColor', 'black');
    set(handles.er_message, 'String', '');
    set(handles.nPages,  'ForegroundColor', 'black');
    set(handles.integP, 'ForegroundColor', 'black');
end
if state.internal.usePage
    state.acq.numberOfFrames = state.acq.framesPerPage;
    state.acq.numberOfZSlices = state.acq.numberOfPages;
    state.acq.zStepSize = 0; %MISHA
else
    state.acq.numberOfFrames = str2num(get(gh.mainControls.framesTotal, 'String'));
    state.acq.numberOfZSlices = str2num(get(gh.mainControls.slicesTotal, 'String'));
    state.acq.zStepSize = str2double(get(gh.motorControls.etZStepPerSlice, 'String')); %MISHA
end


% --- Executes on button press in uncageControl.
function uncageControl_Callback(hObject, eventdata, handles)
% hObject    handle to uncageControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gh
try
    figure(gh.yphys.stimScope.figure1)
catch
    yphys_stimScope;
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
hideGUI(hObject);



function frameS_Callback(hObject, eventdata, handles)
% hObject    handle to frameS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameS as text
%        str2double(get(hObject,'String')) returns contents of frameS as a double
update_all_values(handles);
