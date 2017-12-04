function [ ds2,bestFitData,A ] = getPSFmeasurements( zStep, zRange, useDrift, randomZ, resetZ0Motor, autoFocus,grabCount )
%tuneEtlToZmotor should be used to figure out the ETL's Z range and
%corresponding motor Z values. With every motor Z step, the ETL will move
%and autofocus along with the motor.
%
% zStep is the step at which each frame will be collected
% zRange represents the entire motor Z range which will be measured
% useDrift will use scan angle drift correction to keep the image aligned
% with the center image
%
% randomZ identifies whether the Z motor should step sequentially (false, default) or
% randomly (true).
%
% resetZ0Motor indicates whether the motor position at which Z=0 should be
% checked every 10 aquisitions (false by default)
%
% autoFocus (optional) is on by default. turn it off if collecting
% measurements for FOV size



global state dia af gh testStruct

genericCallback(gh.mainControls.baseName);



if ~exist('polyfit0','file')
    disp('Error - polyfit0 function is required');
    return
end

if dia.etl.acq.autoRange<zRange
    disp('Error - Auto ETL Range too low');
    return
end

if nargin<7
    grabCount=1;
end

if nargin<6
    autoFocus=1;
end

if nargin<5
    resetZ0Motor=false;
end

if nargin<4
    randomZ=false;
end

if nargin<3
    useDrift=false;
end

if useDrift
    Iref=af.drift.Iref;
    imSize=[state.acq.pixelsPerLine,state.acq.linesPerFrame];
end

[motorPosnAbsolute,posnRelative] = motorGetPosition();
posnAbsolute=motorPosnAbsolute;
% posnAbsolute(3)=motorPosnAbsolute(3)+etlVoltToMotorZCalc;

[fName,pName]=uiputfile([state.files.savePath, '\image.tif'],'Save Image');

FS=stoploop('Click OK to Stop ETL Measurements');

dsNames={'absMotorZ','relMotorZ','etlVoltage','Image','maxImageIntensity','MirrorDataOutput'};
ds=cell2dataset([dsNames; motorPosnAbsolute(3), posnRelative(3), 0, {'12421'},0,{''}]);
% ds.absMotorZ(1)=motorPosnAbsolute(3);
% ds.relMotorZ(1)=posnRelative(3);
% ds.etlVoltage(1)=0;
ds1=ds;
dia.etl.acq.absZlimit=posnAbsolute(3);
baseImgFname=state.files.baseName;
dia.etl.acq.etlOn=0;
state.files.baseName=genvarname([baseImgFname,'_Zoffset_','0','_']);
for k=1:grabCount
    Igrab=updateCurrentImage(1,2,1);
end
% testStruct.Igrab=Igrab;
ds.Image{1}=Igrab;
ds.MirrorDataOutput{1}=state.acq.mirrorDataOutput;
% testStruct.ds=ds;
ds.maxImageIntensity(1)=max(max(ds.Image{1}));
dia.etl.acq.etlOn=1;

if randomZ
    relPosZlist=linspace(posnRelative(3),posnRelative(3)-zRange,zRange/zStep);
end

if FS.Stop()
    return
end

for i=1:floor(zRange/zStep)
    %     ds1.absMotorZ(1)=ds1.absMotorZ(1)-zStep;
    drawnow();
    if FS.Stop()
        return
    end
    try
        if resetZ0Motor
            if i>=10 && ~mod(i,10) %run every 10 rounds
                motorSetPositionAbsolute([motorPosnAbsolute(1),motorPosnAbsolute(2),posnAbsolute(3)],'verify');
                k=1;
                while abs(state.motor.absZPosition-posnAbsolute(3))>.3 && k<5 %if position is not reached try again up to 5 times
                    motorSetPositionAbsolute([motorPosnAbsolute(1),motorPosnAbsolute(2),posnAbsolute(3)],'verify');
                    k=k+1;
                    if FS.Stop()
                        return
                    end
                end
                motorOrETLMove(posnAbsolute);
                dia.etl.acq.etlOn=0;
                if autoFocus
                    runDriftCorrect('LowResolution',true,'LiveAutofocus',true,'ShiftZPosition',true); %run autofocus and move to new Z position
                end
                motorSetRelativeOrigin([0 0 1]); %set new relative Z origin
                [motorPosnAbsolute,posnRelative] = motorGetPosition(); %update Z origin
                posnAbsolute=motorPosnAbsolute;
                dia.etl.acq.etlOn=1;
                if FS.Stop()
                    return
                end
                
            end
        end
        
        if randomZ
            ind=randi(length(relPosZlist));
            zMotor=relPosZlist(ind);
            motorSetPositionRelative([posnRelative(1),posnRelative(2),zMotor],'verify');
            k=1;
            while abs(state.motor.relZPosition-zMotor)>.3 && k<5 %if position is not reached try again up to 5 times
                motorSetPositionRelative([posnRelative(1),posnRelative(2),zMotor],'verify');
                k=k+1;
                if FS.Stop()
                    return
                end
            end
            relPosZlist(ind)=[];
            if FS.Stop()
                return
            end
        else
            motorSetPositionAbsolute([motorPosnAbsolute(1),motorPosnAbsolute(2),ds1.absMotorZ(1)-zStep],'verify'); %move motor to new position
        end
        ds1.absMotorZ(1)=state.motor.absZPosition;
        dia.etl.acq.absZlimit=state.motor.absZPosition; %update etl abs z limit to current motor position
        listAbsZ=linspace((motorPosnAbsolute(3)-(af.params.zrange/2)),(motorPosnAbsolute(3)+(af.params.zrange/2)),af.params.scancount);
        if listAbsZ(1)<state.motor.absZPosition
            motorOrETLMove([motorPosnAbsolute(1),motorPosnAbsolute(2),motorPosnAbsolute(3)+af.params.zrange/2]);
        else
            motorOrETLMove(motorPosnAbsolute); %move to original motor position using ETL
        end
        %autofocus
        if FS.Stop()
            return
        end
        if useDrift
%             I=af.bestFocusedImage;
            I = getLastAcqImage( af.params.channel,1 );
            [ shiftx, shifty ] = computeDrift(Iref,I);
            pos=[imSize(1)/2-shiftx, imSize(2)/2-shifty, 0, 0];
            [ssF, ssS, ~, ~, ~, ~]=scanShiftCalc(pos, state.acq.zoomFactor, imSize);
            state.acq.scanShiftFast=state.acq.scanShiftFast+ssF;
            state.acq.scanShiftSlow=state.acq.scanShiftSlow+ssS;
            updateGUIByGlobal('state.acq.scanShiftFast');
            updateGUIByGlobal('state.acq.scanShiftSlow');
            setupAOData; %needed to reset scanning shift
        end
        if autoFocus
            runDriftCorrect('LowResolution',true,'LiveAutofocus',true,'ShiftZPosition',true); %run autofocus and move to new Z position
            motorPosnAbsolute(3)=af.bestFocusAbsZ; %update motor position value to go to next time... this is to deal with offset mistakes.
        end
        
        %record values
        ds1.etlVoltage(1)=dia.etl.acq.voltageMin;
        motorGetPosition;
        ds1.relMotorZ(1)=state.motor.relZPosition;
%         if useDrift
% %             I=af.bestFocusedImage;
%             I = getLastAcqImage( af.params.channel,1 );
%             [ shiftx, shifty ] = computeDrift(Iref,I);
%             pos=[imSize(1)/2-shiftx, imSize(2)/2-shifty, 0, 0];
%             [ssF, ssS, ~, ~, ~, ~]=scanShiftCalc(pos, state.acq.zoomFactor, imSize);
%             state.acq.scanShiftFast=state.acq.scanShiftFast+ssF;
%             state.acq.scanShiftSlow=state.acq.scanShiftSlow+ssS;
%             updateGUIByGlobal('state.acq.scanShiftFast');
%             updateGUIByGlobal('state.acq.scanShiftSlow');
%             setupAOData; %needed to reset scanning shift
%         end
        state.files.baseName=genvarname([baseImgFname,'_Zoffset_',num2str(round(ds1.relMotorZ(1)*100)/100),'_']);
        dia.etl.acq.etlOn=0;
        for k=1:grabCount
            Igrab=updateCurrentImage(1,2,1);
        end
        ds1.Image{1}=Igrab;
        ds1.MirrorDataOutput{1}=state.acq.mirrorDataOutput;
        ds1.maxImageIntensity(1)=max(max(ds1.Image{1}));
        dia.etl.acq.etlOn=1;
        ds=[ds;ds1];
        dia.etl.measuredValues.tuneMeasurements=ds;
    catch err
        disp(err);
    end
end

dia.etl.measuredValues.tuneMeasurements=ds;

figure;
y=ds.relMotorZ;
x=ds.etlVoltage;
p=polyfit0(x,y,1);
p2=polyfit(x,y,8);
p3=polyfit(abs(y(2:end)),x(2:end),4);
p=[p,0];
f=polyval(p,x);
f2=polyval(p2,x);
f3=polyval(p3,abs(y));
plot(x,y,'o',x,f,'-',x,f2,'--');
% scatter(x,y);
set(get(gca,'YLabel'),'String','Motor Z');
set(get(gca,'XLabel'),'String','ETL Voltage');
txt=['Slope = ' num2str(p(1))];
text(.2,.95,txt,'parent',gca, ...
    'verticalalignment','top','units','normalized');
figure;
plot(abs(y),x,'o',abs(y),f3,'-');

dia.etl.measuredValues.trendLine=p;
dia.etl.measuredValues.poly8_voltageToMotor=p2;
dia.etl.measuredValues.poly4_motorToVoltage=p3;

 dia.etl.acq.umToVoltPoly=p3;
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
save([pName,fName(1:end-4),'Data.txt'],'ds2');

bestFitData=dia.etl.measuredValues;
save([pName,fName(1:end-4),'bestFitData.mat'],'bestFitData');
FS.Clear();
