function optLens_ini
%optLens_ini initiates some ETL control parameters
global state dia

import dabs.ni.daqmx.*

dia.init.etl.boardIndex='Dev2'; %name of output DAQ board
dia.init.etl.channel=7; %output channel on DAQ board
dia.init.etl.voltageRange=5; %voltage range is 0 to this value
dia.init.etl.ao_etl=Task(['ETL Control', num2str(round(rand(1)*10000))]);
dia.init.etl.ao_etl.createAOVoltageChan(dia.init.etl.boardIndex,dia.init.etl.channel,'ETL',-dia.init.etl.voltageRange,dia.init.etl.voltageRange);

voltageSignal=[1;2;3;4];
outputRate=1; %frequency of value changes
outputCount=4; %amount of times voltageSignal is cycled through
outputBufferSize=length(voltageSignal)*outputCount; %total amount of  
% dia.init.etl.ao_etl.cfgSampClkTiming(state.acq.outputRate, 'DAQmx_Val_FiniteSamps',state.init.hAO.get('bufOutputBufSize') * state.internal.numberOfFocusFrames);
dia.init.etl.ao_etl.cfgSampClkTiming(outputRate, 'DAQmx_Val_FiniteSamps',outputBufferSize); %works for as long as outputBufferSize indicates
dia.init.etl.ao_etl.cfgSampClkTiming(outputRate, 'DAQmx_Val_ContSamps',outputBufferSize); %works forever


dia.init.etl.ao_etl.writeAnalogData(voltageSignal); %set signal
dia.init.etl.ao_etl.start(); %start instrument

dia.init.etl.ao_etl.stop(); %stop instrument

dia.init.etl.ao_etl.control('DAQmx_Val_Task_Unreserve'); %unreserve AO buffers so other things can use them.
dia.init.etl.ao_etl.cfgDigEdgeStartTrig(state.init.triggerInputTerminal); %run on trigger
% the first integer sets the voltage
dia.init.etl.ao_etl.writeAnalogData(state.acq.mirrorDataOutput);


rate=dia.init.etl.ao_etl.sampClkRate


state.init.hAO.createAOVoltageChan(dia.init.etl.boardIndex,dia.init.etl.channel,'ETL',-dia.init.etl.voltageRange,dia.init.etl.voltageRange);

end

