function [ output_args ] = groupRoisByFOV( input_args )
%calcCloseRois will take the positions which were defined using the stage,
%figure out which ones are close to eachother, and align them appropriately into the scan angle ROI system
global ua state

% clear any previous handles (necessary if reset is being called)
if isfield(ua,'fov') && isfield(ua.fov,'handles')
    if  isfield(ua.fov.handles,'fov') && ishandle(ua.fov.handles.fov(1))
        delete(ua.fov.handles.fov);
    end
    
    if isfield(ua.fov.handles,'fovFixed')
        for i=1:length(ua.fov.handles.fovFixed)
            if ishandle(ua.fov.handles.fovFixed(i))
                delete(ua.fov.handles.fovFixed(i));
            end
        end
    end
end
FOVgui;
showSelectFigure; %show a figure where the user can select ROIs

end

