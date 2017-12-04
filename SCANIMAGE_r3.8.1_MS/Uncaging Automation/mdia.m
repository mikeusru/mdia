function varargout = mdia(varargin)
% FIGURE1 MATLAB code for figure1.fig
%      FIGURE1, by itself, creates a new FIGURE1 or raises the existing
%      singleton*.
%
%      H = FIGURE1 returns the handle to a new FIGURE1 or the handle to
%      the existing singleton*.
%
%      FIGURE1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE1.M with the given input arguments.
%
%      FIGURE1('Property','Value',...) creates a new FIGURE1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mdia_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mdia_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figure1

% Last Modified by GUIDE v2.5 26-Apr-2016 11:50:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mdia_OpeningFcn, ...
    'gui_OutputFcn',  @mdia_OutputFcn, ...
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


% --- Executes just before figure1 is made visible.
function mdia_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figure1 (see VARARGIN)
global dia af
% Choose default command line output for figure1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
dia.handles.mdia=handles;
set(dia.handles.mdia.figure1,'Tag','mdia');
%% load these settings before starting figure
try
    set(dia.handles.mdia.afModePanel,'SelectedObject',dia.handles.mdia.(af.params.mode));
end
set(dia.handles.mdia.figure1,'position',[520,208,506,613]);
set(dia.handles.mdia.singlePositionPanel,'BorderType','none','Title','');
set(dia.handles.mdia.multiPositionPanel,'BorderType','none','Title','');
set(dia.handles.mdia.ribbonUipanel,'BorderType','none','Title','');
mdiaSelectPanel;
updateUAgui;
updateMdiaEnabled;

%%



% UIWAIT makes figure1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mdia_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function singlePositionPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to singlePositionPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
dia.guiStuff.panelPos=get(hObject,'Position');


% --- Executes when selected object is changed in tabPanel.
function tabPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in tabPanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global dia

dia.guiStuff.panelSelection=get(eventdata.NewValue,'Tag');
mdiaSelectPanel;


%
% function edit1_Callback(hObject, eventdata, handles)
% % hObject    handle to edit1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% % Hints: get(hObject,'String') returns contents of edit1 as text
% %        str2double(get(hObject,'String')) returns contents of edit1 as a double
%
%
% % --- Executes during object creation, after setting all properties.
% function edit1_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
%
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
%
%
%
% function edit2_Callback(hObject, eventdata, handles)
% % hObject    handle to edit2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% % Hints: get(hObject,'String') returns contents of edit2 as text
% %        str2double(get(hObject,'String')) returns contents of edit2 as a double
%
%
% % --- Executes during object creation, after setting all properties.
% function edit2_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
%
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --- Executes on selection change in aaSelectPopupmenu.
function aaSelectPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to aaSelectPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject, 'String');
val = get(hObject,'Value');
% globally declare autofocus structure
global af
% check if an algorithm has been selected
af.algorithm.value=val;
if strcmp(str{val},'Select Autofocus Algorithm')==0
    af.algorithm.selected=1;
    % Set algorithm to global af structure.
    af.algorithm.operator=str{val};
else af.algorithm.selected=0;
end
% Hints: contents = cellstr(get(hObject,'String')) returns aaSelectPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from aaSelectPopupmenu


% --- Executes during object creation, after setting all properties.
function aaSelectPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aaSelectPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global af
set(hObject,'Value',af.algorithm.value);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zrangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to zrangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=str2double(get(hObject,'String'));
global af
% add z range to global autofocus parameters
af.params.zrange=str;
if isfield(af.params,'zstep')
    if isa(af.params.zstep,'double')==1 && isa(af.params.zrange,'double')==1 ...
            && isnan(af.params.zstep)==0 && isnan(af.params.zrange)==0
        af.params.scancount=ceil(af.params.zrange/af.params.zstep+1);
        set(handles.scanCountText, 'String', af.params.scancount);
    else set(handles.scanCountText, 'String', 'Z step and range must be numbers');
    end
end
% Hints: get(hObject,'String') returns contents of zrangeEdit as text
%        str2double(get(hObject,'String')) returns contents of zrangeEdit as a double


% --- Executes during object creation, after setting all properties.
function zrangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zrangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',num2str(af.params.zrange));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zstepEdit_Callback(hObject, eventdata, handles)
% hObject    handle to zstepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=str2double(get(hObject,'String'));
global af
% add z step to global autofocus parameters
af.params.zstep=str;
if isfield(af.params,'zrange')
    if isa(af.params.zstep,'double')==1 && isa(af.params.zrange,'double')==1 ...
            && isnan(af.params.zstep)==0 && isnan(af.params.zrange)==0
        af.params.scancount=ceil(af.params.zrange/af.params.zstep+1);
        set(handles.scanCountText, 'String', af.params.scancount);
    else set(handles.scanCountText, 'String', 'Z step and range must be numbers');
    end
end
% Hints: get(hObject,'String') returns contents of zstepEdit as text
%        str2double(get(hObject,'String')) returns contents of zstepEdit as a double


% --- Executes during object creation, after setting all properties.
function zstepEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zstepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',num2str(af.params.zstep));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function runFrequencyEdit_Callback(hObject, eventdata, handles)
% hObject    handle to runFrequencyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=str2double(get(hObject,'String'));
global af
% add z step to global autofocus parameters
af.params.frequency=str;
% Hints: get(hObject,'String') returns contents of runFrequencyEdit as text
%        str2double(get(hObject,'String')) returns contents of runFrequencyEdit as a double


% --- Executes during object creation, after setting all properties.
function runFrequencyEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runFrequencyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',num2str(af.params.frequency));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channelSelectPopupmenu.
function channelSelectPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to channelSelectPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.params.channel=get(hObject,'Value');

% Hints: contents = cellstr(get(hObject,'String')) returns channelSelectPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelSelectPopupmenu


% --- Executes during object creation, after setting all properties.
function channelSelectPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelSelectPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global state dia af
try % try to set channel picket to proper array count. if state variable isn't open yet, just set it to two as a default.
    channelarray=sprintf('Channel %d|',1:state.init.maximumNumberOfInputChannels);
    af.params.flimChannelIndex=state.init.maximumNumberOfInputChannels+1;
catch
    channelarray=sprintf('Channel %d|',1:2);
    af.params.flimChannelIndex=3;
end
channelarray=[channelarray,'FLIM'];
set(hObject,'String',channelarray);

try
    set(hObject,'Value',af.params.channel);
catch ME
    disp(ME.message);
end

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in singleDriftCorrectionCheckbox.
function singleDriftCorrectionCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to singleDriftCorrectionCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.drift.on=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of singleDriftCorrectionCheckbox


% --- Executes on button press in tuneDistPushbutton.
function tuneDistPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to tuneDistPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.statusGUI='Click on reproducible position';
afStatus(af.statusGUI);
tuneDist(); % run function to set spine
af.statusGUI='-';
afStatus(af.statusGUI);



function tuneDistEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tuneDistEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.drift.scale=str2double(get(hObject,'Value'));
% Hints: get(hObject,'String') returns contents of tuneDistEdit as text
%        str2double(get(hObject,'String')) returns contents of tuneDistEdit as a double


% --- Executes during object creation, after setting all properties.
function tuneDistEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tuneDistEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'String',af.drift.scale);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in testDriftCorrectPushbutton.
function testDriftCorrectPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to testDriftCorrectPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
driftCorrect('click');

% --- Executes on button press in setSpinePushbutton.
function setSpinePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setSpinePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.statusGUI='Click on spine of interest';
set(handles.statustext,'String',af.statusGUI);
set_spines(); % run function to set spine
af.statusGUI='-';
set(handles.statustext,'String',af.statusGUI);

% --- Executes on button press in testAfPushbutton.
function testAfPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to testAfPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
runDriftCorrect('LiveAutofocus',true);

% --- Executes on button press in afOnCheckbox.
function afOnCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to afOnCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.params.isAFon=get(hObject,'Value');
updateMdiaEnabled;
% Hint: get(hObject,'Value') returns toggle state of afOnCheckbox


% --- Executes on button press in acquiredForAutofocusCheckbox.
function acquiredForAutofocusCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to acquiredForAutofocusCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.params.useAcqForAF=get(hObject,'Value');
updateMdiaEnabled;
% Hint: get(hObject,'Value') returns toggle state of acquiredForAutofocusCheckbox


% --- Executes on button press in displayAfImagesCheckbox.
function displayAfImagesCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to displayAfImagesCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af
af.params.displaytoggle=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of displayAfImagesCheckbox


% --- Executes on button press in tuneThreshButton.
function tuneThreshButton_Callback(hObject, eventdata, handles)
% hObject    handle to tuneThreshButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
find_dendrites_slider_GUI;

% --- Executes during object creation, after setting all properties.
function scanCountText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanCountText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
if isfield(af.params, 'scancount')
    set(hObject,'String', num2str(af.params.scancount));
else
    set(hObject,'String', '-');
end


% --- Executes during object creation, after setting all properties.
function statustext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statustext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
if isfield(af,'statusGUI')
    set(hObject,'String',af.statusGUI);
else set(hObject,'String','-');
end


% --- Executes during object creation, after setting all properties.
function singleDriftCorrectionCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to singleDriftCorrectionCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.drift.on);


% --- Executes during object creation, after setting all properties.
function afOnCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to afOnCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.params.isAFon);


% --- Executes during object creation, after setting all properties.
function acquiredForAutofocusCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acquiredForAutofocusCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.params.useAcqForAF);


% --- Executes during object creation, after setting all properties.
function displayAfImagesCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayAfImagesCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global af
set(hObject,'Value',af.params.displaytoggle);


% --- Executes on button press in defineUncagingROIpushbutton.
function defineUncagingROIpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to defineUncagingROIpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.hPos.defineROI;
% defineROICallback;


% --- Executes on button press in startPushbutton.
function startPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state dia
dia.acq.grabAndTimeOn=0;
if ~state.files.autoSave
    errordlg('Save is turned off. Turn it on.');
    return
end
if strcmp(get(hObject,'String'),'Start')
    startButtonCallback;
else
    UA_Abort;
end

% --- Executes on button press in clearRoisPushbutton.
function clearRoisPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearRoisPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua gh dia
choice=questdlg('Clear ALL of your positions?','Confirm Clear ROIs','OK','Cancel','Cancel');
if strcmp(choice,'Cancel')
    return
end
dia.hPos = mdiaPositionClass;
dia.hPos.initialize;

% clear all ROIs in image
for i=1:length(gh.yphys.figure.yphys_roi)
    if ishandle(gh.yphys.figure.yphys_roi(i))
        a=findobj('Tag', num2str(i));
        if size(a) > 0
            for j = 1:size(a)
                delete(a(j));
            end
        end
        %         delete(a);
    end
end


gh.yphys.figure.yphys_roi=[];
gh.yphys.figure.yphys_roiText=[];
gh.yphys.figure.yphys_roi2=[];
gh.yphys.figure.yphys_roiText2=[];
gh.yphys.figure.yphys_roi3=[];
gh.yphys.figure.yphys_roiText3=[];

updateUAgui;


% --- Executes on button press in goToPushbutton.
function goToPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to goToPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GoToCallback;


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deleteROICallback;
updateUAgui;

% --- Executes on button press in refImgPushbutton.
function refImgPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to refImgPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UA_DriftCorrect;

% --- Executes on button press in updateXyzPushbutton.
function updateXyzPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to updateXyzPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateUAposition;


% --- Executes on button press in pageAcq_checkbox.
function pageAcq_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to pageAcq_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia ua gh state

value=get(hObject,'Value');
dia.acq.pageAcqOn=value;
% Hint: get(hObject,'Value') returns toggle state of pageAcq_checkbox


% --- Executes on button press in saveROIsPB.
function saveROIsPB_Callback(hObject, eventdata, handles)
% hObject    handle to saveROIsPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state ua dia

startPath=state.hSI.getLastPath('roiLastPath');
[fname, pname]=uiputfile({'*.roi'},'Choose ROI File...',startPath);
[~,fname,ext] = fileparts(fname);
if isempty(ext) || ~strcmpi(ext,'.roi')
    fprintf(2,'WARNING: Invalid file extension found. Cannot open ROI file.\n');
    return;
end
state.hSI.roiPath=pname;
state.hSI.roiName=fname;
state.hSI.roiSave();

if isfield(ua,'fov')
    fovInfo=ua.fov;
else
    fovInfo=[];
end
allPositionsDS = dia.hPos.allPositionsDS;
fovDS = dia.hPos.fovDS;
posXYZ_graph_offset=dia.hPos.posXYZ_graph_offset;
fpath=[pname,fname,'.mat'];
save(fpath,'allPositionsDS','fovDS','posXYZ_graph_offset','fovInfo');
% state.hSI.roiSaveAs();

% --- Executes on button press in loadRoisPB.
function loadRoisPB_Callback(hObject, eventdata, handles)
% hObject    handle to loadRoisPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state ua dia
choice=questdlg('Warning - Loading ROIs will clear all current ROIs','Confirm Load ROIs','OK','Cancel','Cancel');
if strcmp(choice,'Cancel')
    return
else
    state.hSI.roiLoad();
    startPath=state.hSI.roiPath;
    
    pause(.2);
    [fname, pname]=uigetfile({'*.mat'},'Choose MAT File...',startPath);
    
    fpath=[pname,fname];
    load(fpath);
    
    if ~isempty(fovInfo)
        ua.fov=fovInfo;
    end
    dia.hPos.allPositionsDS = allPositionsDS;
    dia.hPos.fovDS = fovDS;
    dia.hPos.posXYZ_graph_offset = posXYZ_graph_offset;
    updateUAgui;
end

function zRoofEdit_Callback(hObject, eventdata, handles)
% hObject    handle to zRoofEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zRoofEdit as text
%        str2double(get(hObject,'String')) returns contents of zRoofEdit as a double


% --- Executes during object creation, after setting all properties.
function zRoofEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zRoofEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua dia
if isfield(ua.params,'zRoof')
    set(hObject,'String',num2str(ua.params.zRoof));
end
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setGlobalZroofPushbutton.
function setGlobalZroofPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setGlobalZroofPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua state dia
ua.params.zRoof=state.motor.hMotor.positionAbsolute(3);
set(dia.handles.mdia.zRoofEdit,'String',num2str(ua.params.zRoof));
for i=1:length(dia.hPos.allPositionsDS.posID)
    updateUAposition(dia.hPos.allPositionsDS.posID(i),[],[],1);
end

% --- Executes on button press in groupByFovPushbutton.
function groupByFovPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to groupByFovPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
groupRoisByFOV;



function postUncageTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to postUncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.primaryTime=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of postUncageTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of postUncageTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function postUncageTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to postUncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.params.primaryTime));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function postUncageFrequencyEdit_Callback(hObject, eventdata, handles)
% hObject    handle to postUncageFrequencyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.primaryFreq=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of postUncageFrequencyEdit as text
%        str2double(get(hObject,'String')) returns contents of postUncageFrequencyEdit as a double


% --- Executes during object creation, after setting all properties.
function postUncageFrequencyEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to postUncageFrequencyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.params.primaryFreq));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pageAcq_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pageAcq_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% global ua dia
% if isfield(dia.acq,'pageAcqOn')
%     set(hObject,'Value',dia.acq.pageAcqOn);
% else
%     dia.acq.pageAcqOn=0;
%     set(hObject,'Value',dia.acq.pageAcqOn);
% end


% --- Executes when selected cell(s) is changed in SpineSelectUitable.
function SpineSelectUitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to SpineSelectUitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global ua dia
if numel(eventdata.Indices)>0 %check if something is selected
    selectedCell=eventdata.Indices;
    a=get(dia.handles.mdia.SpineSelectUitable,'data');
    ua.SelectedSpine=a(selectedCell(1),2);
    ua.SelectedPosition=cell2mat(a(selectedCell(1),1));
end



function preUncageTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to preUncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.preUncageTime=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of preUncageTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of preUncageTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function preUncageTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preUncageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.params.preUncageTime));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function preUncageFreqEdit_Callback(hObject, eventdata, handles)
% hObject    handle to preUncageFreqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.preUncageFreq=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of preUncageFreqEdit as text
%        str2double(get(hObject,'String')) returns contents of preUncageFreqEdit as a double


% --- Executes during object creation, after setting all properties.
function preUncageFreqEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preUncageFreqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.params.preUncageFreq));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes when selected object is changed in afModePanel.
function afModePanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in afModePanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global af
af.params.mode=get(eventdata.NewValue,'Tag');
updateMdiaEnabled;
updateUAgui( 'afmode' );


% --- Executes during object creation, after setting all properties.
function afModePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to afModePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in fovModeOnCheckbox.
function fovModeOnCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to fovModeOnCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua state gh
ua.params.fovModeOn=get(hObject,'Value');
updateUAgui;
if ~ua.params.fovModeOn
    state.acq.scanShiftSlow = 0;
    updateGUIByGlobal('state.acq.scanShiftSlow');
    state.acq.scanShiftFast = 0;
    updateGUIByGlobal('state.acq.scanShiftFast');
    setScanProps(gh.mainControls.zero);
    updateRSPs();
    disp('Scan Shift reset to 0');
end
% Hint: get(hObject,'Value') returns toggle state of fovModeOnCheckbox


% --- Executes during object creation, after setting all properties.
function fovModeOnCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fovModeOnCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'Value',ua.params.fovModeOn);


% --- Executes on button press in autoAddRefImgCheckbox.
function autoAddRefImgCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to autoAddRefImgCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.autoAddRefImg=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of autoAddRefImgCheckbox


% --- Executes during object creation, after setting all properties.
function autoAddRefImgCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoAddRefImgCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'Value',ua.params.autoAddRefImg);


% --- Executes during object creation, after setting all properties.
function tabPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tabPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function loadUipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to loadUipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadInifileAFUA;
mdia;
disp('Automation Settings Loaded');


% --------------------------------------------------------------------
function saveUipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to saveUipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveInifileAFUA;
disp('Saved Automation Settings.');
disp('Note - Position ROIs must be saved separately');


% --- Executes when selected object is changed in driftCorrectModePanel.
function driftCorrectModePanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in driftCorrectModePanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global af
af.drift.mode=get(eventdata.NewValue,'Tag');


% --- Executes on button press in setRefPushbutton.
function setRefPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setRefPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af ua

if isfield(af.drift,'Iref') && ~isempty(af.drift.Iref)
    hFig=figure;
    set(hFig,'MenuBar','none','Name','Current Reference Image','ToolBar','none');
    set(hFig,'ToolBar','none');
    imagesc(af.drift.Iref);
    colormap gray
    axis square off
    %     axis off
    choice=questdlg('Saved Reference Image Shown. Create new Reference Image?','Reset Reference?','OK','Cancel','Cancel');
    if strcmp(choice,'Cancel')
        return
    end
    close(hFig);
end
channel=af.params.channel;
if ua.drift.useMaxProjection
    Iref=updateCurrentImage(channel,2);
else
    Iref=updateCurrentImage(channel,1);
end
af.drift.Iref=Iref;
hFig=figure;
imagesc(Iref);
colormap gray
axis square off
set(hFig,'MenuBar','none','ToolBar','none','Name','New Reference Image');



function setZoomEdit_Callback(hObject, eventdata, handles)
% hObject    handle to setZoomEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.params.initialZoom=str2double(get(hObject,'String'));

% Hints: get(hObject,'String') returns contents of setZoomEdit as text
%        str2double(get(hObject,'String')) returns contents of setZoomEdit as a double


% --- Executes during object creation, after setting all properties.
function setZoomEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setZoomEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'String',num2str(ua.params.initialZoom));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useETLcheckbox.
function useETLcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to useETLcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: get(hObject,'Value') returns toggle state of useETLcheckbox


% --- Executes during object creation, after setting all properties.
function useETLcheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to useETLcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in setZlimitPushbutton.
function setZlimitPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setZlimitPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state dia af
af.params.motorZlimit=state.motor.hMotor.positionAbsolute(3); %for ETL
set(dia.handles.mdia.setZlimitEdit,'String',num2str(af.params.motorZlimit));


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


% --- Executes on button press in timeFOVGrabPushbutton.
function timeFOVGrabPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to timeFOVGrabPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia state gh
try
    set(hObject,'String','Timing...');
    dia.acq.grabAndTimeOn=1;
    dia.acq.numberOfZSlices=state.acq.numberOfZSlices;
    dia.acq.zStepSize=state.acq.zStepSize;
    dia.acq.allowTimerStart=true;
    
    dia.acq.returnHome=state.acq.returnHome;
    if dia.acq.returnHome %turn off 'Return Home' to speed up imaging
        disp('turning off ''Return Home'' to speed up multiposition imaging');
        set(gh.motorControls.cbReturnHome,'Value',0);
        genericCallback(gh.motorControls.cbReturnHome);
    end
    
    autoSave=false;
    disp('AutoFocus, Drift Correction, and AutoSave are turned off during Timing');
    if state.files.autoSave
        autoSave=true;
        set(gh.mainControls.cbAutoSave,'Value',0);
        genericCallback(gh.mainControls.cbAutoSave);
        preallocateMemory(true);
    end
    
    dia.hPos.setWorkingPositions;
    dia.hPos.makeImagingTimers(1);
    
    dia.acq.startTime=clock;
    ii=1;
    for i = dia.hPos.workingPositions'
        t(ii)=dia.hPos.imagingTimers([dia.hPos.imagingTimers.posID]==i).timer(1);
        ii=ii+1;
    end
    
    dia.acq.jobQueue=cell(2,0);
    
    start(t);
    pause(.1);
    % wait(t);
    % delete(t);
    
    dia.acq.jobQueueTimer = timer('TimerFcn',@jobQueuePicker,'ExecutionMode','fixedRate','busymode','drop','period',.1);
    setJobQueueTimer(1);
    
    waitfor(hObject,'String','Grab and Time Positions Once');
    
    %
    % if dia.acq.returnHome
    %     set(gh.motorControls.cbReturnHome,'Value',1);
    %     genericCallback(gh.motorControls.cbReturnHome);
    % end
    UA_Abort(1);
catch ME
    disp(getReport(ME));
    set(dia.handles.mdia.timeFOVGrabPushbutton,'String','Grab and Time Positions Once');
end

if autoSave
    set(gh.mainControls.cbAutoSave,'Value',1);
    genericCallback(gh.mainControls.cbAutoSave);
    preallocateMemory(true);
end

state.acq.numberOfZSlices=dia.acq.numberOfZSlices;
state.acq.zStepSize=dia.acq.zStepSize;
dia.acq.grabAndTimeOn=0;



% --- Executes on button press in setupTimingPB.
function setupTimingPB_Callback(hObject, eventdata, handles)
% hObject    handle to setupTimingPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% uncageStaggerUI;
timelineSetupGui;


% --- Executes on button press in useMaxProjectionForDriftCheckbox.
function useMaxProjectionForDriftCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to useMaxProjectionForDriftCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua
ua.drift.useMaxProjection=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of useMaxProjectionForDriftCheckbox


% --- Executes during object creation, after setting all properties.
function useMaxProjectionForDriftCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to useMaxProjectionForDriftCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ua
set(hObject,'Value',ua.drift.useMaxProjection);


% --- Executes on selection change in singlePositionPopupmenu.
function singlePositionPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to singlePositionPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns singlePositionPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from singlePositionPopupmenu


% --- Executes during object creation, after setting all properties.
function singlePositionPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to singlePositionPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in singlePosAfUaCheckbox.
function singlePosAfUaCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to singlePosAfUaCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.init.useOnePos=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of singlePosAfUaCheckbox


% --- Executes on button press in setSinglePositionPushbutton.
function setSinglePositionPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setSinglePositionPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia ua
dia.acq.refPosition=ua.SelectedPosition;
set(dia.handles.mdia.afDriftPosEdit,'String',num2str(dia.acq.refPosition));


function afDriftPosEdit_Callback(hObject, eventdata, handles)
% hObject    handle to afDriftPosEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of afDriftPosEdit as text
%        str2double(get(hObject,'String')) returns contents of afDriftPosEdit as a double


% --- Executes during object creation, after setting all properties.
function afDriftPosEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to afDriftPosEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function singlePosAfUaCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to singlePosAfUaCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'Value',dia.init.useOnePos);


% --- Executes on button press in pausePushButton.
function pausePushButton_Callback(hObject, eventdata, handles)
% hObject    handle to pausePushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ua dia gh
persistent t stopPositions
ps=get(hObject,'String');
if strcmp(ps,'Pause')
    dia.acq.pauseOn = 1;
    setJobQueueTimer(0);
    stopPositions = getWorkingTimers(0,1);
    pauseOrResumeTimers([],1,stopPositions);
elseif strcmp(ps,'Unpause')
    Lia = ismember(stopPositions,dia.hPos.workingPositions); %in case positions were deleted during pause
    stopPositions = stopPositions(Lia);
    
    pauseOrResumeTimers([],0,timerInd);
    
    %     c=[dia.hPos.imagingTimers.stepCountdown];
    %     c=c(ind);
    % %     update step counters
    %     for i=1:length(c)
    %         if c(i) > 0
    %             t(i).TasksToExecute = c(i);
    %         else %timers that are done will move on by themselves when the jobquetimer runs their stop function after the pause
    %             t(i)=[];
    %         end
    %     end
    if strcmp(get(gh.mainControls.focusButton,'String'),'ABORT');
        mainControls('focusButton_Callback',gh.mainControls.focusButton);
    end
    %     start(t);
    clear('stopPositions');
    
    dia.acq.pauseOn = false;
    setJobQueueTimer(1);
end
updateUAgui;


% --- Executes on button press in useEtlCheckbox.
function useEtlCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to useEtlCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.etl.acq.etlOn=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of useEtlCheckbox


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia state
dia.etl.acq.absZlimit=state.motor.lastPositionRead(3);
set(dia.handles.mdia.etlZLimitEdit,'String',num2str(dia.etl.acq.absZlimit));


function etlZLimitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to etlZLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etlZLimitEdit as text
%        str2double(get(hObject,'String')) returns contents of etlZLimitEdit as a double


% --- Executes during object creation, after setting all properties.
function etlZLimitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etlZLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.etl.acq.absZlimit));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etlRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to etlRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.etl.acq.autoRange=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of etlRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of etlRangeEdit as a double


% --- Executes during object creation, after setting all properties.
function etlRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etlRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.etl.acq.autoRange));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function useEtlCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to useEtlCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'Value',dia.etl.acq.etlOn);


% --- Executes on button press in loadETLguiPushbutton.
function loadETLguiPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadETLguiPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
etl3Dgui;


% --- Executes on button press in stacksOnlyETLCheckbox.
function stacksOnlyETLCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to stacksOnlyETLCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stacksOnlyETLCheckbox
global dia

dia.etl.acq.stackOnlyMode=get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function stacksOnlyETLCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stacksOnlyETLCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia

set(hObject,'Value',dia.etl.acq.stackOnlyMode);


% --- Executes during object creation, after setting all properties.
function driftCorrectModePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to driftCorrectModePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cellInfoGui;


% --------------------------------------------------------------------
function optionsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to optionsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveWindowPositionsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to saveWindowPositionsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=findall(0,'Type','Figure','Visible','On');
windowNames=get(handles,'Name');
allPositions=get(handles,'OuterPosition');
windowUnits=get(handles,'Units');
[fPath,~,~]=fileparts(mfilename('fullpath'));
save([fPath,'\inifile\windowPositions.mat'],'windowNames','allPositions','windowUnits');


% --------------------------------------------------------------------
function loadWindowPositionsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to loadWindowPositionsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fPath,~,~]=fileparts(mfilename('fullpath'));
hInfo=load([fPath,'\inifile\windowPositions.mat'],'windowNames','allPositions','windowUnits');
setWindowPositions(hInfo);


% --- Executes on button press in checkbox21.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox21



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox22.
function checkbox22_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox22



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox23.
function checkbox23_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox23


% --- Executes on button press in setRibbonPushbutton.
function setRibbonPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setRibbonPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia state af gui

if checkForRibbonSettings
    return
end
% I=getLastAcqImage(af.params.channel, 1);
if af.params.channel == af.params.flimChannelIndex
    ax=gui.spc.figure.projectAxes;
else
    ax=state.internal.axis(af.params.channel);
end

rbn_setRibbon(ax);
dia.acq.doRibbonTransform=1;
setupDAQDevices_ConfigSpecific;
setupAOData();


disp('Ribbon Created');



% --- Executes on button press in clearRibbonPushbutton.
function clearRibbonPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearRibbonPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
disp('Computing Ribbon...');

try
    dia.acq.ribbonMask=true(size(dia.acq.ribbonMask));
catch err
    disp(err.message);
    disp('Probably no ribbon present');
end
disp('Ribbon Cleared');
dia.acq.doRibbonTransform=0;
dia.acq.do3DRibbonTransform=0;
updateAcquisitionParameters;

setupDAQDevices_ConfigSpecific;
setupAOData();


% --------------------------------------------------------------------
function fovAlignmentMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fovAlignmentMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fovAlignment;


% --- Executes on button press in setLocalZroofPushbutton.
function setLocalZroofPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setLocalZroofPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateUAposition([],[],[],1);


% --------------------------------------------------------------------
function helpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to helpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function helpContentsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to helpContentsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open('Scanimage 3.8.1 Uncaging Automation Tutorial.html');


% --- Executes on button press in ribbonUpdatePushbutton.
function ribbonUpdatePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ribbonUpdatePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia state af gui
if checkForRibbonSettings
    return
end

disp('Computing Ribbon...');

dia.acq.doRibbonTransform=0;
setupDAQDevices_ConfigSpecific;
setupAOData();

if af.params.channel == af.params.flimChannelIndex
    ax=gui.spc.figure.projectAxes;
else
    ax=state.internal.axis(af.params.channel);
end

rbn_setRibbon(ax,dia.acq.ribbon.RelativeRibbonPoly);
dia.acq.doRibbonTransform=1;
setupDAQDevices_ConfigSpecific;
setupAOData();


disp('Ribbon Created');


% --- Executes on button press in set3DRibbonPushbutton.
function set3DRibbonPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to set3DRibbonPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global af dia gh state
if checkForRibbonSettings
    return
end

%set Z stack params
oldZslices=state.acq.numberOfZSlices;
oldZstepsPerSlice=state.acq.zStepSize;
stepsPerSlice=str2double(get(dia.handles.mdia.ribbonZstepEdit,'String'));
numSlices=ceil(str2double(get(dia.handles.mdia.ribbonZrangeEdit,'String'))/...
    stepsPerSlice+1);
setMotorSliceAndSteps(numSlices,stepsPerSlice);

disp('Computing Ribbon...');

if ~af.params.useAcqForAF || ~af.params.isAFon
    af.params.useAcqForAF=1;
    af.params.isAFon=1;
    disp('''Use Acquired for Autofocus'' set to ON');
end
rbn_set3DRibbon;
dia.acq.doRibbonTransform=1;
dia.acq.do3DRibbonTransform=1;
setupDAQDevices_ConfigSpecific;
setupAOData();

%set old Z params
setMotorSliceAndSteps(oldZslices,oldZstepsPerSlice);

disp('Ribbon Created');


% --- Executes on button press in update3DRibbonPushbutton.
function update3DRibbonPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to update3DRibbonPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia state af gui
if checkForRibbonSettings
    return
end

disp('Computing Ribbon...');
dia.acq.doRibbonTransform=0;
dia.acq.do3DRibbonTransform=0;
setupDAQDevices_ConfigSpecific;
setupAOData();

if af.params.channel == af.params.flimChannelIndex
    ax=gui.spc.figure.projectAxes;
else
    ax=state.internal.axis(af.params.channel);
end

rbn_set3DRibbon(ax,dia.acq.ribbon.RelativeRibbonPoly,dia.acq.ribbon.Zlist);
dia.acq.doRibbonTransform=1;
dia.acq.do3DRibbonTransform=1;
setupDAQDevices_ConfigSpecific;
setupAOData();


disp('Ribbon Created');

%checks to make sure settings for ribbon imaging are on
function err = checkForRibbonSettings
global state
if state.acq.bidirectionalScan && state.acq.disableStriping %...
    %         && mod(state.acq.inputRate/state.acq.outputRate,1)==0
    err = false;
else
    err = true;
    disp('Cannot do Ribbon Imaging. Turn on Bidirectional Scan (BiDi),');
    disp('Disable Image Striping, and make sure input rate is not 1.25');
end



function ribbonZstepEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ribbonZstepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ribbonZstepEdit as text
%        str2double(get(hObject,'String')) returns contents of ribbonZstepEdit as a double


% --- Executes during object creation, after setting all properties.
function ribbonZstepEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ribbonZstepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ribbonZrangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ribbonZrangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ribbonZrangeEdit as text
%        str2double(get(hObject,'String')) returns contents of ribbonZrangeEdit as a double


% --- Executes during object creation, after setting all properties.
function ribbonZrangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ribbonZrangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setMotorSliceAndSteps(numZslices,zStepsPerSlice)
global gh
set(gh.motorControls.etNumberOfZSlices,'String',num2str(numZslices));
set(gh.motorControls.etZStepPerSlice,'String',num2str(zStepsPerSlice));
motorControls('etNumberOfZSlices_Callback',gh.motorControls.etNumberOfZSlices);
motorControls('etZStepPerSlice_Callback',gh.motorControls.etZStepPerSlice);



function maxPositionsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxPositionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia ua
dia.acq.maxPositions = str2double(get(hObject,'String'));
if ~ua.UAmodeON
    dia.hPos.setWorkingPositions(1);
end
% Hints: get(hObject,'String') returns contents of maxPositionsEdit as text
%        str2double(get(hObject,'String')) returns contents of maxPositionsEdit as a double


% --- Executes during object creation, after setting all properties.
function maxPositionsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxPositionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
set(hObject,'String',num2str(dia.acq.maxPositions));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function scanDriftMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanDriftMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in checkbox29.
function checkbox29_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox29
global dia
dia.acq.ribbon.sineWave = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function checkbox29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
if ~isfield(dia.acq,'ribbon') || ~isfield(dia.acq.ribbon,'sineWave')
    dia.acq.ribbon.sineWave = false;
end
set(hObject,'Value',dia.acq.ribbon.sineWave);



function sineED_Callback(hObject, eventdata, handles)
% hObject    handle to sineED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.ribbon.sineWaveHz = str2double(get(hObject,'String'));
set(dia.handles.mdia.sineSL,'Value',dia.acq.ribbon.sineWaveHz);
% Hints: get(hObject,'String') returns contents of sineED as text
%        str2double(get(hObject,'String')) returns contents of sineED as a double


% --- Executes during object creation, after setting all properties.
function sineED_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sineED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
if ~isfield(dia.acq,'ribbon') || ~isfield(dia.acq.ribbon,'sineWaveHz')
    dia.acq.ribbon.sineWaveHz = 1000;
end

set(hObject,'String',num2str(dia.acq.ribbon.sineWaveHz));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sineSL_Callback(hObject, eventdata, handles)
% hObject    handle to sineSL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dia
dia.acq.ribbon.sineWaveHz = get(hObject,'Value');
set(dia.handles.mdia.sineED,'String',num2str(dia.acq.ribbon.sineWaveHz));
% set(dia.handles.mdia.sin
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sineSL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sineSL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dia
if isfield(dia.acq,'ribbon') && isfield(dia.acq.ribbon,'sineWaveHz')
    set(hObject,'Value',dia.acq.ribbon.sineWaveHz);
end
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
