function varargout = sj_cotnrolPanel(varargin)
% SJ_COTNROLPANEL M-file for sj_cotnrolPanel.fig
%      SJ_COTNROLPANEL, by itself, creates a new SJ_COTNROLPANEL or raises the existing
%      singleton*.
%
%      H = SJ_COTNROLPANEL returns the handle to a new SJ_COTNROLPANEL or the handle to
%      the existing singleton*.
%
%      SJ_COTNROLPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SJ_COTNROLPANEL.M with the given input arguments.
%
%      SJ_COTNROLPANEL('Property','Value',...) creates a new SJ_COTNROLPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sj_cotnrolPanel_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sj_cotnrolPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help sj_cotnrolPanel

% Last Modified by GUIDE v2.5 06-Feb-2009 16:41:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sj_cotnrolPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @sj_cotnrolPanel_OutputFcn, ...
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


% --- Executes just before sj_cotnrolPanel is made visible.
function sj_cotnrolPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sj_cotnrolPanel (see VARARGIN)

% Choose default command line output for sj_cotnrolPanel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sj_cotnrolPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sj_cotnrolPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Fast_FLIM.
function Fast_FLIM_Callback(hObject, eventdata, handles)
% hObject    handle to Fast_FLIM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Fast_FLIM
global gh;

pulseN = get(handles.pulseN, 'String');
set(gh.yphys.stimScope.pulseN, 'String', pulseN);
yphys_setupParameters;
yphys_generic;
yphys_loadAverage;




function pulseN_Callback(hObject, eventdata, handles)
% hObject    handle to pulseN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pulseN as text
%        str2double(get(hObject,'String')) returns contents of pulseN as a double


% --- Executes during object creation, after setting all properties.
function pulseN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulseN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


