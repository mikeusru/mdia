% #########################################################################
% FLIMimage v1.0r100
% Ryohei Yasuda, Aleksander Sobczyk
% Cold Spring Harbor Labs
% #########################################################################

function varargout = FLIMimage(varargin)
% FLIMIMAGE M-file for FLIMimage.fig
%      FLIMIMAGE, by itself, creates a new FLIMIMAGE or raises the existing
%      singleton*.
%
%      H = FLIMIMAGE returns the handle to a new FLIMIMAGE or the handle to
%      the existing singleton*.
%
%      FLIMIMAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLIMIMAGE.M with the given input arguments.
%
%      FLIMIMAGE('Property','Value',...) creates a new FLIMIMAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FLIMimage_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FLIMimage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FLIMimage

% Last Modified by GUIDE v2.5 01-May-2013 17:56:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FLIMimage_OpeningFcn, ...
                   'gui_OutputFcn',  @FLIMimage_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% #########################################################################
% --- Executes just before FLIMimage is made visible.
function FLIMimage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FLIMimage (see VARARGIN)

% Choose default command line output for FLIMimage
global gh
global state gui

gh.spc.FLIMimage = handles;
handles.output = hObject;
gh.spc.FLIMimage.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FLIMimage wait for user response (see UIRESUME)
% uiwait(handles.figure1);
flim_ini;
spc_setupPixelClockDAQ_Common; %%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Need to be comppletely rewritten.
if strcmp(state.spc.init.dllname, 'TH260lib')
    PQ_init;
    PQ_setParameters(0);
else
    FLIM_Init(hObject,handles);
end
%guidata(hObject,handles);

try
	spc_drawInit;
    figure(gui.spc.figure.project);
    colormap('gray');
catch ME
   disp('Error in spc_drawInit');
   for i=1:length(ME.stack)
       disp(ME.stack(i).file);
       disp(ME.stack(i).name);
       disp(ME.stack(i).line);
   end
   fprintf(2,'ERROR in callback function (%s): \t%s\n',mfilename,ME.message);
end


%%%%Set Initial values%%%%%%%%%%%%%%%%%%
%set(handles.image, 'Value', state.spc.acq.spc_image);
set(handles.flimcheck, 'Value', state.spc.acq.spc_takeFLIM); 
set(handles.checkbox3, 'Value', state.spc.acq.spc_binning);
set(handles.frameScan, 'Value', ~state.spc.acq.spc_average);
set(handles.pageScan, 'Value', state.internal.usePage);
set(handles.showImages, 'Value', state.spc.init.spc_showImages, 'Enable', 'off');
set(handles.stream, 'Value', state.spc.init.infinite_Nframes);
set(handles.checkbox1, 'value', 1); %show photon / sync rates.
state.spc.acq.binFactor=1;
state.spc.acq.spc_binning = 0;

%set(handles.checkbox1,'Value', 1);
set(handles.Uncage, 'Value', state.spc.acq.uncageBox);
set(handles.BinFPop, 'Value', 1);

if strcmp(state.spc.init.dllname, 'TH260lib')
    set(handles.acquire_every_other, 'String', 'PQ TH260');
    set(handles.st_cfd, 'string', 'Ch 1');
    set(handles.st_tac, 'string', 'Ch 2');
    set(handles.st_adc, 'string', '');
    set(handles.checkbox3, 'Value', 0);
    set(handles.checkbox3, 'Enable', 'off'); %Binning.
end

if state.spc.acq.spc_takeFLIM
    state.spc.init.ao_flim1.writeAnalogData([5,0], 1, true);
else
    state.spc.init.ao_flim1.writeAnalogData([0,5], 1, true);
end

if ~isempty(strfind(state.spc.init.dllname, 'spcm'))
    out1=calllib(state.spc.init.dllname,'SPC_clear_rates',state.spc.acq.module);
end
state.spc.acq.timer.timerRatesEVER=true;
state.spc.acq.timer.timerRates=timer('TimerFcn','FLIM_TimerFunctionRates','ExecutionMode','fixedSpacing','Period',2.0);
start(state.spc.acq.timer.timerRates);

% #########################################################################
% --- Outputs from this function are returned to the command line.
function varargout = FLIMimage_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% #########################################################################
function FLIM_MenuFile_Callback(hObject, eventdata, handles)

% #########################################################################
function FLIM_MenuFileExit_Callback(hObject, eventdata, handles)
FLIM_Close;

% #########################################################################
function FLIM_MenuParameters_Callback(hObject, eventdata, handles)
global state
if strcmp(state.spc.init.dllname, 'TH260lib')
    PQ_parameters;
else
    FLIM_Parameters;
end

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles) %'Show the rate of SYNC, CFD, TAC'
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

global state;


if(isvalid(state.spc.acq.timer.timerRates)==1) && (get(hObject,'Value')==1)
    if ~strcmp(state.spc.init.dllname, 'TH260lib')    
        out1=calllib(state.spc.init.dllname,'SPC_clear_rates',state.spc.acq.module);
    end
    state.spc.acq.timer.timerRatesEVER=true;
    %state.spc.acq.timer.timerRates=timer('TimerFcn','FLIM_TimerFunctionRates','ExecutionMode','fixedSpacing','Period',2.0);
    start(state.spc.acq.timer.timerRates);
end

if (isvalid(state.spc.acq.timer.timerRates)==1) && (get(hObject,'Value')==0)
    set(handles.edit2,'String','');
    set(handles.edit3,'String','');
    set(handles.edit4,'String','');
    set(handles.edit5,'String','');
    stop(state.spc.acq.timer.timerRates);
    %delete(state.spc.acq.timer.timerRates);
end


% --- Executes on button press in recover.
function recover_Callback(hObject, eventdata, handles)
% hObject    handle to recover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

spc_abortCurrent;


% --- Executes on button press in checkbox Bining.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
global state;
value=get(hObject, 'Value');
state.spc.acq.spc_binning = value;
   if FLIM_setupScanning(0)
        return;
    end    

% --- Executes on button press in Uncage.
function Uncage_Callback(hObject, eventdata, handles)
% hObject    handle to Uncage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Uncage
global state;
value=get(hObject, 'Value');
state.spc.acq.uncageBox = value;


% --- Executes during object creation, after setting all properties.
function BinFPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BinFPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in BinFPop.
function BinFPop_Callback(hObject, eventdata, handles)
% hObject    handle to BinFPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns BinFPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BinFPop

global state;
value=get(hObject, 'Value');
state.spc.acq.binFactor= 2^(value-1);
state.spc.acq.spc_binning = 1;
set(handles.checkbox3, 'Value', 1);
   if FLIM_setupScanning(0)
        return;
    end   



% --- Executes on button press in flimcheck.
function flimcheck_Callback(hObject, eventdata, handles)
% hObject    handle to flimcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flimcheck

global state;

value = get(hObject, 'Value');
state.spc.acq.spc_takeFLIM = value;
%%%%%%%%%%%%%
if state.spc.acq.spc_takeFLIM
    state.spc.init.ao_flim1.writeAnalogData([5,0], 1, true);
else
    state.spc.init.ao_flim1.writeAnalogData([0,5], 1, true);
end
%%%%%%%%%%%%%%



% --- Executes on button press in frameScan.
function frameScan_Callback(hObject, eventdata, handles)
% hObject    handle to frameScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of frameScan

global state

value = get(hObject, 'Value');
state.spc.acq.spc_average = ~value;
if value
    set(handles.pageScan, 'Value', 0);
    state.internal.usePage = 0;
end


% --- Executes on button press in pageScan.
function pageScan_Callback(hObject, eventdata, handles)
% hObject    handle to pageScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pageScan
global state

value = get(hObject, 'Value');
state.internal.usePage = value;
if value
    set(handles.frameScan, 'Value', 0);
    state.spc.acq.spc_average = 1;
end

% --- Executes on button press in pageControl.
function pageControl_Callback(hObject, eventdata, handles)
% hObject    handle to pageControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gh
try
    figure(gh.yphys.yphys_pageControls.figure1);
catch
    yphys_pageControls;
end


% --- Executes on button press in showImages.
function showImages_Callback(hObject, eventdata, handles)
% hObject    handle to showImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showImages

global state
state.spc.init.spc_showImages = get(hObject, 'Value');


% --- Executes on button press in uncageControl.
function uncageControl_Callback(hObject, eventdata, handles)
% hObject    handle to uncageControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gh

try
    figure(gh.yphys.stimScope.figure1);
catch
    yphys_stimScope;
end


% --------------------------------------------------------------------
function menu_viewAll_Callback(hObject, eventdata, handles)
% hObject    handle to menu_viewAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gui gh

% try
%     figure(gh.yphys.stimScope.figure1)
% catch
%     yphys_stimScope;
% end
% 
% try
%     figure(gh.yphys.yphys_pageControls.figure1)
% catch
%     yphys_pageControls;
% end
%
figure(gui.spc.spc_main.spc_main)
figure(gui.spc.figure.lifetimeMap)
figure(gui.spc.figure.lifetime)
figure(gui.spc.figure.project)



% --- Executes on button press in stream.
function stream_Callback(hObject, eventdata, handles)
% hObject    handle to stream (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stream

global state
state.spc.init.infinite_Nframes = get(hObject, 'Value');
if state.spc.init.infinite_Nframes
    set(handles.acquire_every_other, 'String', 'Acquire every other frame');
    set(handles.frame_limit, 'String', 'No limit in num of frames');
else
    set(handles.acquire_every_other, 'String', 'Acquire every frame');   
    set(handles.frame_limit, 'String', ['Num of frames must be < ', num2str(1024)]);
end
