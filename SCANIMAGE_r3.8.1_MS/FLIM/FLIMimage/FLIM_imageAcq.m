function error1 = FLIM_imageAcq (redraw, focus)

global state dia
global spc gui

if ~nargin
    redraw = 1;
end
if nargin < 2
    focus = 0;
end

%redraw = 1
error1 = 0;

%set(gh.spc.FLIMimage.status, 'String', 'Reading data'); 
% set(gh.spc.FLIMimage.focus,'Enable','Off');
% set(gh.spc.FLIMimage.grab,'Enable','Off');
% set(gh.spc.FLIMimage.loop,'Enable','Off');


% if dia.acq.doRibbonTransform %misha
%     blocks_per_frame = floor(length(dia.acq.ribbon.mirrorDataOutput)/state.acq.outputRate/state.spc.acq.SPCdata.pixel_time);
% else
    blocks_per_frame = state.spc.acq.SPCMemConfig.blocks_per_frame;
% end
frames_per_page = state.spc.acq.SPCMemConfig.frames_per_page;
block_length = state.spc.acq.SPCMemConfig.block_length;
%disp('Now reading data block ...');
image1 = [];
memorysize =  block_length* blocks_per_frame*  frames_per_page;
image1(memorysize)=0.0;
%[out1 image1]=calllib(state.spc.init.dllname,'SPC_read_data_page',state.spc.acq.module,0,0,image1);
frame = 0;


% if strcmp(get(gh.spc.FLIMimage.focus, 'String'), 'STOP')
%     [out1, image1]=calllib(state.spc.init.dllname,'SPC_read_data_page',state.spc.acq.module, 0, 0, image1);
%     %pause(0.005);
% else
    if state.internal.usePage 
  %%
                memorysize1 = memorysize;
                state.spc.internal.image_all = [];
                state.spc.internal.image_all(memorysize1) = 0.0;
                [out1, state.spc.internal.image_all]=calllib(state.spc.init.dllname,'SPC_read_data_page',state.spc.acq.module, state.spc.acq.page, state.spc.acq.page, state.spc.internal.image_all);
                if (out1~=0)
                    error1 = FLIM_get_error_string (out1);    
                    disp(['error during reading data:', error1]);
                    return;
                end

                if (~state.spc.acq.spc_average && state.spc.init.infinite_Nframes)
                    image1 = state.spc.internal.image_all;
                else
                    image1 = state.spc.internal.image_all;
                end
  %%              
%         if state.spc.acq.page == 0
%                 nPage =ceil(state.acq.numberOfPages / state.acq.numberOfBinPages);
%                 nPage = 2^ceil(log2(nPage));
%                 memorysize1 = memorysize * nPage;
%                 state.spc.internal.image_all = [];
%                 state.spc.internal.image_all(memorysize1) = 0.0;
%                 [out1, state.spc.internal.image_all]=calllib(state.spc.init.dllname,'SPC_read_data_page',state.spc.acq.module, 0, nPage-1, state.spc.internal.image_all);
%                 sum(state.spc.internal.image_all(:));
%                 state.spc.internal.image_all = reshape(state.spc.internal.image_all, memorysize, nPage);
%                 out1 = 0;
%                 image1 = state.spc.internal.image_all(:,state.spc.acq.page+1);
%         else
%             out1 = 0;
%             image1 = state.spc.internal.image_all(:,state.spc.acq.page+1);
%         end
    elseif (~state.spc.acq.spc_average && ~state.spc.init.infinite_Nframes) 
        %%%%Frame
        if state.spc.acq.page == 0
                state.spc.internal.image_all = [];
                state.spc.internal.image_all(memorysize) = 0.0;
                pause(0.5);
                [out1, state.spc.internal.image_all]=calllib(state.spc.init.dllname,'SPC_read_data_page',state.spc.acq.module, 0, 0, state.spc.internal.image_all);
                if (out1~=0)
                    error1 = FLIM_get_error_string (out1);    
                    disp(['error during reading data:', error1]);
                    return;
                end
                NFrames = 2^ceil(log2(state.acq.numberOfFrames));
                state.spc.internal.image_all = reshape(state.spc.internal.image_all, memorysize/NFrames, NFrames);
                out1 = 0;
                image1 = state.spc.internal.image_all(:,state.spc.acq.page+1);
        else
            image1 = 1;
        end    
    else
        %tic
        [out1, image1]=calllib(state.spc.init.dllname,'SPC_read_data_page',state.spc.acq.module, 0, 0, image1);
        %toc
%         dia.test.image1=image1;
        if (out1~=0)
            error1 = FLIM_get_error_string (out1);    
            disp(['error during reading data:', error1]);
            return;
        end
        state.spc.internal.image_all = image1;
    end
%end
%[out1 image1]=calllib(state.spc.init.dllname,'SPC_read_data_frame',state.spc.acq.module,frame,state.spc.acq.page,image1);

if sum(image1(:)) == 0 && ~focus
    disp('*********** ERROR ************');
    disp(['***********Page: ', num2str(state.spc.acq.page+1), '************']);
    disp(['NO DATA']);
    error1 = 1;
    %return;
end
if state.acq.numberOfPages > 1
    spc.datainfo.multiPages.timing = state.spc.acq.timing;
    spc.datainfo.multiPages.nPages = state.acq.numberOfPages;
    spc.datainfo.multiPages.page = state.spc.acq.page;
    spc.page = state.spc.acq.page;
end

if dia.acq.doRibbonTransform
    state.spc.acq.SPCdata.scan_size_y = state.acq.linesPerFrame;
    state.spc.acq.SPCdata.scan_size_x = state.acq.pixelsPerLine;
end
scan_size_y = state.spc.acq.SPCdata.scan_size_y * frames_per_page;
scan_size_x = state.spc.acq.SPCdata.scan_size_x;
res = 2^state.spc.acq.SPCdata.adc_resolution;


spc.SPCdata = state.spc.acq.SPCdata;
%spc.size = [res, scan_size_x, scan_size_y];
spc.size = [res, scan_size_y, scan_size_x];
spc.switches.peak = [-1, 4];
try 
    limit = spc.switches.lifetime_limit; 
catch
    limit = [2.4, 3.4];
end
try 
    range = spc.fit.range; 
catch
    range = [1, res];
end
spc.switches.lifetime_limit = limit;
%spc.fit.background = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%Note the permutation!!%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (~state.spc.acq.spc_average) && ~focus
    if ~state.spc.init.infinite_Nframes
        %%%%Not used anymore%%%%%DELETE%%%%%%%%%
%         scan_size_y = scan_size_y / state.acq.numberOfFrames;
%         spc.SPCdata.scan_size_y = scan_size_y;
% 
%         if state.spc.acq.page == 0
%             NFrames = 2^ceil(log2(state.acq.numberOfFrames));
%             spc.imageModStack = reshape(state.spc.internal.image_all, res, scan_size_x, scan_size_y, NFrames);
%             spc.imageModStack = double(permute(spc.imageModStack, [1,3,2,4]));
%         end
%         image1 = spc.imageModStack(:,:,:,state.spc.acq.page+1);
    else
        image1 = (reshape(image1, res, scan_size_x, scan_size_y));
        scan_size_y0 = scan_size_y / frames_per_page;
        scan_size_y = round(scan_size_y / state.spc.init.numSlicesPerFrames / frames_per_page);
        image_line = [];
        for colorN = 1:frames_per_page
            start_line = scan_size_y0*(colorN-1) + 1;
            end_line = start_line + scan_size_y - 1;
            image_line = [image_line, start_line:end_line];
        end
        image1 = image1(:, :, image_line);
        image1 = double(permute(image1, [1,3,2]));
        spc.SPCdata.scan_size_y = scan_size_y;
    end
elseif dia.acq.doRibbonTransform
    dia.acq.ribbon.originalFLIMimage=image1;
    image1=image1(dia.acq.ribbon.FLIMworkingPixels(:));
    image1=image1(1:dia.acq.ribbon.FLIMworkingPixelLength);
    temp1=dia.acq.ribbon.FLIMblankCanvas;
    temp1(dia.acq.ribbon.FLIMpixelIndex)=image1;
    image1=temp1;
    image1=double(permute(image1,[3,1,2]));
else
    image1 = (reshape(image1, res, scan_size_x, scan_size_y));
    image1 = double(permute(image1, [1,3,2]));
end
%%%%%%%%%%%%%%%%%%%%%%%%%Note the permutation!!%%%%%%%%%%%%%%%%%%%%%%%%%%%


if redraw || focus
    spc.project = reshape(sum(image1, 1), scan_size_y, scan_size_x);
end

if 1 %~focus
    spc.lifetime= sum(sum(image1, 2),3);
    spc.switches.imagemode = 1;
    spc.switches.logscale = 1;
    spc.fit(gui.spc.proChannel).range = range;
    spc.datainfo.time = datestr(clock, 13);
    spc.datainfo.date = datestr(clock, 1);
    spc.datainfo.cfd_ll = state.spc.acq.SPCdata.cfd_limit_low;
    spc.datainfo.cfd_lh = state.spc.acq.SPCdata.cfd_limit_high;
    spc.datainfo.cfd_zc = state.spc.acq.SPCdata.cfd_zc_level;
    spc.datainfo.cfd_hf = state.spc.acq.SPCdata.cfd_holdoff;
    spc.datainfo.syn_th = state.spc.acq.SPCdata.sync_threshold;
    spc.datainfo.syn_zc = state.spc.acq.SPCdata.sync_zc_level;
    spc.datainfo.syn_fd = state.spc.acq.SPCdata.sync_freq_div;
    spc.datainfo.syn_hf = state.spc.acq.SPCdata.sync_holdoff;
    spc.datainfo.scan_x = scan_size_x;
    spc.datainfo.scan_y = scan_size_y;
    spc.datainfo.col_t = state.spc.acq.SPCdata.collect_time;
    spc.datainfo.pix_time =state.spc.acq.SPCdata.pixel_time;
    spc.datainfo.incr = state.spc.acq.SPCdata.count_incr;
    spc.datainfo.dither = state.spc.acq.SPCdata.dither_range;
    spc.datainfo.tac_of =state.spc.acq.SPCdata.tac_offset;
    spc.datainfo.tac_ll =state.spc.acq.SPCdata.tac_limit_low;
    spc.datainfo.taclh = state.spc.acq.SPCdata.tac_limit_high;
    spc.datainfo.tac_r = state.spc.acq.SPCdata.tac_range*1e-9;
    spc.datainfo.tac_g = state.spc.acq.SPCdata.tac_gain;
    spc.datainfo.adc_re = res;
    try
        spc.datainfo.triggerTime = state.spc.acq.triggerTime;
    catch
        spc.datainfo.triggerTime = datestr(now);
    end
    spc.datainfo.psPerUnit = spc.datainfo.tac_r/spc.datainfo.tac_g/spc.datainfo.adc_re*1e12;
    %spc.datainfo.pulseInt = 1/spc.datainfo.pulseRate*1e9;

    spc.imageMod = image1; 
end

% 
if state.internal.zSliceCounter == 1 || state.internal.usePage || ~state.spc.acq.spc_average
    spc.stack.image1 = {};
    spc.stack.image1{1} = spc.imageMod;
    set(gui.spc.spc_main.spc_page, 'String', '1')
else
    spc.stack.image1{state.internal.zSliceCounter} = spc.imageMod;
    set(gui.spc.spc_main.spc_page, 'String', num2str([1:state.internal.zSliceCounter]))
end

%

% addToAF; %MISHA

if redraw
    spc_redrawSetting(1,1); %Fast redraw
end