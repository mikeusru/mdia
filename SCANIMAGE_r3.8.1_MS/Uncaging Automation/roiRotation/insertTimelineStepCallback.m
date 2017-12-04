function insertTimelineStepCallback(source,callbackdata)
global dia
ind = get(dia.handles.timelineGui.timelineUIT,'userdata');
ind = ind(1);
dia.test.source = source;
switch get(source,'Label')
    case 'Insert Step'
        dia.hPos.addTimelineStep(dia.handles.timelineGui,ind);
end
timelineSetupGui('resetTimelineGuiBoxes',dia.handles.timelineGui);
