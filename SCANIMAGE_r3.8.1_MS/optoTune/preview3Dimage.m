function preview3Dimage
%preview3Dimage creates a figure with a 3D plane showing how the image will
%be collected
global state dia

if ~isfield(dia,'etl') || ~isfield(dia.etl, 'acq') || ~isfield(dia.etl.acq,'voltageMin')
dia.etl.acq.voltageMin=0;
dia.etl.acq.voltageRange=0;
dia.etl.acq.fovSizeUm=240;
dia.etl.acq.voltToUm=-77;

end 

zBase=dia.etl.acq.voltageMin;
zRange=dia.etl.acq.voltageRange;
fovSizeum=dia.etl.acq.fovSizeUm;
%% need to calculate percent decrease for slow scan shift mirror... need to know FOV size for this.
 zRangeUm=abs(etlVoltToMotorZCalc(zRange+zBase)-etlVoltToMotorZCalc(zBase));
zBaseUm=etlVoltToMotorZCalc(zBase);
%% z^2 + y0^2 = y^2, so y0=sqrt(y^2-z^2)
z=zRangeUm;
y=fovSizeum/state.acq.zoomFactor;
if abs(z)>=y
    y0=0;
else
    y0=sqrt(y^2-z^2);
end
shiftScale=y0/y;
dia.etl.acq.mirrorSlowShiftScale=shiftScale;
%%

% axes(dia.handles.etl3Dgui.scanPlaneAxes);

if shiftScale~=0
    X=linspace(0,y,128);
    Y=linspace(0,y,128);
    visLine=NaN(128,1);
    visLine(1:round(128*shiftScale))=linspace(0,z,round(128*shiftScale))';
    visMat=repmat(visLine,1,128);
    Z=visMat;
    if etlVoltToMotorZCalc(.1)<0
        if abs(z)<(y+zBaseUm)
            zAx=[-y 0];
        else
            zAx=[-y+zBaseUm 0];
        end
    else
        if abs(z)<(y-zBaseUm)
            zAx=[0 y];
        else
            zAx=[0 y+zBaseUm];
        end
    end

else
    %if vertical imaging
    Y=zeros(1,128);
    X=linspace(0,y,128);
    Z=linspace(1,z,128)';
    Z=repmat(Z,1,128);
    if z<0
        zAx=[z+zBaseUm 0];
    else
        zAx=[0 z+zBaseUm];
    end
end

surf(dia.handles.etl3Dgui.scanPlaneAxes,X,Y,Z+zBaseUm,'EdgeAlpha',0);
axis(dia.handles.etl3Dgui.scanPlaneAxes,'equal');
rotate3d(dia.handles.etl3Dgui.scanPlaneAxes,'on'); %allow rotation of axes
zlim(dia.handles.etl3Dgui.scanPlaneAxes,zAx);
xlim(dia.handles.etl3Dgui.scanPlaneAxes,[0 y]);
ylim(dia.handles.etl3Dgui.scanPlaneAxes,[0 y]);
caxis(dia.handles.etl3Dgui.scanPlaneAxes,zAx);
set(dia.handles.etl3Dgui.scanPlaneAxes,'Ydir','reverse');
set(get(dia.handles.etl3Dgui.scanPlaneAxes,'XLabel'),'String','X');
set(get(dia.handles.etl3Dgui.scanPlaneAxes,'YLabel'),'String','Y');
set(get(dia.handles.etl3Dgui.scanPlaneAxes,'ZLabel'),'String','Z');
end

