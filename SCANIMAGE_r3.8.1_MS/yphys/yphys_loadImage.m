function yphys_loadImage
global yphys;

fh = 402;
global yphys
global gh

[fname,pname] = uigetfile('*_intensity.mat','Select ***_intensity');
cd (pname);
filestr = [pname, fname];

[pathstr,filenamestr,extstr] = fileparts(filestr);
load(filestr);

evalc(['yphys.image.intensity =', filenamestr]);

pos = findstr(filenamestr, '_intensity');
baseName = filenamestr(1:pos-1);

yphys.image.currentImage = length(yphys.image.intensity);
yphys.image.baseName = baseName;
yphys.image.pathstr = pname;

'aaa'
yphys_loadYphys;
