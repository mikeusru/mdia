function spc_startGrab
global state;

%    list = delimitedList(state.init.eom.focusLaserList, ',');
%     offBeams = find(~ismember(state.init.eom.pockelsCellNames, list));
%     for i = 1 : length(offBeams)
%         putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{i}, state.init.eom.min(i));
%     end



    %if state.spc.acq.spc_image
        if state.spc.acq.spc_takeFLIM            
%             if state.spc.acq.spc_image
                start([state.spc.init.spc_ao, state.init.ao2, state.init.ai]);
%             else
%                 start([state.spc.init.spc_ao, state.init.ao2]);
%             end
        else
            start([state.spc.init.pockels_ao, state.init.ao2, state.init.ai]);
        end
%     else
%         start([state.spc.init.spc_ao, state.init.ao2]);
%     end

    
    
%%%EPHYS for UNCAGING%%%%
% if state.spc.acq.uncageBox & state.spc.acq.uncageEveryXFrame > 0
%     try
%         yphys_setup;
%         param = state.yphys.acq.pulse{3,state.yphys.acq.pulseN};
%         rate = param.freq;
%         nstim = param.nstim;
%         dwell = param.dwell;
%         ampc = param.amp;
%         delay = param.delay;
%         sLength = param.sLength;
%         %input Setting.
%         %get(state.yphys.init.phys_input);
%         set(state.yphys.init.phys_input, 'TriggerType', 'HwDigital');
%         set(state.yphys.init.phys_input, 'SamplesPerTrigger', sLength*state.yphys.acq.inputRate/1000));
%         set(state.yphys.init.phys_input, 'StopFcn', '');
% 
%         %Output Setting
%         if ~state.yphys.acq.cclamp & sLength > 200
%             phys_output = zeros(length(pockelsOutput2), 1);
%             phys_output_dep = yphys_mkPulse(50, 1, 50, -5/20, 10, 100, 'ap');
%             depstart=length(phys_output)-length(phys_output_dep);
%             phys_output(depstart+1:end) = phys_output_dep;
%         else
%             phys_output = zeros(length(pockelsOutput2), 1);
%         end
%         set(gh.yphys.pulsePlot1, 'XData', (1:length(phys_output))/state.yphys.acq.outputRate*1000, 'YData', phys_output);
%         set(state.yphys.init.phys_patch, 'TriggerType', 'HwDigital');
%     end
% end