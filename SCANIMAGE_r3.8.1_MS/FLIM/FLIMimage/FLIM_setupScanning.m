function out1 = FLIM_setupScanning (focus)

global state gh spc gui dia

if ~isfield(gh, 'mainControls')
    out1 = 0;
    return;
end

out1 = 0;

state.spc.acq.SPCdata.scan_borders = 0;
state.spc.acq.SPCdata.scan_polarity = 0;
if state.spc.init.spc_dualB && state.internal.usePage
    state.spc.acq.SPCdata.trigger = 258;
else
    state.spc.acq.SPCdata.trigger = 2;
end
state.spc.acq.SPCdata.pixel_clock = 1; %state.spc.acq.spc_pixel;

state.spc.acq.SPCdata.stop_on_time = 0;


if focus
    state.spc.acq.SPCdata.collect_time = state.internal.numberOfFocusFrames*state.acq.linesPerFrame*state.acq.msPerLine/1000;
else
    if state.spc.init.spc_dualB
        state.spc.acq.SPCdata.collect_time = state.acq.numberOfFrames*state.acq.linesPerFrame*state.acq.msPerLine/1000;
    elseif dia.acq.doRibbonTransform %misha
        state.spc.acq.SPCdata.collect_time = state.acq.numberOfFrames*length(dia.acq.ribbon.mirrorDataOutput)/state.acq.outputRate;
    else
        state.spc.acq.SPCdata.collect_time = state.acq.numberOfFrames*state.acq.linesPerFrame*state.acq.msPerLine/1000;
    end
end

if state.acq.pixelsPerLine*state.acq.linesPerFrame <= 256*256 || dia.acq.doRibbonTransform
        state.spc.acq.SPCdata.scan_size_x = state.acq.pixelsPerLine;
        state.spc.acq.SPCdata.scan_size_y = state.acq.linesPerFrame;
    if state.spc.acq.SPCdata.mode == 2
        state.spc.acq.SPCdata.img_size_x = 1;
        state.spc.acq.SPCdata.img_size_y = 1;
    elseif state.spc.acq.SPCdata.mode == 0
        state.spc.acq.SPCdata.scan_size_x = 1;
        state.spc.acq.SPCdata.scan_size_y = 1;
    elseif state.spc.acq.SPCdata.mode == 5
        state.spc.acq.SPCdata.pixel_clock = 1;
        state.spc.acq.SPCdata.img_size_x = state.acq.pixelsPerLine;
        state.spc.acq.SPCdata.img_size_y = state.acq.linesPerFrame;
    end
else
    beep;
    out1 = 1;
    error('Error: change pixelsPerLine and state.acq.linesPerFrame to < 256 * 256');
end

state.spc.acq.SPCdata.pixel_time = 1/(state.acq.inputRate/state.acq.binFactor);
state.spc.acq.SPCdata.line_compression = 1;

if state.spc.acq.spc_binning == 1
     binfactor = state.spc.acq.binFactor;
     state.spc.acq.SPCdata.scan_size_x  =  floor(state.spc.acq.SPCdata.scan_size_x / binfactor) ;
     state.spc.acq.SPCdata.scan_size_y  =  floor(state.spc.acq.SPCdata.scan_size_y / binfactor) ;
     state.spc.acq.SPCdata.pixel_time = state.spc.acq.SPCdata.pixel_time * binfactor;
     state.spc.acq.SPCdata.line_compression = binfactor;
     state.spc.acq.SPCdata.scan_borders = state.spc.acq.SPCdata.scan_borders/binfactor;     
end

set(gui.spc.figure.projectAxes, 'xlim', [0.5, state.spc.acq.SPCdata.scan_size_x], 'ylim', [0.5, state.spc.acq.SPCdata.scan_size_y]);
set(gui.spc.figure.projectAxes, 'CLimMode', 'Auto');

if ~state.spc.acq.spc_average && ~focus
    if state.spc.init.infinite_Nframes
        state.spc.acq.SPCdata.scan_size_y = state.spc.acq.SPCdata.scan_size_y*state.spc.init.numSlicesPerFrames;
    else
        state.spc.acq.SPCdata.scan_size_y = state.spc.acq.SPCdata.scan_size_y*state.acq.numberOfFrames;
    end
end
if focus
    if state.spc.acq.SPCModInfo.module_type == 140 || state.spc.acq.SPCModInfo.module_type == 150
            state.spc.acq.SPCdata.adc_resolution=0;
    end
else
    state.spc.acq.SPCdata.adc_resolution = state.spc.acq.resolution;
end

if dia.acq.doRibbonTransform
    state.spc.acq.SPCdata.scan_size_y = 1;
    state.spc.acq.SPCdata.scan_size_x = floor(length(dia.acq.ribbon.mirrorDataOutput)/state.acq.outputRate/state.spc.acq.SPCdata.pixel_time);
    if state.spc.acq.SPCdata.scan_size_x >= 256*256
        beep;
        out1 = 1;
        error('Error: FLIM ribbon pixels >= 256*256');
    end
end

FLIM_setParameters;