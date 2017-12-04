function grabAndWait
%grabAndWait performs Grab and waits until it is done by waiting for the
%'GRAB' button to show up again

global gh dia state

logActions;

mainControls('grabOneButton_Callback',gh.mainControls.grabOneButton);
try
    waitfor(gh.mainControls.grabOneButton,'String','GRAB'); %wait until grab is complete
catch ME
    disp('Warning - waiting for grab didn''t work correctly');
    disp(ME.message);
end
end

