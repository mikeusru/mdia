function [ output_args ] = tuneEtlToZmotor( zStep, zRange, useDrift, k )
%tuneEtlToZmotor should be used to figure out the ETL's Z range and
%corresponding motor Z values. With every motor Z step, the ETL will move
%and autofocus along with the motor.
%
% zStep is the step at which each frame will be collected
% zRange represents the entire motor Z range which will be measured
% useDrift will use scan angle drift correction to keep the image aligned
% with the center image
%
% k is the initial volt:micron constant which the program will use to
% identify the first positions. it will be updated once data is collected

global state dia af gh

if ~exist('polyfit0','file')
    disp('Error - polyfit0 function is required');
    return
end
[fName,pName]=uiputfile('image.tif','Save Image');

[motorPosnAbsolute,posnRelative] = motorGetPosition();
posnAbsolute=motorPosnAbsolute;
posnAbsolute(3)=motorPosnAbsolute(3)+etlVoltToMotorZCalc;

dsNames={'absMotorZ','relMotorZ','etlVoltage','Image'};
ds=cell2dataset([dsNames; motorPosnAbsolute(3), posnRelative(3), 0, {'12421'}]);
% ds.absMotorZ(1)=motorPosnAbsolute(3);
% ds.relMotorZ(1)=posnRelative(3);
% ds.etlVoltage(1)=0;
ds1=ds;
dia.etl.acq.absZlimit=posnAbsolute(3);
ds.Image{1}=updateCurrentImage(1,2);

for i=1:floor(zRange/zStep)
%     ds1.absMotorZ(1)=ds1.absMotorZ(1)-zStep;

    motorSetPositionAbsolute([motorPosnAbsolute(1),motorPosnAbsolute(2),ds1.absMotorZ(1)-zStep],'verify'); %move motor to new position
    ds1.absMotorZ(1)=state.motor.absZPosition;
    dia.etl.acq.absZlimit=state.motor.absZPosition; %update etl abs z limit to current motor position
    listAbsZ=linspace((motorPosnAbsolute(3)-(af.params.zrange/2)),(motorPosnAbsolute(3)+(af.params.zrange/2)),af.params.scancount);
    if listAbsZ(1)<state.motor.absZPosition
        motorOrETLMove([motorPosnAbsolute(1),motorPosnAbsolute(2),motorPosnAbsolute(3)+af.params.zrange/2]);
    else
        motorOrETLMove(motorPosnAbsolute); %move to original motor position using ETL
    end
    %autofocus 
    run_AF('test');
    %record values
    motorPosnAbsolute(3)=af.bestFocusAbsZ; %update motor position value to go to next time... this is to deal with offset mistakes.
    ds1.etlVoltage(1)=dia.etl.acq.voltageMin;
    ds1.relMotorZ(1)=state.motor.relZPosition;
    ds1.Image{1}=updateCurrentImage(1,2);
    ds=[ds;ds1];
end
dia.etl.measuredValues.tuneMeasurements=ds;

figure;
y=ds.relMotorZ;
x=ds.etlVoltage;
p=polyfit0(x,y,1);
p=[p,0];
f=polyval(p,x);
plot(x,y,'o',x,f,'-');
% scatter(x,y);
set(get(gca,'YLabel'),'String','Motor Z');
set(get(gca,'XLabel'),'String','ETL Voltage');
txt=['Slope = ' num2str(p(1))];
text(.2,.95,txt,'parent',gca, ...
    'verticalalignment','top','units','normalized');
dia.etl.measuredValues.trendLine=p;

%% Save Images and Data

A=uint16(zeros(size(ds.Image{1})));
A(:,:,1)=uint16(ds.Image{1});
imwrite(A,[pName,fName],'tif','WriteMode','overwrite');
for i=2:length(ds)
%     dirPath=uigetdir('C:\Users\yasudalab\Documents\data');
    A(:,:,i)=uint16(ds.Image{i});
    imwrite(A(:,:,i),[pName,fName],'tif','WriteMode','append');
end
ds2=ds;
ds2.Image=[];
export(ds2,'file',[pName,fName(1:end-4),'Data.txt']);


