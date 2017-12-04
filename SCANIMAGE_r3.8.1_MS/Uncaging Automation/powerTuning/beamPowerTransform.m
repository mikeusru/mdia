function beamOutput = beamPowerTransform( beamOutput, beam, uncaging )
%beamPowerTransform( beamOutput, shortOrLong )
% This function changes the pockels cells output so the beam power is equal
% over different scan angles where it usually loses power
% beam is the number of the beam
% uncaging indicates whether uncaging is happening

global state dia

if nargin<3
    uncaging=false;
end
pockelMaxIndex=beamOutput~=min(beamOutput);

if uncaging
    beamOutput(pockelMaxIndex)=dia.init.powerMod.PockelsModulationUncaging(pockelMaxIndex);
else
beamOutput(pockelMaxIndex)=dia.init.powerMod.PockelsModulationMatrix{beam}(pockelMaxIndex);
end
