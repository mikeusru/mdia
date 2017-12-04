function varargout = PQ_parameters(varargin)
% PQ_PARAMETERS MATLAB code for PQ_parameters.fig
%      PQ_PARAMETERS, by itself, creates a new PQ_PARAMETERS or raises the existing
%      singleton*.
%
%      H = PQ_PARAMETERS returns the handle to a new PQ_PARAMETERS or the handle to
%      the existing singleton*.
%
%      PQ_PARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PQ_PARAMETERS.M with the given input arguments.
%
%      PQ_PARAMETERS('Property','Value',...) creates a new PQ_PARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PQ_parameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PQ_parameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PQ_parameters

% Last Modified by GUIDE v2.5 14-Nov-2016 16:23:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PQ_parameters_OpeningFcn, ...
                   'gui_OutputFcn',  @PQ_parameters_OutputFcn, ...
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


% --- Executes just before PQ_parameters is made visible.
function PQ_parameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PQ_parameters (see VARARGIN)

% Choose default command line output for PQ_parameters
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PQ_parameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global gh state gui spc

gh.spc.pq_parameters = handles;

flim_ini;
fid = fopen('PQ_parameters.m');
[fileName,~, ~] = fopen(fid);
[pathstr,~,~] = fileparts(fileName);
fclose(fid);
% fname = [pathstr, '\spc_init.mat'];
% if exist(fname, 'file')
%     load(fname);
%     state.spc.acq.SPCdata = SPCdata;
% end

state.spc.internal.hPQ = PQC_acquisition(state.spc.acq.module, state.spc.acq.SPCdata.mode);
PQC_fillParameters;
PQC_setParametersGUI(0);
try
    PQC_setupAcqTimers;
end
%state.spc.acq.timer.pqc_timerRates=timer('TimerFcn','PQC_TimerFunctionRates','ExecutionMode','fixedSpacing','Period',1.0);
start(state.spc.acq.timer.pqc_timerRates);
set(gh.spc.pq_parameters.cb_showrates, 'value', 1);

try
	spc_drawInit;
    figure(gui.spc.figure.project);
    colormap('gray');
    set(gui.spc.figure.LutLowerlimit, 'String', '0');

%     fname = [pathstr, '\fig_pos.mat'];
%     figName = {'lifetimeMap', 'lifetime', 'scanImgF', 'project'};
%     if exist(fname, 'file')
%         load(fname);
%         pos1 = get(gui.spc.spc_main.spc_main, 'position');
%         set(gui.spc.spc_main.spc_main, 'position', [fig_pos.main(1:2), pos1(3:4)]);
%         pos2 = get(gh.spc.pq_parameters.figure1, 'position');
%         set(gh.spc.pq_parameters.figure1, 'position', [fig_pos.pq_parameters(1:2), pos2(3:4)]);
%         
%         for i = 1:length(figName)
%             evalc(sprintf('set(gui.spc.figure.%s, ''position'', fig_pos.%s)', figName{i}, figName{i}));
%         end
%     end
    
catch ME
   disp('Error in spc_drawInit');
   for i=1:length(ME.stack)
       disp(ME.stack(i).file);
       disp(ME.stack(i).name);
       disp(ME.stack(i).line);
   end
   fprintf(2,'ERROR in callback function (%s): \t%s\n',mfilename,ME.message);
end


% --- Outputs from this function are returned to the command line.
function varargout = PQ_parameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function n_channels_Callback(hObject, eventdata, handles)
% hObject    handle to n_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_channels as text
%        str2double(get(hObject,'String')) returns contents of n_channels as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function n_channels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function binning_Callback(hObject, eventdata, handles)
% hObject    handle to binning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binning as text
%        str2double(get(hObject,'String')) returns contents of binning as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function binning_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function input_offset2_Callback(hObject, eventdata, handles)
% hObject    handle to input_offset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_offset2 as text
%        str2double(get(hObject,'String')) returns contents of input_offset2 as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function input_offset2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_offset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function input_zc_level2_Callback(hObject, eventdata, handles)
% hObject    handle to input_zc_level2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_zc_level2 as text
%        str2double(get(hObject,'String')) returns contents of input_zc_level2 as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function input_zc_level2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_zc_level2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_trigger_level2_Callback(hObject, eventdata, handles)
% hObject    handle to input_trigger_level2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_trigger_level2 as text
%        str2double(get(hObject,'String')) returns contents of input_trigger_level2 as a double
state.spc.acq.SPCdata.cfd_limit_low(2) = str2num(get(hObject, 'string'));
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function input_trigger_level2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_trigger_level2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_trigger_level1_Callback(hObject, eventdata, handles)
% hObject    handle to input_trigger_level1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_trigger_level1 as text
%        str2double(get(hObject,'String')) returns contents of input_trigger_level1 as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function input_trigger_level1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_trigger_level1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_zc_level1_Callback(hObject, eventdata, handles)
% hObject    handle to input_zc_level1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_zc_level1 as text
%        str2double(get(hObject,'String')) returns contents of input_zc_level1 as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function input_zc_level1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_zc_level1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_offset1_Callback(hObject, eventdata, handles)
% hObject    handle to input_offset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_offset1 as text
%        str2double(get(hObject,'String')) returns contents of input_offset1 as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function input_offset1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_offset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sync_trigger_level_Callback(hObject, eventdata, handles)
% hObject    handle to sync_trigger_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sync_trigger_level as text
%        str2double(get(hObject,'String')) returns contents of sync_trigger_level as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function sync_trigger_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sync_trigger_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sync_zc_level_Callback(hObject, eventdata, handles)
% hObject    handle to sync_zc_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sync_zc_level as text
%        str2double(get(hObject,'String')) returns contents of sync_zc_level as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function sync_zc_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sync_zc_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sync_offset_Callback(hObject, eventdata, handles)
% hObject    handle to sync_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sync_offset as text
%        str2double(get(hObject,'String')) returns contents of sync_offset as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function sync_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sync_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sync_freq_div_Callback(hObject, eventdata, handles)
% hObject    handle to sync_freq_div (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sync_freq_div as text
%        str2double(get(hObject,'String')) returns contents of sync_freq_div as a double
PQC_setParametersGUI(1);

% --- Executes during object creation, after setting all properties.
function sync_freq_div_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sync_freq_div (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_flim_check.
function cb_flim_check_Callback(hObject, eventdata, handles)
% hObject    handle to cb_flim_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_flim_check
PQC_setParametersGUI(1);

% --- Executes on button press in cb_uncage.
function cb_uncage_Callback(hObject, eventdata, handles)
% hObject    handle to cb_uncage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_uncage
PQC_setParametersGUI(1);

% --- Executes on button press in cb_page.
function cb_page_Callback(hObject, eventdata, handles)
% hObject    handle to cb_page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_page
PQC_setParametersGUI(1);


% --- Executes on button press in cb_showrates.
function cb_showrates_Callback(hObject, eventdata, handles)
% hObject    handle to cb_showrates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_showrates
global state;
val = get(hObject, 'value');
if val
    start(state.spc.acq.timer.pqc_timerRates);
else
    stop(state.spc.acq.timer.pqc_timerRates);
end



    


% --- Executes on button press in pb_reset.
function pb_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pb_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PQ_reset;


% --- Executes on button press in cb_FLIM_focus.
function cb_FLIM_focus_Callback(hObject, eventdata, handles)
% hObject    handle to cb_FLIM_focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_FLIM_focus
PQC_setParametersGUI(1);
