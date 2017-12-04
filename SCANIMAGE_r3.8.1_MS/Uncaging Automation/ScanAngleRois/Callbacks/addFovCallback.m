function [ output_args ] = addFovCallback( input_args )
%addFovCallback is called when the button "add FOV" is pushed
global ua

fovwidth=ua.fov.fovwidth;
fovheight=ua.fov.fovheight;
ha=ua.fov.handles.axes1;
pos=[mean(xlim(ha))-fovwidth/2,mean(ylim(ha))-fovwidth/2,fovwidth,fovheight];

fov=imrect(ha,pos);
setResizable(fov,0);
setColor(fov,'r');

fcn = makeConstrainToRectFcn('imrect',get(ha,'XLim'),get(ha,'YLim'));
setPositionConstraintFcn(fov,fcn);

if isfield(ua.fov.handles,'fov') && isvalid(ua.fov.handles.fov(1))
    ua.fov.handles.fov(end+1,:)=fov;
else
    ua.fov.handles.fov(1)=fov;
end
end

