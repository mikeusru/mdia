function mdiaSelectPanel
%mdiaSelectPanel Sets all the appropriate GUI items for the visible part of
%the GUI

global dia

if isfield(dia.guiStuff,'panelSelection')
    switch dia.guiStuff.panelSelection
        case 'focusDriftToggle'
            %set singlepanel to main
            set(dia.handles.mdia.singlePositionPanel,'Visible','on','Position',dia.guiStuff.panelPos);
            set(dia.handles.mdia.multiPositionPanel,'Visible','off');
            set(dia.handles.mdia.ribbonUipanel,'Visible','off');
            
        case 'multiPositionToggle'
            %set multipanel to main
            set(dia.handles.mdia.singlePositionPanel,'Visible','off');
            set(dia.handles.mdia.ribbonUipanel,'Visible','off');
            set(dia.handles.mdia.multiPositionPanel,'Visible','on','Position',dia.guiStuff.panelPos);
        case 'ribbonImagingToggle'
            %set ribbonpanel to main
            set(dia.handles.mdia.singlePositionPanel,'Visible','off');
            set(dia.handles.mdia.multiPositionPanel,'Visible','off');
            set(dia.handles.mdia.ribbonUipanel,'Visible','on','Position',dia.guiStuff.panelPos);
    end
end

end

