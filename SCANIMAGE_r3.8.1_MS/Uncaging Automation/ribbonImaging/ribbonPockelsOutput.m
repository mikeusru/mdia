function beamOutput = ribbonPockelsOutput(beamOutput, maxValue)
%beamOutput = ribbonPockelsOutput(maxValue) creates the pockels cell output
%for a ribbon transform
%   Detailed explanation goes here
global dia
minValue=min(beamOutput);
beamOutput=double(dia.acq.ribbon.inSmallShifted);
beamOutput(~dia.acq.ribbon.inSmallShifted)=minValue;
beamOutput(dia.acq.ribbon.inSmallShifted)=maxValue;
% beamOutput=repmat(minValue,(length(dia.acq.ribbon.inFull)),1);
% beamOutput(dia.acq.ribbon.inSmall)=maxValue;
% beamOutput=beamOutput(dia.acq.ribbon.inFull);
end

