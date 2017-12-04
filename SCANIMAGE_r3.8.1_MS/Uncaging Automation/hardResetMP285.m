function hardResetMP285
%hardResetMP285 sends a hard reset signal to the mp285 motor controller
%   This is useful for when the controller crashes (usually when reading a
%   position while being manually controlled) and the reset button needs to
%   be pushed. A custom connector to the reset button needs to be attached.

global dia state

if ~dia.init.mp285reset.resetOn
    return
end

%% disable other functions using the same board
try
    warning off
    state.spc.init.taskA.control('DAQmx_Val_Task_Unreserve');
    warning on
end

try
    state.init.hAOAcqTasks.control('DAQmx_Val_Task_Unreserve');
end

%%
voltageSignal=[5;0];
outputRate=10; %frequency of value changes
outputCount=1; %amount of times voltageSignal is cycled through
outputBufferSize=length(voltageSignal)*outputCount; %total amount of  
dia.init.mp285reset.eom.hAO.cfgSampClkTiming(outputRate, 'DAQmx_Val_FiniteSamps',outputBufferSize); %works for as long as outputBufferSize indicates


dia.init.mp285reset.eom.hAO.writeAnalogData(voltageSignal); %set signal
dia.init.mp285reset.eom.hAO.start(); %start instrument

pause(.3);

dia.init.mp285reset.eom.hAO.stop(); %stop instrument

dia.init.mp285reset.eom.hAO.control('DAQmx_Val_Task_Unreserve'); %unreserve AO buffers so other things can use them.

end

