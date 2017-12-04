function FLIM_FillParameters(handles)
global state

p=mfilename('fullpath'); %MISHA - Load settings from spcm_ry.ini in current FLIMimage directory
[path,~,~]=fileparts(p);

if strcmp(state.spc.init.dllname, 'TH260lib')
    set(handles.popupmenu1,'String',{'Histo', 'TTTR2', 'TTTR3'});
    set(handles.edit3,'String',sprintf('%.2f',state.spc.acq.SPCdata.cfd_limit_low(1)));
    set(handles.edit9,'String',sprintf('%.2f',state.spc.acq.SPCdata.sync_threshold));
    set(handles.edit11,'String',sprintf('%d', state.spc.acq.SPCdata.sync_freq_div));
    set(handles.edit5,'String',sprintf('%.2f',state.spc.acq.SPCdata.cfd_zc_level(1)));
    set(handles.edit7,'String',sprintf('%.2f',state.spc.acq.SPCdata.sync_zc_level));
    if state.spc.acq.SPCdata.mode <= 0 || state.spc.acq.SPCdata.mode > 3
        state.spc.acq.SPCdata.mode = 3;
    end
    set(handles.popupmenu1,'Value',state.spc.acq.SPCdata.mode);
    
%     try
%         Resolution = 0;
%         ResolutionPtr = libpointer('doublePtr', Resolution);
%         [ret, Resolution] = calllib('TH260lib', 'TH260_GetResolution', state.spc.acq.module, ResolutionPtr);
%     catch
%         Resolution = 250;
%     end
%     set(handles.popupmenu2, 'string', sprintf('%d ps', Resolution));
%     state.spc.acq.resolution = Resolution;
else
    % SPCdata.mode
    if (handles.SPCdata.mode>=0)&(handles.SPCdata.mode<=3)
        set(handles.popupmenu1,'Value',handles.SPCdata.mode+1);
    else
        set(handles.popupmenu1,'String','???');
    end
    %set(handles.edit31,'String',sprintf('%.10f',handles.SPCdata.mode));

    % SPCdata.stop_on_ovfl
    switch handles.SPCdata.stop_on_ovfl
        case 0
            set(handles.edit22,'Value',0);
        case 1
            set(handles.edit22,'Value',1);
    end
    %set(handles.edit22,'String',sprintf('%.10f',handles.SPCdata.stop_on_ovfl));

    % SPCdata.stop_on_time
    switch handles.SPCdata.stop_on_time
        case 0
            set(handles.edit21,'Value',0);
        case 1
            set(handles.edit21,'Value',1);
    end
    %set(handles.edit21,'String',sprintf('%.10f',handles.SPCdata.stop_on_time));

    % SPCdata.adc_resolution
    switch handles.SPCdata.adc_resolution
        case 6
            set(handles.popupmenu2,'Value',1);
        case 8
            set(handles.popupmenu2,'Value',2);    
        case 10
            set(handles.popupmenu2,'Value',3);
        case 12
            set(handles.popupmenu2,'Value',4);
    end
    %set(handles.edit16,'String',sprintf('%i',handles.SPCdata.adc_resolution));

    % SPCdata.dither_range
    switch handles.SPCdata.dither_range
        case 0
            set(handles.popupmenu3,'Value',1);
        case 32
            set(handles.popupmenu3,'Value',2);
        case 64
            set(handles.popupmenu3,'Value',3);
        case 128
            set(handles.popupmenu3,'Value',4);
        case 256
            set(handles.popupmenu3,'Value',5);
    end
    %set(handles.edit23,'String',sprintf('%.10f',handles.SPCdata.dither_range));

    % SPCdata.count_incr
    set(handles.edit24,'String',sprintf('%i',handles.SPCdata.count_incr));
    %set(handles.slider24,'Value',handles.SPCdata.count_incr);

    % SPCdata.collect,repeat,display_time
    set(handles.edit18,'String',sprintf('%.2f',handles.SPCdata.collect_time));
    set(handles.edit20,'String',sprintf('%.2f',handles.SPCdata.repeat_time));
    set(handles.edit19,'String',sprintf('%.2f',handles.SPCdata.display_time));

    % SPCdata.dead_time_comp
    switch handles.SPCdata.dead_time_comp
        case 0
            set(handles.edit26,'Value',0);
        case 1
            set(handles.edit26,'Value',1);
    end
    %set(handles.edit26,'String',sprintf('%.10f',handles.SPCdata.dead_time_comp));





    %set(handles.edit1,'String',sprintf('%.10f',handles.SPCdata.base_adr));
    %set(handles.edit2,'String',sprintf('%.10f',handles.SPCdata.init));
    set(handles.edit3,'String',sprintf('%.2f',handles.SPCdata.cfd_limit_low-0.01));
    %set(handles.edit4,'String',sprintf('%.10f',handles.SPCdata.cfd_limit_high));
    set(handles.edit5,'String',sprintf('%.2f',handles.SPCdata.cfd_zc_level));
    %set(handles.edit6,'String',sprintf('%.10f',handles.SPCdata.cfd_holdoff));
    set(handles.edit7,'String',sprintf('%.2f',handles.SPCdata.sync_zc_level));
    set(handles.edit8,'String',sprintf('%.2f',handles.SPCdata.sync_holdoff));
    set(handles.edit9,'String',sprintf('%.2f',handles.SPCdata.sync_threshold));
    set(handles.edit10,'String',sprintf('%.2f',handles.SPCdata.tac_range));
    set(handles.edit11,'String',sprintf('%d',handles.SPCdata.sync_freq_div));
    set(handles.edit12,'String',sprintf('%.2f',handles.SPCdata.tac_gain));
    set(handles.edit13,'String',sprintf('%.2f',handles.SPCdata.tac_offset));
    set(handles.edit14,'String',sprintf('%.2f',handles.SPCdata.tac_limit_low));
    set(handles.edit15,'String',sprintf('%.2f',handles.SPCdata.tac_limit_high));
    set(handles.edit17,'String',sprintf('%.2f',handles.SPCdata.ext_latch_delay));
    %set(handles.edit25,'String',sprintf('%.10f',handles.SPCdata.mem_bank));
    set(handles.edit27,'String',sprintf('%.2f',handles.SPCdata.scan_control));
    set(handles.edit28,'String',sprintf('%.2f',handles.SPCdata.routing_mode));
    set(handles.edit29,'String',sprintf('%.2f',handles.SPCdata.tac_enable_hold));
    %set(handles.edit30,'String',sprintf('%.10f',handles.SPCdata.pci_card_no));
    set(handles.edit32,'String',sprintf('%.2f',handles.SPCdata.test_eep));
    set(handles.edit33,'String',sprintf('%d',handles.SPCdata.scan_size_x));
    set(handles.edit34,'String',sprintf('%d',handles.SPCdata.scan_size_y));
    set(handles.edit35,'String',sprintf('%d',handles.SPCdata.scan_rout_x));
    set(handles.edit36,'String',sprintf('%d',handles.SPCdata.scan_rout_y));
    set(handles.edit37,'String',sprintf('%d',handles.SPCdata.scan_polarity));
    set(handles.edit38,'String',sprintf('%d',handles.SPCdata.scan_flyback));
    set(handles.edit39,'String',sprintf('%d',handles.SPCdata.scan_borders));
    set(handles.edit40,'String',sprintf('%d',handles.SPCdata.pixel_clock));
    set(handles.edit41,'String',sprintf('%d',handles.SPCdata.line_compression));
    set(handles.edit42,'String',sprintf('%d',handles.SPCdata.trigger));
    set(handles.edit43,'String',sprintf('%.2f',handles.SPCdata.pixel_time*1e6));
    set(handles.edit44,'String',sprintf('%d',handles.SPCdata.ext_pixclk_div));
    set(handles.edit45,'String',sprintf('%d',handles.SPCdata.rate_count_time));
    %set(handles.edit46,'String',sprintf('%.10f',handles.SPCdata.macro_time_clk));
    set(handles.edit47,'String',sprintf('%d',handles.SPCdata.add_select));
    %set(handles.edit48,'String',sprintf('%.10f',handles.SPCdata.adc_zoom));
end

SPCdata = state.spc.acq.SPCdata;
save([path, filesep, 'spc_init.mat'], 'SPCdata');
