function spc_parkLaser
global state

% parkLaser.m*******
%
% Function that puts the laser at the designated place that is set
% by the user via state.acq.parkAmplitudeX & state.acq.parkAmplitudeY
% or specified by the user in the parameter XY
%
% Places data back in the engine when done for next output.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% February 8, 2001

% start(state.init.aoPark);
% 
% while strcmp(state.init.aoPark.Running, 'On')
% end

%makeAndPutDataPark;
%TPMOD
%setPockelsVoltage(state.acq.pockellAmplitude - state.acq.pockellOffset);

%9/17/2 Ryohei for FLIM
%

    %a = state.spc.acq.spc_amplitude;
    %a=0;
    
% if state.init.pockelsOn == 1
%     %putsample(state.spc.init.spc_ao,[a,a,a,a,a,a]);
% else
%     %putsample(state.spc.init.spc_ao,[a,a,a]);
% end