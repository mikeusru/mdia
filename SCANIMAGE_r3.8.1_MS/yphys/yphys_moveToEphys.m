function yphys_moveToEphys(flag)
    global yphys

if flag == 1
   if isfield(yphys, 'filename')
        [pathstr,filenamestr,extstr] = fileparts(yphys.filename);
         num = str2num(filenamestr(end-2: end)) - 1;
         numchar = num2str(num);
            for i=1:3-length(numchar)
                numchar = ['0', numchar];
            end
			filenamestr = ['yphys', numchar];
	end
elseif flag == 2
	if isfield(yphys, 'filename')
        [pathstr,filenamestr,extstr] = fileparts(yphys.filename);
         num = str2num(filenamestr(end-2: end)) + 1;
         numchar = num2str(num);
            for i=1:3-length(numchar)
                numchar = ['0', numchar];
            end
			filenamestr = ['yphys', numchar];
	end

elseif flag == 3
	numchar = get(hObject, 'String');		
	if isfield(yphys, 'filename')
        [pathstr,filenamestr,extstr] = fileparts(yphys.filename);
            for i=1:3-length(numchar)
                numchar = ['0', numchar];
            end
			filenamestr = ['yphys', numchar];
	end

end

if exist([pathstr, '\', filenamestr, extstr])
    yphys_loadYphys([pathstr, '\', filenamestr, extstr]);
end