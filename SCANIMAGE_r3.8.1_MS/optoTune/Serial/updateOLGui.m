function [ output_args ] = updateOLGui( input_args )
%updateOptGui updates the values in the optLensGui. this is useful for
%changing current limits and stuff.

global dia



set(dia.handles.optLens.maxCurrentEdit,'String',num2str(dia.hOL.maxOutputCurrent));
set(dia.handles.optLens.lowSoftwareLimitEdit,'String',num2str(dia.hOL.lowerSoftwareCurrentLimit));
set(dia.handles.optLens.upperSoftwareLimitEdit,'String',num2str(dia.hOL.upperSoftwareCurrentLimit));

%if current is out of bounds, reset it
if dia.hOL.current>dia.hOL.upperSoftwareCurrentLimit ...
        || dia.hOL.current<dia.hOL.lowerSoftwareCurrentLimit
    dia.hOL.setCurrent(0);
end
pos=dia.guiStuff.optLensPanelPos;
if dia.hOL.currentMode==1
    %Current Control Mode
    set(dia.handles.optLens.currentUipanel4,'Visible','On','Position',pos);
    set(dia.handles.optLens.freqControlUipanel,'Visible','Off');

  
    
    set(dia.handles.optLens.currentSlider,'Value',dia.hOL.current);
    set(dia.handles.optLens.currentEdit,'String',num2str(dia.hOL.current));
    set(dia.handles.optLens.currentSlider,'Max',dia.hOL.upperSoftwareCurrentLimit);
    set(dia.handles.optLens.currentSlider,'Min',dia.hOL.lowerSoftwareCurrentLimit);
else %triangular, rectangular, or sinusoidal modes
    set(dia.handles.optLens.currentUipanel4,'Visible','Off');
    set(dia.handles.optLens.freqControlUipanel,'Visible','On','Position',pos);
    
    
    set(dia.handles.optLens.lowSwingSlider,'Max',dia.hOL.upperSoftwareCurrentLimit);
    set(dia.handles.optLens.lowSwingSlider,'Min',dia.hOL.lowerSoftwareCurrentLimit);
    set(dia.handles.optLens.upSwingSlider,'Max',dia.hOL.upperSoftwareCurrentLimit);
    set(dia.handles.optLens.upSwingSlider,'Min',dia.hOL.lowerSoftwareCurrentLimit);
    set(dia.handles.optLens.freqSlider,'Value',dia.hOL.frequency);
    set(dia.handles.optLens.freqEdit,'String',num2str(dia.hOL.frequency));
    set(dia.handles.optLens.lowSwingSlider,'Value',dia.hOL.lowSwing);
    set(dia.handles.optLens.lowSwingEdit,'String',num2str(dia.hOL.lowSwing));
    set(dia.handles.optLens.upSwingSlider,'Value',dia.hOL.upSwing);
    set(dia.handles.optLens.upSwingEdit,'String',num2str(dia.hOL.upSwing));
end

switch dia.hOL.optLens.Status
    case 'closed'
        set(dia.handles.optLens.connectPushbutton,'String','Connect');
    case 'open'
        set(dia.handles.optLens.connectPushbutton,'String','Disconnect');
end



end

