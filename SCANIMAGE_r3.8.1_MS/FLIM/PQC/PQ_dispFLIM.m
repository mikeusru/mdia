function PQ_dispFLIM(calculateLifetime, focus)
global spc state gh gui

if ~nargin
    calculateLifetime = 1;
end

res = state.spc.acq.SPCdata.adc_resolution;
range = [1, res];
resolution = state.spc.acq.resolution; %ps
    
siz = size(spc.stack.image1{1});

factor = 1; %pixel value / photon

% if ~state.spc.acq.spc_average
%     factor = 1;
% else
%     if focus
%         factor = state.acq.numberOfFrames/(state.internal.frameCounter+1);
%     else
%         factor = state.acq.numberOfFrames;
%     end
% end

%NOT NECESSARY
if ~calculateLifetime 
    if focus 
        %frame = spc.stack.stackF(:,:,:,1);
        frame = spc.stack.image1{1};
    elseif ~state.spc.acq.spc_average
        %frame = spc.stack.stackF(:,:,:,state.internal.frameCounter+1);
        frame = spc.stack.image1{state.internal.frameCounter+1};
    else
        %frame = spc.stack.stackF(:,:,:,state.internal.frameCounter+1);
        %frame = sum(spc.stack.stackF(:,:,:,1:state.internal.frameCounter+1), 4);
        frame = spc.stack.image1{1};
        for i = 2:length(spc.stack.image1)
            frame = frame + spc.stack.image1{i};
        end
    end
    sum_projection = reshape(sum(frame, 1), siz(2), siz(3));
    
    if state.spc.acq.SPCdata.n_channels > 1
        y1 = state.acq.linesPerFrame*(gui.spc.proChannel-1) + 1: state.acq.linesPerFrame*gui.spc.proChannel;
        sum_Frame = sum_projection(y1, :);
    end
    
   % set(gui.spc.figure.projectImage, 'CData', sum_Frame*factor);
    %drawnow;
else
    if focus && ~state.spc.acq.FLIM_afterFocus
        return;
    end
    
    if focus
        sum_Frame = spc.stack.image1F{1};
    else
        if state.spc.acq.spc_average
            sum_Frame = spc.stack.image1{1};
            for i = 2:length(spc.stack.image1)
               sum_Frame = sum_Frame + spc.stack.image1{i};
            end
        else
           sum_Frame = spc.stack.image1{state.internal.frameCounter+1};
        end    
    end
    
    scan_size_x = state.acq.pixelsPerLine;
    scan_size_y = state.acq.linesPerFrame;
    
    %figure; imagesc(sum_projection);
    spc.lifetime= sum(sum(sum_Frame, 2),3);
    spc.switches.imagemode = 1;
    spc.switches.logscale = 1;
    for i = 1:state.spc.acq.SPCdata.n_channels
        spc.fit(i).range = range;
    end;
    
    spc.page = [1:length(spc.stack.image1)];
    spc.datainfo.time = datestr(clock, 13);
    spc.datainfo.date = datestr(clock, 1);

    spc.datainfo.scan_x = scan_size_x;
    spc.datainfo.scan_y = scan_size_y*state.spc.acq.SPCdata.n_channels;
    spc.datainfo.pix_time = state.acq.pixelTime;
    spc.datainfo.adc_re = res;
    spc.datainfo.pulseInt= 1e9/double(spc.datainfo.pulseRate);
    %spc.datainfo.pulseInt = 12.1; %double(pulseInt);
    
    spc.SPCdata.line_compression = 1;
    spc.SPCdata.scan_size_x = scan_size_x;
    spc.SPCdata.scan_size_y = scan_size_y;
    spc.SPCdata.scan_rout_x = state.spc.acq.SPCdata.n_channels;
    spc.SPCdata.scan_rout_y = 1;
    spc.datainfo.scan_rx = state.spc.acq.SPCdata.n_channels;
    spc.switches.noSPC = 0;
    spc.switches.redImg = 0;
    
    try
        spc.datainfo.triggerTime = state.spc.acq.triggerTime;
    catch
        warning('Trigger time is not set');
        spc.datainfo.triggerTime = datestr(now);
    end
    
    spc.datainfo.psPerUnit = resolution;
    spc.size = size(sum_Frame);
    spc.imageMod = sum_Frame;
    %z = state.internal.zSliceCounter
    if state.internal.zSliceCounter == 0 || state.internal.usePage || state.spc.acq.spc_average %Frame
        spc.stack.image1 = {};
        spc.stack.image1{1} = sum_Frame;
        set(gui.spc.spc_main.spc_page, 'String', '1')
    else
        spc.stack.image1{state.internal.zSliceCounter} = sum_Frame;
        set(gui.spc.spc_main.spc_page, 'String', num2str(1:state.internal.zSliceCounter))
    end
    
    %set(gui.spc.figure.LutLowerlimit, 'String', '0');
    if state.files.fileCounter == 1
        set(gui.spc.figure.projectAuto, 'value', 1)
    end
    try
        spc_redrawSetting(1); %Calculate spc.stack.project too.
        spc_redrawSetting(1);
    end
end