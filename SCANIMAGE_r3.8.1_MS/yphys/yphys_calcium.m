function Aout = yphys_calcium(num)
global state;
global yphys;
global gh;


color_a = {'green', 'red', 'white', 'cyan', 'magenta'};
%fh = 402;

roiobj = findobj('Tag', 'ROI');

nRoi = length(roiobj);

if ~nargin
    num = state.files.fileCounter-1;
end

if num < 1
    num = 1
end

str1 = '000';
str2 = num2str(num);
str1(end-length(str2)+1:end) = str2;

filename = [state.files.savePath, state.files.baseName, str1, '.tif'];

yphys.image.filename = filename;
yphys.image.currentImage = num;


try
    if exist(filename)
        [data,header]=genericOpenTif(filename);
        str1 = num2str(num);
        PathName = state.files.savePath;
        FileName = [state.files.baseName, str1, '.tif'];
        
    else
        disp(['*ERROR* No file:' filename]);
        [FileName, PathName] = uigetfile('*.tif');
        if ~isfield(state, 'acq')
            state.files.savePath = PathName;
            state.files.baseName = FileName(1:end-7);
        end
        %str1 = FileName(end-10:end-8);
        str1 = FileName(end-6:end-4);
        num = str2num(str1);
        filename = [PathName, FileName(1:end-7), str1, '.tif']
        [data,header]=genericOpenTif(filename);
    end
catch
        disp(['*ERROR* No file:' filename]);
        [FileName, PathName] = uigetfile('*.tif');
        if ~isfield(state, 'acq')
            state.files.savePath = PathName;
            state.files.baseName = FileName(1:end-7);
        end
        str1 = FileName(end-10:end-8);
        num = str2num(str1);
        filename = [PathName, FileName(1:end-7), str1, '.tif']
        [data,header]=genericOpenTif(filename);    
end

yphys.image.imageData = data;
yphys.image.imageHeader = header;
yphys.image.baseName = FileName(1:end-7);

if isfield(yphys.image, 'pathstr')
	if ~strcmp(yphys.image.pathstr, [PathName, 'spc'])
        yphys.image.pathstr = [PathName, 'spc'];
        yphys.image.intensity = {};
	end
else
    yphys.image.pathstr = [PathName, 'spc'];
end

yphys_calcium_offLine(1);

%return;