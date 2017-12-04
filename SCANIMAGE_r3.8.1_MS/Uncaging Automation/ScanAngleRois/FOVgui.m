function varargout = FOVgui(varargin)
% FOVGUI MATLAB code for FOVgui.fig
%      FOVGUI, by itself, creates a new FOVGUI or raises the existing
%      singleton*.
%
%      H = FOVGUI returns the handle to a new FOVGUI or the handle to
%      the existing singleton*.
%
%      FOVGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FOVGUI.M with the given input arguments.
%
%      FOVGUI('Property','Value',...) creates a new FOVGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FOVgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FOVgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FOVgui

% Last Modified by GUIDE v2.5 08-Feb-2016 12:07:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FOVgui_OpeningFcn, ...
    'gui_OutputFcn',  @FOVgui_OutputFcn, ...
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


% --- Executes just before FOVgui is made visible.
function FOVgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FOVgui (see VARARGIN)

% Choose default command line output for FOVgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global ua
ua.fov.handles=handles;

% UIWAIT makes FOVgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FOVgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in addFov_pushbutton.
function addFov_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to addFov_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addFovCallback;

% --- Executes on button press in clearFov_pushbutton.
function clearFov_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearFov_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua dia

dia.hPos.clearFOV;

if isfield(ua.fov.handles,'fov')
    delete(ua.fov.handles.fov(ishandle(ua.fov.handles.fov)));
end
% ua.fov.positions=[]; %remove when hPos is ready
% ua.fov.FOVposStruct=[]; %remove when hPos is ready
if isfield(ua.fov.handles,'fovFixed')
    for i=1:length(ua.fov.handles.fovFixed)
        if ishandle(ua.fov.handles.fovFixed(i))
            delete(ua.fov.handles.fovFixed(i));
        end
    end
end

updateUAgui;

% --- Executes on button press in saveFovs_pushbutton.
function saveFovs_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveFovs_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua dia
% ofst=[dia.hPos.posXYZ_graph_offset(1) dia.hPos.posXYZ_graph_offset(2) 0 0];

% ofst=[ua.fov.posXYZ_graph_offset(1) ua.fov.posXYZ_graph_offset(2) 0 0]; %remove when hPos is ready

dia.hPos.translateMotorToScanningROIs;
% 
% for i=1:length(ua.fov.handles.fov)
%     if isvalid(ua.fov.handles.fov(i))
%         pos=getPosition(ua.fov.handles.fov(i))+ofst;
%         ds.graphPosition{i,1} = pos;
%         hr=rectangle('Position',pos - ofst,'EdgeColor','k');
% %         if isfield(ua.fov,'positions') && ~isempty(ua.fov.positions) %remove when hPos is ready
% %             ua.fov.positions(end+1,:)=pos;
% %         else
% %             ua.fov.positions(1,:)=pos;
% %         end
% %         hr=rectangle('Position',ua.fov.positions(end,:)-ofst,'EdgeColor','k');
% %         if isfield(ua.fov.handles,'fovFixed')
% %             ua.fov.handles.fovFixed(end+1)=hr;
% %         else
% %             ua.fov.handles.fovFixed(1)=hr;
% %         end
% %         delete(ua.fov.handles.fov(i));
%     end
% end

% setScanningRois;



% --- Executes on button press in reset_pushbutton.
function reset_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to reset_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
groupRoisByFOV;


% --- Executes on button press in translateMotorPositions_pushbutton.
function translateMotorPositions_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to translateMotorPositions_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dia.hPos.translateMotorToScanningROIs;
% setScanningRois;


% --- Executes on button press in alignPositions_pushbutton.
function alignPositions_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to alignPositions_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
allPosIDs = dia.hPos.allPositionsDS.posID(dia.hPos.allPositionsDS.FOVnum == min(dia.hPos.allPositionsDS.FOVnum));
locateNewPosition(allPosIDs);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
