function varargout = scanimageInstaller(varargin)
% SCANIMAGEINSTALLER MATLAB code for scanimageInstaller.fig
%      SCANIMAGEINSTALLER, by itself, creates a new SCANIMAGEINSTALLER or raises the existing
%      singleton*.
%
%      H = SCANIMAGEINSTALLER returns the handle to a new SCANIMAGEINSTALLER or the handle to
%      the existing singleton*.
%
%      SCANIMAGEINSTALLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCANIMAGEINSTALLER.M with the given input arguments.
%
%      SCANIMAGEINSTALLER('Property','Value',...) creates a new SCANIMAGEINSTALLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scanimageInstaller_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scanimageInstaller_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scanimageInstaller

% Last Modified by GUIDE v2.5 05-Jul-2017 15:47:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scanimageInstaller_OpeningFcn, ...
                   'gui_OutputFcn',  @scanimageInstaller_OutputFcn, ...
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


% --- Executes just before scanimageInstaller is made visible.
function scanimageInstaller_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scanimageInstaller (see VARARGIN)

% Choose default command line output for scanimageInstaller
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global installer
installer.handles = handles;

% UIWAIT makes scanimageInstaller wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = scanimageInstaller_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in destinationPB.
function destinationPB_Callback(hObject, eventdata, handles)
% hObject    handle to destinationPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = uigetdir();
p = fullfile(p,'SCANIMAGE_r3.8.2');
set(handles.destinationED,'String',p);

% --- Executes on button press in sourcePB.
function sourcePB_Callback(hObject, eventdata, handles)
% hObject    handle to sourcePB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folderOrigin = uigetdir();
set(handles.sourceED,'String',folderOrigin);

% --- Executes on button press in lastverPB.
function lastverPB_Callback(hObject, eventdata, handles)
% hObject    handle to lastverPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = uigetdir();
set(handles.lastverED,'String',p);


function destinationED_Callback(hObject, eventdata, handles)
% hObject    handle to destinationED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destinationED as text
%        str2double(get(hObject,'String')) returns contents of destinationED as a double


% --- Executes during object creation, after setting all properties.
function destinationED_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destinationED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sourceED_Callback(hObject, eventdata, handles)
% hObject    handle to sourceED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sourceED as text
%        str2double(get(hObject,'String')) returns contents of sourceED as a double


% --- Executes during object creation, after setting all properties.
function sourceED_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sourceED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
[pname,~,~] = fileparts(mfilename('fullpath'));
set(hObject,'String',pname);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lastverED_Callback(hObject, eventdata, handles)
% hObject    handle to lastverED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lastverED as text
%        str2double(get(hObject,'String')) returns contents of lastverED as a double


% --- Executes during object creation, after setting all properties.
function lastverED_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastverED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fileList = getAllFiles(dirName,verbose)
%list all files in all subdirectories of dirName
%verbose (optional) shows which files are currently being indexed
if nargin<2
    verbose=false;
end

  dirData = dir(dirName);      % Get the data for the current directory
  dirIndex = [dirData.isdir];  % Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  % Prepend path to files
                       fileList,'UniformOutput',false);
  end
  subDirs = {dirData(dirIndex).name};  % Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  % Find index of subdirectories
                                               %   that are not '.' or '..'
  for iDir = find(validIndex)                  % Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    % Get the subdirectory path
    if verbose
        disp(nextDir);
    end
    fileList = [fileList; getAllFiles(nextDir,verbose)];  % Recursively call getAllFiles
  end


% --- Executes on button press in installPB.
function installPB_Callback(hObject, eventdata, handles)
% hObject    handle to installPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pSource = get(handles.sourceED,'String');
pDestination = get(handles.destinationED,'String');
pLastVer = get(handles.lastverED,'String');

if strcmp(pDestination,pLastVer)
    errordlg('Warning: destination directory and previous version directory cannot be the same. Rename previous version directory.');
    return
end

if isdir(pDestination)
    errordlg('Warning: destination directory already exists. Remove directory and try again');
    return
end

%create destination file list
fileListSource = getAllFiles(pSource);
fileDestinationList = cellfun(@(x) strrep(x,pSource,pDestination),...
    fileListSource,'UniformOutput',false);
copyOrDeleteFilesFromList(fileListSource,fileDestinationList,'copy');


if get(handles.keepFilesCB,'Value')
    fileListLastVer = getAllFiles(pLastVer);
    iniFiles={...
    'internal.ini';...
    'standard_model.ini';...
    'defaults.ini';...
    'standard_user.usr';...
%     'flim_ini.m';...
    'spcm_ry.ini';...
    'spc_init.mat';...
    'yphys_init.mat';...
    };
    iniFilePaths = {};
    for i=1:length(iniFiles)
        ind=find(~cellfun(@isempty,strfind(fileListLastVer,iniFiles{i})));
        if ~isempty(ind)
            for j=1:length(ind)
                disp(['Using ', fileListLastVer{ind(j)}]);
                iniFilePaths = [iniFilePaths;fileListLastVer{ind(j)}];
            end
            
        end
    end
    iniFileDestinationList = cellfun(@(x) strrep(x,pLastVer,pDestination),...
    iniFilePaths,'UniformOutput',false);
    copyOrDeleteFilesFromList(iniFilePaths,iniFileDestinationList,'copy');
end

setup_ini.cardType = get(get(handles.flimCardBG,'SelectedObject'),'String');
setupFile = fullfile(pDestination,'setup_ini.mat');
save(setupFile,'-struct','setup_ini');

msgbox('Installation Complete!','Installation Complete');

%make sure standard_usr.usr file directories are correct
susrFile = fullfile(pDestination,'Scanimage\init_files','standard_usr.usr');
fin = fopen(susrFile);
fout = fopen('standard_usr_temp.usr','wt');

expression = 'C:\\.*?SCANIMAGE.*?\\';
replace = [regexprep(pDestination,'\\','\\\\'),'\\'];
while ~feof(fin)
   s = fgetl(fin);
   line = regexprep(s,expression,replace);
   fprintf(fout,'%s\n',line);
end
fclose(fin);
fclose(fout);
copyfile('standard_usr_temp.usr',susrFile,'f');
delete('standard_usr_temp.usr');

function copyOrDeleteFilesFromList(fileList,fileTargetList,copyOrDelete)
switch copyOrDelete
    case 'backup'
        waitBarName = 'Backing Up Files...';
        justDoCopy = true;
    case 'copy'
        waitBarName = 'Copying Files...';
        justDoCopy = true;
    case 'delete'
        waitBarName = 'Deleting Files...';
        justDoCopy = false;
        fileTargetList = fileList;
end

%% copy files
h=waitbar(0,'...','Name',waitBarName,'CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');
maxbar=length(fileList);
for i=1:maxbar
    %check cancel button press
    if getappdata(h,'canceling')
        break
    end
    % Report current file being copied
    [folderName,fileName,ext]=fileparts(fileTargetList{i});
    if justDoCopy && ~exist(folderName,'dir')
        mkdir(folderName)
    end
    waitbar(i/maxbar,h,[fileName,ext]);
    if justDoCopy
        % copy the file
        [status,message] = copyfile(fileList{i},folderName,'f');
        if ~status
            disp(message)
            return
        end
    else
        delete(fileList{i});
    end
end
delete(h)       % DELETE the waitbar; don't try to CLOSE it.


% --- Executes on button press in keepFilesCB.
function keepFilesCB_Callback(hObject, eventdata, handles)
% hObject    handle to keepFilesCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keepFilesCB
