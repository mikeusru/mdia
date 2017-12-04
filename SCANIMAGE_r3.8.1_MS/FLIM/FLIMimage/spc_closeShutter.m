function spc_closeShutter
global state

% openShutter.m******
% 
% Function that sends the open signal defined in the state global 
% variable to the shutter.
%
% Must be executed after the setupDAQDevices.m function.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% December 5, 2000
            
state.shutter.shutterOpen=0;
%putvalue(state.shutter.shutterLine, state.shutter.open);
if state.spc.acq.spc_takeFLIM && state.spc.internal.ifstart
    putvalue(state.spc.init.spc_dio, [0, ~state.shutter.open, state.spc.init.dio_flim(end-1:end)]);
else
    putvalue(state.spc.init.spc_dio, [0, ~state.shutter.open, state.spc.init.dio_image(end-1:end)]);
end