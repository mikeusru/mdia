function afStatus(status)
%AFSTATUS is just a function to set the status message in the AF GUI. the
%input should be a string.
%   Detailed explanation goes here
global dia
set(dia.handles.mdia.statustext,'String',status);

end

