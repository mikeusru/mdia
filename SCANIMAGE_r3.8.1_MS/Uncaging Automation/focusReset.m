function [ output_args ] = focusReset( input_args )
%focusReset briefly turns on the focus. this is a workaround to make sure
%certain settings register and various bugs are avoided.
global gh

if strcmp(get(gh.mainControls.focusButton,'String'),'FOCUS')
    mainControls('focusButton_Callback',gh.mainControls.focusButton);
end
try
    waitfor(gh.mainControls.focusButton,'String','ABORT');
catch ME
    disp('Warning - frame may not have been acquired correctly since mainControls focus button cannot be read');
    disp(ME.message);
end
if strcmp(get(gh.mainControls.focusButton,'String'),'ABORT')
    mainControls('focusButton_Callback',gh.mainControls.focusButton);
end

end

