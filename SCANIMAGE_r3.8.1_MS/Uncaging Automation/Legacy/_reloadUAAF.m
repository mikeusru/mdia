function reloadUAAF
%reloadUAAF reloads the AF and UA GUIs
global af ua
%close the currently open windows
if ishandle(ua.handles.figure1)
    close(ua.handles.figure1)
end

if ishandle(af.handles_afGUI.figure1)
    close(af.handles_afGUI.figure1);
end

% open figures

UA;
afGUI;

end

