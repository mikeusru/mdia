function spc_OutputStopFnc;

global state;

if sum(state.acq.acquiringChannel) == 0
    spc_endAcquisition_NoChannel;
end