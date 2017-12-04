function beamOutput = beamPowerTransform( beamOutput, beam )
%beamPowerTransform( beamOutput, shortOrLong )
% This function changes the pockels cells output so the beam power is equal
% over different scan angles where it usually loses power
% beam is the number of the beam
global state dia

mirrorDataOutput=state.acq.mirrorDataOutput;
pockelMaxIndex=beamOutput~=min(beamOutput);
% pockelMaxIndex=find(pockelMaxIndex);
% if shortOrLong==1
voltRangeX=mirrorDataOutput(pockelMaxIndex,1);
voltRangeY=mirrorDataOutput(pockelMaxIndex,2);
brightnessOffsetX=polyval(dia.init.PowerCalibZpx,voltRangeX);
brightnessOffsetY=polyval(dia.init.PowerCalibZpy,voltRangeY);
brightnessOffsetX(brightnessOffsetX>0)=0;
brightnessOffsetY(brightnessOffsetY>0)=0;
brightnessOffsetY=brightnessToPowerOffset(brightnessOffsetY);
brightnessOffsetX=brightnessToPowerOffset(brightnessOffsetX);
% brightnessOffsetX=sqrt(abs(brightnessOffsetX));
% brightnessOffsetY=sqrt(abs(brightnessOffsetY));
brightnessOffsetX=round(brightnessOffsetX);
brightnessOffsetY=round(brightnessOffsetY);
maxPower=state.init.eom.lut(beam, state.init.eom.maxPower(beam)+brightnessOffsetX+brightnessOffsetY);
beamOutput(pockelMaxIndex)=maxPower;
% elseif shortOrLong==2
%     maxPower=state.init.eom.lut(beam, state.init.eom.maxPower(beam)+brightnessOffset);
%     beamOutput(pockelMaxIndex)=maxPower;
% end

    function powerOffset=brightnessToPowerOffset(brightnessOffset)
        baseBrightness=polyval(dia.init.powerCalibPowerToBrightnessPoly,state.init.eom.maxPower(beam));
        if baseBrightness<0
            baseBrightness=0;
        end
        x=-brightnessOffset+baseBrightness;
        p=dia.init.powerCalibBrightnessToPowerPoly;
        y=polyval(p,x);
        powerOffset=y-state.init.eom.maxPower(beam);
        powerOffset=powerOffset-min(powerOffset);
    end
end