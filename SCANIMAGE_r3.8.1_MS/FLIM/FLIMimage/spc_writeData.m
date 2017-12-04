function spc_writeData(quickHeader)
%%
% quickHeader = 1: use quick header (use only for page!)


    global state
    
    if nargin
        quickHeader = 0;
    end
    
    fileName = [state.files.fullFileName '.tif'];
    [pathstr,name,ext] = fileparts(fileName);
    
    if exist([pathstr, '\spc']) ~= 7
        mkdir (pathstr, '\spc');
    end
    spc_filename = [pathstr, '\spc\', name, '.tif']; 
    
    state.spc.files.fullFileName = spc_filename;
    state.spc.files.maxfullFileName = [pathstr, '\spc\', name, '_max.tif'];
        
    if state.internal.zSliceCounter == 1 || state.internal.usePage % if its the first frame of first channel, then overwrite...
        spc_saveAsTiff(spc_filename, 0, 1+quickHeader);  %spc_saveAsTiff: filename, append, new header)
	else
        spc_saveAsTiff(spc_filename, 1, 0);
    end	
    
    
    
