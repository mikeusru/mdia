function [ powerCalibBrightnessToPowerPoly,powerCalibPowerToBrightnessPoly ] = tunePowerToBrightness()
%[ powerCalibBrightnessToPower ] = tunePowerToBrightness() checks various
%power intensities for the image brightness they produce

global state dia gh
powerCalibPowerToBrightness=zeros(1,100);
setZoomValue(30);
originalPower=get(gh.powerControl.maxPowerText,'String');

for i=1:2:50
    set(gh.powerControl.maxPowerText,'String',num2str(i));
    powerControl('maxPowerText_Callback',gh.powerControl.maxPowerText);
    I = updateCurrentImage(1,2,0);
    powerCalibPowerToBrightness(i)=mean(mean(double(I)));
end

set(gh.powerControl.maxPowerText,'String',originalPower);
powerControl('maxPowerText_Callback',gh.powerControl.maxPowerText);

[~,ind,val]=find(powerCalibPowerToBrightness);
p=polyfit(ind,val,3);
y=polyval(p,1:100);
figure;
plotVals=powerCalibPowerToBrightness;
plotVals(plotVals==0)=NaN;
plot(plotVals,'bo');
title('Brightness (Y) vs % Power (X)');
hold on
plot(y);
hold off
% powerCalibPowerToBrightness=y;
powerCalibPowerToBrightnessPoly=p;
p2=polyfit(y,1:100,3);
x=polyval(p2,y);
powerCalibBrightnessToPowerPoly=p2;
figure;
plot(val,ind,'ro',y,x,'b-');
title('Brightness (X) vs % Power (Y)');
end

