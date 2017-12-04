function spc_startFocus
global gh state

% Function that will start the DAQ devices running for Focus (ao1F, ao2F, aiF).
%
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% February 7, 2001

%Ryohei 9/17/02 added state.init.spc_on

if state.spc.acq.spc_image
    start([state.spc.init.spc_aoF state.init.ao2F state.init.aiF]);
else
	start([state.spc.init.spc_aoF state.init.ao2F]);
end
 