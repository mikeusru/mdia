function yphys_setup (restart_all, start_external)
global state yphys gh dia

if ~nargin
    restart_all = 1;
end
if nargin < 1
    start_external = 0;
end


state.yphys.init.yphys_on = 1;

state.yphys.init.mirrorOutputBoardIndex = state.init.mirrorOutputBoardID;
state.yphys.init.XMirrorChannelIndex =  state.init.XMirrorChannelID;
state.yphys.init.YMirrorChannelIndex =  state.init.YMirrorChannelID;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.yphys.init.eom.laserP = 1;
state.yphys.init.eom.uncageP = 2;
state.yphys.init.eom.requireOpeningBeforeCalibBeam = 2;
%%%%%
state.yphys.init.eom.pockelsBoardIndex1 = state.init.eom.pockelsBoardID1;
state.yphys.init.eom.pockelsChannelIndex1 = state.init.eom.pockelsChannelIndex1;
%%%%
state.yphys.init.eom.pockelsBoardIndex2 = state.init.eom.pockelsBoardID2;
state.yphys.init.eom.pockelsChannelIndex2 = state.init.eom.pockelsChannelIndex2;
%%%
state.yphys.init.eom.shutterAOBoard = state.init.eom.pockelsBoardID1; %state.init.eom.pockelsBoardIndex2;
state.yphys.init.eom.shutterAOChannelIndex = 3;
%%%
state.yphys.init.acquisitionBoardIndex = state.init.acquisitionBoardID;
state.yphys.init.inputChannelIndex1 = state.init.inputChannelIndex1;
state.yphys.init.inputChannelIndex2 = state.init.inputChannelIndex2;
%%%%
state.yphys.init.vclampBoardIndex = 'Dev3';
state.yphys.init.vclampLineIndex = 1;
%%%%
state.yphys.init.phys_boardIndex = 'Dev3';
state.yphys.init.phys_patchChannelIndex = 0;
state.yphys.init.phys_stimChannelIndex = 1;
state.yphys.init.phys_dataIndex = 0;
state.yphys.init.phys_gainIndex = 1;
state.yphys.init.phys_viIndex = 2;
% state.yphys.init.triggerBoardIndex = state.init.triggerBoardID;
% state.yphys.init.triggerLineIndex = state.init.triggerLineID;
%%%.
state.yphys.acq.inputRate = 1250000;
%%%
state.yphys.init.multiclamp = 1;  %0 = axopatch 200B, 1 = multiclamp 700B, 2 = Axopatch 1D
state.yphys.acq.multiclamp = 1;

% yphys.init.multiClampFileName = 'C:\Program Files\acq\amps\00000000_1.txt';
% if state.yphys.acq.multiclamp
%     b = dir('C:\Program Files\acq\amps\*_1.txt');
%     for i = 1:length(b)
%         if strcmp(b(i).name, '00000000_1.txt') || strcmp(b(i).name, 'no_ampli_1.txt')
%         else
%             state.yphys.init.multiClampFileName = ['C:\Program Files\acq\amps\', b(i).name];
%         end
%     end
% end
%%%

%%%%
yphys.aveString{1} = '';
yphys.filename = '';
yphys.data.data = [1:32, 1:2];
yphys.aveData = [1:32, 1:2];
yphys.fwindow = 5;
%%%
%
state.yphys.shutter.close = 0;
state.yphys.shutter.open = 5;
%
if state.init.eom.numberOfBeams == 1
    state.yphys.init.shutter_delay = 0; %For slow shutter, put 4.]
else
    state.yphys.init.shutter_delay = 4;
end


if state.yphys.init.multiclamp == 0 %Default setting.
    state.yphys.acq.gainV = 1/1000; %Input gain V / nA (/ 1000)
    state.yphys.acq.gainC = 1/1000; %Input gain V / mV --- getting milivolt
    state.yphys.acq.commandSensV = 20; %mV/V
    state.yphys.acq.commandSensC = 2000; %pA/V
elseif state.yphys.init.multiclamp == 1
    state.yphys.acq.gainV = 0.5/1000; %Input gain V / nA (/ 1000)
    %state.yphys.acq.gainV = 1/1000
    state.yphys.acq.gainC = 10/1000; %Input gain V / mV --- getting milivolt
    state.yphys.acq.commandSensV = 20; %mV/V
    state.yphys.acq.commandSensC = 400; %pA/V
elseif state.yphys.init.multiclamp == 2
    state.yphys.acq.gainV = 1/1000; %Input gain V / nA (/ 1000)
    state.yphys.acq.gainC = 1/1000; %Input gain V / mV --- getting milivolt
    state.yphys.acq.commandSensV = 20; %mV/V
    state.yphys.acq.commandSensC = 400; %pA/V
end

state.yphys.acq.inputRate = 20000;
state.yphys.acq.outputRate = 20000;
state.yphys.acq.cclamp = 0;
state.yphys.internal.fft_on = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Page the value here!!!!
%state.yphys.acq.scanoffset =  [ 0.0040, 0.000];
%%%%Put Roi1 at a bead and type "yphys_voltageCalib" to obtain this value.
%%%%Note *** Uncaging protocol must be shorter than ~100 ms.
state.yphys.acq.scanoffset =   [-0.000         0]; %%Calibrated 5/4/2011, Rohit & Ryohei
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%
%board setting
%%%%%%%%%%%%%%%%%%
%Graphics


if ~isfield(gh, 'yphys')
    gh.yphys.calcium = 1;
    gh.yphys.intensity_graph = 1;
    gh.yphys.figure.yphys_roi = 1;
    gh.yphys.figure.stim_graph = 1;
else
    if isfield(gh.yphys, 'stimScope')
        try
            set(gh.yphys.stimScope.start, 'Enable', 'On');
        end
    end
    if ~isfield (gh.yphys, 'calcium')
        gh.yphys.calcium = 1;
    end
    if ~isfield (gh.yphys, 'intensity_graph')
        gh.yphys.intensity_graph = 1;
    end
    if ~isfield (gh.yphys, 'figure')
        gh.yphys.figure.yphys_roi = 1;
    end
end
%%%%%%%

if isempty(strfind(computer, '64')) %32bit
    win64 = 0;
else
    win64 = 1;
    state.yphys.init.yphys_on = 0;
end

if state.yphys.init.multiclamp == 1 && state.yphys.init.yphys_on
    if start_external
%         if exist('C:\Program Files\acq\MCTeleClient.exe', 'file')
%             %open('C:\Program Files\acq\MCTeleClient.exe');
%         end
        if exist('C:\Program Files (x86)\Molecular Devices\MultiClamp 700B Commander\MC700B.exe', 'file')
            token=MultiClampTelegraph('getAllAmplifiers');
            if isempty(token)
                open('C:\Program Files (x86)\Molecular Devices\MultiClamp 700B Commander\MC700B.exe');
            end
        end
    end
end

board_active = 1;
try
    if ~strcmp(get(state.yphys.init.phys_input, 'taskName'), 'yphys input')
        board_active = 0;
    end
catch
    board_active = 0;
end    
if restart_all
    board_active = 0;
end
    
if ~board_active && restart_all
    import dabs.ni.daqmx.*


    try
        delete(state.yphys.init.phys_input);
        pause(0.05);
    end
    if state.yphys.init.yphys_on == 1;
        try
            state.yphys.init.phys_input = Task(['yphys input', num2str(round(rand(1)*10000))]);
            state.yphys.init.phys_input.createAIVoltageChan(state.yphys.init.phys_boardIndex, state.yphys.init.phys_dataIndex, 'data', -10, 10);
            %state.yphys.init.phys_input.cfgSampClkTiming(state.yphys.acq.inputRate,'DAQmx_Val_ContSamps'); %Defer buffer configuration until everyNSamples value is known
            %state.yphys.init.phys_input.everyNSamplesReadDataEnable=true;
            %state.yphys.init.phys_input.set('everyNSamplesEventCallbacks', @yphys_getData);
            %state.yphys.init.phys_input.set('everyNSamplesReadDataTypeOption', 'native');
            state.yphys.init.phys_input.cfgSampClkTiming(state.yphys.acq.inputRate,'DAQmx_Val_FiniteSamps');
            state.yphys.init.phys_input.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
            state.yphys.init.phys_input.set('doneEventCallbacks', @yphys_getData);
        catch
            state.yphys.init.yphys_on = 0;
            disp('yphys board not detected');
        end
    end

    if state.yphys.init.yphys_on
        try
            delete(state.yphys.init.phys_inputPatch);
        end
        state.yphys.init.phys_inputPatch = Task(['yphys input patch', num2str(round(rand(1)*10000))]);
        state.yphys.init.phys_inputPatch.createAIVoltageChan(state.yphys.init.phys_boardIndex, state.yphys.init.phys_dataIndex, 'data patch', -10, 10);
        state.yphys.init.phys_inputPatch.cfgSampClkTiming(state.yphys.acq.inputRate,'DAQmx_Val_FiniteSamps');
        state.yphys.init.phys_inputPatch.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
        state.yphys.init.phys_inputPatch.set('doneEventCallbacks', @yphys_getData_patch);

        try
            delete(state.yphys.init.phys);
        end
        state.yphys.init.phys = Task(['yphys stim', num2str(round(rand(1)*10000))]);
        physTask = [state.yphys.init.phys];  
        stim1 = physTask(1).createAOVoltageChan(state.yphys.init.phys_boardIndex, state.yphys.init.phys_stimChannelIndex, 'stim1', -10, 10);
        physTask(1).cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
        physTask(1).cfgSampClkTiming(state.yphys.acq.outputRate, 'DAQmx_Val_FiniteSamps');

        %
        try
            delete(state.yphys.init.phys_patch);
        end
        state.yphys.init.phys_patch = Task(['yphys patch', num2str(round(rand(1)*10000))]);
        state.yphys.init.phys_patch.createAOVoltageChan(state.yphys.init.phys_boardIndex, state.yphys.init.phys_patchChannelIndex, 'patch1', -10, 10);
        state.yphys.init.phys_patch.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
        state.yphys.init.phys_patch.cfgSampClkTiming(state.yphys.acq.outputRate, 'DAQmx_Val_FiniteSamps');
    %
        try
            delete(state.yphys.init.phys_patch_Static);
        end
        state.yphys.init.phys_patch_Static = Task(['yphys patch static', num2str(round(rand(1)*10000))]);
        state.yphys.init.phys_patch_Static.createAOVoltageChan(state.yphys.init.phys_boardIndex, state.yphys.init.phys_patchChannelIndex, 'patch1 static', -10, 10);

        %
        try
            delete(state.yphys.init.phys_both);
        end   
        state.yphys.init.phys_both = Task(['yphys both', num2str(round(rand(1)*10000))]);
        state.yphys.init.phys_both.createAOVoltageChan(state.yphys.init.phys_boardIndex, state.yphys.init.phys_patchChannelIndex, 'patch2', -10, 10);
        state.yphys.init.phys_both.createAOVoltageChan(state.yphys.init.phys_boardIndex, state.yphys.init.phys_stimChannelIndex, 'stim2', -10, 10);
        state.yphys.init.phys_both.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
        state.yphys.init.phys_both.cfgSampClkTiming(state.yphys.acq.outputRate, 'DAQmx_Val_FiniteSamps');    
    end

    try
        delete(state.yphys.init.scan_aoPark);
    end   
    state.yphys.init.scan_aoPark = Task(['yphys scan park', num2str(round(rand(1)*10000))]);
    state.yphys.init.scan_aoPark.createAOVoltageChan(state.yphys.init.mirrorOutputBoardIndex, state.yphys.init.XMirrorChannelIndex, 'yphys_Xmirror park', -10, 10);
    state.yphys.init.scan_aoPark.createAOVoltageChan(state.yphys.init.mirrorOutputBoardIndex, state.yphys.init.YMirrorChannelIndex, 'yphys_ymirror park', -10, 10);

    try
        delete(state.yphys.init.scan_ao);
    end   
    state.yphys.init.scan_ao = Task(['yphys scan', num2str(round(rand(1)*10000))]);
    state.yphys.init.scan_ao.createAOVoltageChan(state.yphys.init.mirrorOutputBoardIndex, state.yphys.init.XMirrorChannelIndex, 'yphys_Xmirror', -10, 10);
    state.yphys.init.scan_ao.createAOVoltageChan(state.yphys.init.mirrorOutputBoardIndex, state.yphys.init.YMirrorChannelIndex, 'yphys_ymirror', -10, 10);
    state.yphys.init.scan_ao.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
    state.yphys.init.scan_ao.cfgSampClkTiming(state.yphys.acq.outputRate, 'DAQmx_Val_FiniteSamps');
    %
    try
        delete(state.yphys.init.laser_ao);
    end    
    state.yphys.init.laser_ao = Task(['yphys laser park', num2str(round(rand(1)*10000))]);
    p1 = state.yphys.init.laser_ao.createAOVoltageChan(state.yphys.init.eom.pockelsBoardIndex1, state.yphys.init.eom.pockelsChannelIndex1, 'yphys_p1 park', -10, 10);
    %
    try
        delete(state.yphys.init.pockels_aoPark);
    end
    state.yphys.init.pockels_aoPark = Task(['yphys pockels park', num2str(round(rand(1)*10000))]);
    p2park = state.yphys.init.pockels_aoPark.createAOVoltageChan(state.yphys.init.eom.pockelsBoardIndex2, state.yphys.init.eom.pockelsChannelIndex2, 'yphys_p2 park', -10, 10);
    %p3 = state.yphys.init.pockels_aoPark.createAOVoltageChan(state.yphys.init.eom.pockelsBoardIndex2, state.yphys.init.eom.pockelsChannelIndex3, 'yphys_p3 park', -10, 10);
    
    try
        delete(state.yphys.init.pockels_ao); %Combined shutter
    end
    state.yphys.init.pockels_ao = Task(['yphys pockels', num2str(round(rand(1)*10000))]);
    p2 = state.yphys.init.pockels_ao.createAOVoltageChan(state.yphys.init.eom.pockelsBoardIndex2, state.yphys.init.eom.pockelsChannelIndex2, 'yphys_p2', -10, 10);
    p3 = state.yphys.init.pockels_ao.createAOVoltageChan(state.yphys.init.eom.shutterAOBoard, state.yphys.init.eom.shutterAOChannelIndex, 'yphys_p3', -10, 10);
    state.yphys.init.pockels_ao.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
    state.yphys.init.pockels_ao.cfgSampClkTiming(state.yphys.acq.outputRate, 'DAQmx_Val_FiniteSamps');     
 
   
    try
        delete(state.yphys.init.shutterAOPark);
    end
    state.yphys.init.shutterAOPark = Task(['yphys AO shutter park', num2str(round(rand(1)*10000))]);
    p3park = state.yphys.init.shutterAOPark.createAOVoltageChan(state.yphys.init.eom.shutterAOBoard, state.yphys.init.eom.shutterAOChannelIndex, 'yphys_p3 park', -10, 10);    
    state.yphys.init.shutterAOPark.writeAnalogData(state.yphys.shutter.close, 1, true);
%     try
%         delete(state.yphys.init.shutterAO);
%     end
%     state.yphys.init.shutterAO = Task(['yphys AO shutter', num2str(round(rand(1)*10000))]);
%     p3 = state.yphys.init.shutterAO.createAOVoltageChan(state.yphys.init.eom.shutterAOBoard, state.yphys.init.eom.shutterAOChannelIndex, 'yphys_p3', -10, 10);
%     state.yphys.init.shutterAO.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
%     state.yphys.init.shutterAO.cfgSampClkTiming(state.yphys.acq.outputRate, 'DAQmx_Val_FiniteSamps');         
    
    %%%%%%%%%%%%%%%%%%%
    try
        delete(state.yphys.init.acq_ai);
    end
    state.yphys.init.acq_ai = Task(['yphys acq ai', num2str(round(rand(1)*10000))]);
    phys_acq = state.yphys.init.acq_ai;
    chan0 = state.yphys.init.acq_ai.createAIVoltageChan(state.yphys.init.acquisitionBoardIndex, state.yphys.init.inputChannelIndex1, 'yphys_c1', -10, 10);
    chan1 = state.yphys.init.acq_ai.createAIVoltageChan(state.yphys.init.acquisitionBoardIndex, state.yphys.init.inputChannelIndex2, 'yphys_c2', -10, 10);
    state.yphys.init.acq_ai.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
    state.yphys.init.acq_ai.cfgSampClkTiming(state.acq.inputRate,'DAQmx_Val_FiniteSamps', 100); 
    state.yphys.init.acq_ai.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
    %state.yphys.init.acq_ai.cfgDigEdgeStartTrig(state.init.triggerInputTerminal,'DAQmx_Val_Rising');


    
    try
        delete(state.spc.init.eom.hAO2)
    end
    state.spc.init.eom.hAO2 = Task(['Pockels and shutter Output', num2str(round(rand(1)*10000))]); 
    for i=1:state.init.eom.numberOfBeams
        pockelsBoardID = state.init.eom.(['pockelsBoardID' num2str(i)]);
        pockelsChanID = state.init.eom.(['pockelsChannelIndex' num2str(i)]);
        state.spc.init.eom.hAO2.createAOVoltageChan(pockelsBoardID,pockelsChanID,['PockelsCell-' num2str(i)],-10, 10);    
    end
    try
        if dia.init.etl.etlOn
        % % dia.init.etl.ao_etl=Task(['ETL Control', num2str(round(rand(1)*10000))]);
        % % dia.init.etl.ao_etl.createAOVoltageChan(dia.init.etl.boardIndex,dia.init.etl.channel,'ETL',-dia.init.etl.voltageRange,dia.init.etl.voltageRange);
            state.spc.init.eom.hAO2.createAOVoltageChan(dia.init.etl.boardIndex,dia.init.etl.channel,'ETL',-dia.init.etl.voltageRange,dia.init.etl.voltageRange);
        end
    end
    
    state.spc.init.eom.hAO2.createAOVoltageChan(state.yphys.init.eom.shutterAOBoard, state.yphys.init.eom.shutterAOChannelIndex, 'shutter_1', -10, 10);
    %%%
    state.spc.init.eom.hAO2.cfgSampClkTiming(state.acq.outputRate, 'DAQmx_Val_FiniteSamps'); %VI090509A: Use timebase synchronization instead
    state.spc.init.eom.hAO2.cfgDigEdgeStartTrig(state.init.triggerInputTerminal); 
    state.spc.init.eom.hAO2.set('masterTimebaseRate', 20e6, 'masterTimebaseSrc', 'RTSI7'); 
    
    if ~isempty(state.init.acquisitionBoardID)
        state.spc.init.taskA = [state.init.hAI state.init.hAO state.spc.init.eom.hAO2];
    else
        state.spc.init.taskA = [state.init.hAO state.spc.init.eom.hAO2];
    end
 end


