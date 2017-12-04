function PQ_startMeasurement(focus)
global state gh spc

PQC_readBuffer(0);
state.spc.internal.ifstart = 1;
if ~focus
    %disp('FLIM started');    
    if state.internal.usePage
        state.spc.internal.frameDone = 0;
        state.acq.numberOfFrames = state.acq.framesPerPage;
        state.acq.numberOfZSlices = state.acq.numberOfPages;
        state.acq.numAvgFramesSave = state.acq.framesPerPage;
        state.acq.numAvgFramesDisplay = state.acq.framesPerPage;
        state.acq.averagingDisplay = 1;
        state.acq.averaging = 1;
        state.acq.zStepSize = 0;
        
    else
        state.acq.numberOfFrames = str2double(get(gh.mainControls.framesTotal, 'String'));
        state.acq.numberOfZSlices = str2num(get(gh.mainControls.slicesTotal, 'String'));       
        state.acq.numAvgFramesSave = str2num(get(gh.mainControls.etNumAvgFramesSave, 'String'));
        state.acq.numAvgFramesDisplay = state.acq.numAvgFramesSave;
        if state.acq.numAvgFramesSave > 1
            state.acq.averagingDisplay = 1;
        else
            state.acq.averagingDisplay = 0;
        end
        state.acq.zStepSize = str2double(get(gh.motorControls.etZStepPerSlice, 'String'));
    end
    
    nFramesSave = state.acq.numberOfFrames;
    nFramesAcquire = state.acq.numberOfFrames;
else
    %disp('Focus started');
    nFramesSave = 2;
    nFramesAcquire = 10000;
    state.acq.averagingDisplay = 0;
end

if state.acq.clockExport.pixelClockEnable || state.acq.clockExport.lineClockPolarityLow ...
        || ~state.acq.clockExport.lineClockEnable || state.acq.clockExport.frameClockEnable
    state.acq.clockExport.pixelClockEnable = 0;
    state.acq.clockExport.frameClockEnable = 0;
    state.acq.clockExport.lineClockEnable = 1;
    state.acq.clockExport.lineClockPolarityLow = 0;
    state.acq.clockExport.lineClockPolarityHigh = 1;
    exportClocks();
end

if state.acq.numAvgFramesSave == 1
    state.spc.acq.spc_average = 0;
else
    state.spc.acq.spc_average = 1;
end

if spc.datainfo.pulseRate <= 1e2
    warning('No laser pulse detected!!');
    spc.datainfo.pulseInt = 12.4;
end

%state.spc.internal.hPQ.setParameters;
state.spc.acq.resolution = state.spc.acq.SPCdata.resolution;
state.spc.acq.SPCdata.adc_resolution = ceil(spc.datainfo.pulseInt * 1000 / state.spc.acq.resolution);

period = state.acq.msPerLine*state.acq.linesPerFrame/state.internal.numberOfStripes/1000;
set(state.spc.internal.focusTimer, 'period', period);
set(state.spc.internal.grabTimer, 'period', period);

%%%%%%%%%%% BIN IF IT IS TOO FAST for FOCUS
state.spc.internal.showRealtimeImage = 1;

update_from_GUI = 1; 
PQC_setParametersGUI(update_from_GUI);

if state.spc.acq.spc_takeFLIM %&& (~focus)
    n_time = state.spc.acq.SPCdata.adc_resolution;
else
    n_time = 1;
    spcdata = state.spc.acq.SPCdata;
    spcdata.binning = 8;
    spcdata = PQC_setParameters(state.spc.internal.hPQ.device, spcdata, 0);
end

if ~focus
    spc.stack.image1 = {};
    for i = 1:nFramesSave
        spc.stack.image1{i} = zeros(n_time, ...
            state.acq.linesPerFrame*state.spc.acq.SPCdata.n_channels, state.acq.pixelsPerLine, 'uint8');
    end
else
    spc.stack.image1F = {};
    for i = 1:2
        spc.stack.image1F{i} = zeros(n_time, ...
            state.acq.linesPerFrame*state.spc.acq.SPCdata.n_channels, state.acq.pixelsPerLine, 'uint8');
    end
end

if state.internal.usePage
    spc.stack.stackA = zeros(state.spc.acq.SPCdata.adc_resolution, ...
        state.acq.linesPerFrame*state.spc.acq.SPCdata.n_channels, state.acq.pixelsPerLine, state.acq.numberOfPages, 'uint8');
end

for ch=1:state.spc.acq.SPCdata.n_channels
    spc.stack.remaining_stripeData{ch} = [];
end

state.spc.internal.lineCounter = 0;
state.spc.internal.previousLine = [];

%PQ_dispFLIM(1);
if state.internal.usePage
    disp('Page=0, Ave page=0 time=0.00 s (Timer started)');
    
    state.spc.acq.timing(1) = 0;
    state.internal.pageTicID = tic;
end

state.spc.acq.internal.Tacq = state.acq.numberOfFrames * nFramesAcquire * state.acq.msPerLine + 500000; %millisecond
% ret = calllib('TH260lib', 'TH260_StartMeas', state.spc.acq.module, state.acq.internal.Tacq);
state.spc.internal.hPQ.measurementTime = state.spc.acq.internal.Tacq;
state.spc.internal.hPQ.startMeas;

