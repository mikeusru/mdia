function varargout = optLensGui(varargin)
% OPTLENSGUI MATLAB code for optLensGui.fig
%      OPTLENSGUI, by itself, creates a new OPTLENSGUI or raises the existing
%      singleton*.
%
%      H = OPTLENSGUI returns the handle to a new OPTLENSGUI or the handle to
%      the existing singleton*.
%
%      OPTLENSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTLENSGUI.M with the given input arguments.
%
%      OPTLENSGUI('Property','Value',...) creates a new OPTLENSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before optLensGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to optLensGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help optLensGui

% Last Modified by GUIDE v2.5 12-May-2015 14:25:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @optLensGui_OpeningFcn, ...
                   'gui_OutputFcn',  @optLensGui_OutputFcn, ...
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


% --- Executes just before optLensGui is made visible.
function optLensGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to optLensGui (see VARARGIN)

% Choose default command line output for optLensGui
handles.output = hObject;

% Create a listener for the current slider
handles.sliderListener = addlistener(handles.currentSlider,'ContinuousValueChange',...
    @(hfigure,eventdata) currentSliderContValCallback(...
    hObject,eventdata));

% Update handles structure
guidata(hObject, handles);
global dia
dia.handles.optLens=handles;
set(dia.handles.optLens.freqSlider,'Max',1000); %set limits for frequency slider
set(dia.handles.optLens.freqSlider,'Min',0);
dia.guiStuff.optLensPanelPos=get(dia.handles.optLens.currentUipanel4,'Position');
updateOLGui;



% UIWAIT makes optLensGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = optLensGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function currentSliderContValCallback(hFigure,eventdata)
 % This is the function which is called when the slider value changes, even
 % if the button is not released.
 global dia
 handles = guidata(hFigure);
 %  dia.handles.optLens=handles; %not sure if this is necessary... taking it out for now
 current=str2double(sprintf('%.2f',get(handles.currentSlider,'Value'))); %workaround because rounding to decimal places doesn't work in old version.
 set(handles.currentEdit,'String',num2str(current));
 dia.hOL.setCurrent(current);



% --- Executes on slider movement.
function currentSlider_Callback(hObject, eventdata, handles)
% hObject    handle to currentSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function currentSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'Max',dia.hOL.upperSoftwareCurrentLimit);
set(hObject,'Min',dia.hOL.lowerSoftwareCurrentLimit);
set(hObject,'Value',dia.hOL.current);


% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function currentEdit_Callback(hObject, eventdata, handles)
% hObject    handle to currentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
current=str2double(get(hObject,'String'));
dia.hOL.setCurrent(current);

% Hints: get(hObject,'String') returns contents of currentEdit as text
%        str2double(get(hObject,'String')) returns contents of currentEdit as a double


% --- Executes during object creation, after setting all properties.
function currentEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
current=dia.hOL.current;
set(hObject,'String',num2str(current));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function upperSoftwareLimitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to upperSoftwareLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
current=str2double(get(hObject,'String'));
dia.hOL.setUpperSoftwareCurrentLimit(current);
updateOLGui;
% Hints: get(hObject,'String') returns contents of upperSoftwareLimitEdit as text
%        str2double(get(hObject,'String')) returns contents of upperSoftwareLimitEdit as a double


% --- Executes during object creation, after setting all properties.
function upperSoftwareLimitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperSoftwareLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia

set(hObject,'String',num2str(dia.hOL.upperSoftwareCurrentLimit));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lowSoftwareLimitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to lowSoftwareLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
current=str2double(get(hObject,'String'));
dia.hOL.setLowerSoftwareCurrentLimit(current);
updateOLGui;
% Hints: get(hObject,'String') returns contents of lowSoftwareLimitEdit as text
%        str2double(get(hObject,'String')) returns contents of lowSoftwareLimitEdit as a double


% --- Executes during object creation, after setting all properties.
function lowSoftwareLimitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowSoftwareLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia

set(hObject,'String',num2str(dia.hOL.lowerSoftwareCurrentLimit));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxCurrentEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxCurrentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxCurrentEdit as text
%        str2double(get(hObject,'String')) returns contents of maxCurrentEdit as a double


% --- Executes during object creation, after setting all properties.
function maxCurrentEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxCurrentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia

set(hObject,'String',num2str(dia.hOL.maxOutputCurrent));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in operationModePopupmenu.
function operationModePopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to operationModePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hOL.currentMode=get(hObject,'Value');
switch dia.hOL.currentMode
    case 1
        dia.hOL.setDCmode;
        dia.hOL.setCurrent(0);
    case 2
        dia.hOL.setTriangularSignal;
    case 3
        dia.hOL.setRectangularSignal;
    case 4
        dia.hOL.setSinusoidalSignal;
end
if dia.hOL.currentMode~=1 %if frequency mode, set hardware swing
   dia.hOL.setUpSwingLimit(dia.hOL.upSwing);
   dia.hOL.setLowSwingLimit(dia.hOL.lowSwing);
end
updateOLGui;


% Hints: contents = cellstr(get(hObject,'String')) returns operationModePopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from operationModePopupmenu


% --- Executes during object creation, after setting all properties.
function operationModePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to operationModePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resetPushbutton.
function resetPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
set(handles.currentEdit,'String','0');
set(handles.currentSlider,'Value',0);
dia.hOL.setCurrent(0);


% --- Executes on button press in connectPushbutton.
function connectPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to connectPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia

if strcmp(get(hObject,'String'),'Connect')
    dia.hOL.initialize;
    set(hObject,'String','Disconnect');
else
    dia.hOL.disconnect;
    set(hObject,'String','Connect');
end


% --- Executes during object creation, after setting all properties.
function connectPushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to connectPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
switch dia.hOL.optLens.Status
    case 'closed'
        set(hObject,'String','Connect');
    case 'open'
        set(hObject,'String','Disconnect');
end


% --- Executes on slider movement.
function freqSlider_Callback(hObject, eventdata, handles)
% hObject    handle to freqSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hOL.setFrequency(get(hObject,'Value'));
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function freqSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function freqEdit_Callback(hObject, eventdata, handles)
% hObject    handle to freqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hOL.setFrequency(str2double(get(hObject,'String')));
updateOLGui;
% Hints: get(hObject,'String') returns contents of freqEdit as text
%        str2double(get(hObject,'String')) returns contents of freqEdit as a double


% --- Executes during object creation, after setting all properties.
function freqEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function lowSwingSlider_Callback(hObject, eventdata, handles)
% hObject    handle to lowSwingSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hOL.setLowSwingLimit(get(hObject,'Value'));
updateOLGui;
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function lowSwingSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowSwingSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function upSwingSlider_Callback(hObject, eventdata, handles)
% hObject    handle to upSwingSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hOL.setUpSwingLimit(get(hObject,'Value'));
updateOLGui;
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function upSwingSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upSwingSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function lowSwingEdit_Callback(hObject, eventdata, handles)
% hObject    handle to lowSwingEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hOL.setLowSwingLimit(str2double(get(hObject,'String')));
updateOLGui;
% Hints: get(hObject,'String') returns contents of lowSwingEdit as text
%        str2double(get(hObject,'String')) returns contents of lowSwingEdit as a double


% --- Executes during object creation, after setting all properties.
function lowSwingEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowSwingEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function upSwingEdit_Callback(hObject, eventdata, handles)
% hObject    handle to upSwingEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hOL.setUpSwingLimit(str2double(get(hObject,'String')));
updateOLGui;
% Hints: get(hObject,'String') returns contents of upSwingEdit as text
%        str2double(get(hObject,'String')) returns contents of upSwingEdit as a double


% --- Executes during object creation, after setting all properties.
function upSwingEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upSwingEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function recFreqSlider_Callback(hObject, eventdata, handles)
% hObject    handle to recFreqSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function recFreqSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recFreqSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function recFreqEdit_Callback(hObject, eventdata, handles)
% hObject    handle to recFreqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recFreqEdit as text
%        str2double(get(hObject,'String')) returns contents of recFreqEdit as a double


% --- Executes during object creation, after setting all properties.
function recFreqEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recFreqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function recLowSlider_Callback(hObject, eventdata, handles)
% hObject    handle to recLowSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function recLowSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recLowSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function recUpSlider_Callback(hObject, eventdata, handles)
% hObject    handle to recUpSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function recUpSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recUpSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function recLowEdit_Callback(hObject, eventdata, handles)
% hObject    handle to recLowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recLowEdit as text
%        str2double(get(hObject,'String')) returns contents of recLowEdit as a double


% --- Executes during object creation, after setting all properties.
function recLowEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recLowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function recUpEdit_Callback(hObject, eventdata, handles)
% hObject    handle to recUpEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recUpEdit as text
%        str2double(get(hObject,'String')) returns contents of recUpEdit as a double


% --- Executes during object creation, after setting all properties.
function recUpEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recUpEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function triFreqSlider_Callback(hObject, eventdata, handles)
% hObject    handle to triFreqSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function triFreqSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triFreqSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function triFreqEdit_Callback(hObject, eventdata, handles)
% hObject    handle to triFreqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of triFreqEdit as text
%        str2double(get(hObject,'String')) returns contents of triFreqEdit as a double


% --- Executes during object creation, after setting all properties.
function triFreqEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triFreqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function triLowSlider_Callback(hObject, eventdata, handles)
% hObject    handle to triLowSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function triLowSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triLowSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function triUpSlider_Callback(hObject, eventdata, handles)
% hObject    handle to triUpSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function triUpSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triUpSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function triLowEdit_Callback(hObject, eventdata, handles)
% hObject    handle to triLowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of triLowEdit as text
%        str2double(get(hObject,'String')) returns contents of triLowEdit as a double


% --- Executes during object creation, after setting all properties.
function triLowEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triLowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function triUpEdit_Callback(hObject, eventdata, handles)
% hObject    handle to triUpEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of triUpEdit as text
%        str2double(get(hObject,'String')) returns contents of triUpEdit as a double


% --- Executes during object creation, after setting all properties.
function triUpEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triUpEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setZlimitPushbutton.
function setZlimitPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setZlimitPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function setZlimitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to setZlimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setZlimitEdit as text
%        str2double(get(hObject,'String')) returns contents of setZlimitEdit as a double


% --- Executes during object creation, after setting all properties.
function setZlimitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setZlimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
