function [ Zrange ] = calcZRange( origin )
%calcZRange is a function to calculate the Z range using the z origin
%input. This function can later be altered to calculate ranges based on
%other slice counts and steps.

global state

if ~mod(state.acq.numberOfZSlices,2) %weird thing necessary to calculate Z coordinates same way scanimage does it
    Zrange=linspace(origin-state.acq.zStepSize*state.acq.numberOfZSlices/2,origin+state.acq.zStepSize*(state.acq.numberOfZSlices/2-1),state.acq.numberOfZSlices);
else
    Zrange=linspace(origin-state.acq.zStepSize*(state.acq.numberOfZSlices-1)/2,origin+state.acq.zStepSize*(state.acq.numberOfZSlices/2-.5),state.acq.numberOfZSlices);
end

end

