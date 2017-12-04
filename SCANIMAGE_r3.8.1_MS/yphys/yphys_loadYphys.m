function yphys_loadYphys (filestr)
global yphys
global gh

if ~nargin
     pwdstr = pwd;
     if ~strcmp(pwdstr(end-2:end), 'spc')
         pwdstr = [pwdstr, '\spc'];
     end
     filenames=dir([pwd, '\yphys*']);
     b=struct2cell(filenames);
     [sorted, whichfile] = sort(datenum(b(2, :)));
     if prod(size(filenames)) ~= 0
		  newest = whichfile(end);
		  filename = filenames(newest).name;
          filestr = [pwd, '\', filename];
     end
end

if ~isstr(filestr)
     pwdstr = pwd;
     if ~strcmp(pwdstr(end-2:end), 'spc')
         pwdstr = [pwdstr, '\spc'];
     end
     filename1='yphys000';
     num = num2str(filestr);
     filename1(end-length(num)+1:end) = num;
     filestr = [pwd, '\', filename1, '.mat'];
end

if exist(filestr) == 2
	load(filestr);
	
	yphys.filename = filestr;
	[pathstr,filenamestr,extstr] = fileparts(filestr);
	evalc(['yphys.data = ', filenamestr]);
    
  
	num = str2num(filenamestr(end-2: end));
	nstr = num2str(num);
	set(gh.yphys.stimScope.fileN, 'String', nstr);
	
    yphys_dispEphys;
end