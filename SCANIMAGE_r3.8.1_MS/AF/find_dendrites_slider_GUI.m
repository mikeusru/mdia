function varargout = find_dendrites_slider_GUI(varargin)
% FIND_DENDRITES_SLIDER_GUI MATLAB code for find_dendrites_slider_GUI.fig
%      FIND_DENDRITES_SLIDER_GUI, by itself, creates a new FIND_DENDRITES_SLIDER_GUI or raises the existing
%      singleton*.
%
%      H = FIND_DENDRITES_SLIDER_GUI returns the handle to a new FIND_DENDRITES_SLIDER_GUI or the handle to
%      the existing singleton*.
%
%      FIND_DENDRITES_SLIDER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIND_DENDRITES_SLIDER_GUI.M with the given input arguments.
%
%      FIND_DENDRITES_SLIDER_GUI('Property','Value',...) creates a new FIND_DENDRITES_SLIDER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before find_dendrites_slider_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to find_dendrites_slider_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help find_dendrites_slider_GUI

% Last Modified by GUIDE v2.5 22-Mar-2016 15:42:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @find_dendrites_slider_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @find_dendrites_slider_GUI_OutputFcn, ...
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

% --- Executes just before find_dendrites_slider_GUI is made visible.
function find_dendrites_slider_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to find_dendrites_slider_GUI (see VARARGIN)

% Choose default command line output for find_dendrites_slider_GUI
handles.output = hObject;

% Create a listener for the slider
handles.sliderListener = addlistener(handles.contrastSlider,'ContinuousValueChange',...
    @(hfigure,eventdata) contrastSliderContValCallback(...
    hObject,eventdata));
handles.sliderListener2 = addlistener(handles.distanceSlider,'ContinuousValueChange',...
    @(hfigure,eventdata) contrastSliderContValCallback(...
    hObject,eventdata));


% Update handles structure
guidata(hObject, handles);

global af
af.handles=handles;

% This sets up the initial plot - only do when we are invisible
% so window can get raised using find_dendrites_slider_GUI.
if strcmp(get(hObject,'Visible'),'off')
    contrastSliderCallback();
end



% UIWAIT makes find_dendrites_slider_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = find_dendrites_slider_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function contrastSliderContValCallback(hFigure,eventdata)
% This is the function which is called when the slider value changes, even
% if the button is not released.
global af
handles = guidata(hFigure);
af.handles=handles;
%  totalval=round(get(handles.contrastSlider,'Value'));
af.params.thresh=str2double(sprintf('%.3f',get(handles.contrastSlider,'Value'))); %workaround because rounding to decimal places doesn't work in old version.
af.params.roiDist=str2double(sprintf('%.3f',get(handles.distanceSlider,'Value')));
set(handles.lowThreshBox,'String',num2str(af.params.thresh*100));
set(handles.distEdit,'String',num2str(af.params.roiDist*100));

contrastSliderCallback();




% --- Executes during object creation, after setting all properties.
function contrastSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrastSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.params.thresh);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes1
global state

% af.handles.axes=hObject;



function lowThreshBox_Callback(hObject, eventdata, handles)
% hObject    handle to lowThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
input=str2double(get(hObject,'String'));
if ~isnan(input)
    af.params.thresh=input/100;
    set(handles.contrastSlider,'Value',input/100);
    contrastSliderCallback();
    
end
% Hints: get(hObject,'String') returns contents of lowThreshBox as text
%        str2double(get(hObject,'String')) returns contents of lowThreshBox as a double


% --- Executes during object creation, after setting all properties.
function lowThreshBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',num2str(af.params.thresh*100));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function contrastSlider_Callback(hObject, eventdata, handles)
% hObject    handle to contrastSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes on button press in updateImagePushbutton.
function updateImagePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to updateImagePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af ua
channel=af.params.channel;
if ua.drift.useMaxProjection
    I=updateCurrentImage(channel,2);
else
    I=updateCurrentImage(channel,1);
end

contrastSliderCallback;


% --- Executes on slider movement.
function distanceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to distanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function distanceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.params.roiDist);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function distEdit_Callback(hObject, eventdata, handles)
% hObject    handle to distEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
input=str2double(get(hObject,'String'));
if ~isnan(input)
    af.params.roiDist=input/100;
    set(handles.distanceSlider,'Value',input/100);
    contrastSliderCallback();
    
end
% Hints: get(hObject,'String') returns contents of distEdit as text
%        str2double(get(hObject,'String')) returns contents of distEdit as a double


% --- Executes during object creation, after setting all properties.
function distEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',num2str(af.params.roiDist*100));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
