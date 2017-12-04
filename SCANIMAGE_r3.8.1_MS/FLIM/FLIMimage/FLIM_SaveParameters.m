function result = FLIM_SaveParameters(hObject,handles)
global state

% SPCdata.mode
if ~strcmp(state.spc.init.dllname, 'TH260lib')
    handles.SPCdata.mode=get(handles.popupmenu1,'Value')-1;
else
    handles.SPCdata.mode=get(handles.popupmenu1,'Value');
end
%handles.SPCdata.mode=str2num(get(handles.edit31,'String'));

% SPCdata.stop_on_ovfl
handles.SPCdata.stop_on_ovfl=get(handles.edit22,'Value');
%handles.SPCdata.stop_on_ovfl=str2num(get(handles.edit22,'String'));

% SPCdata.stop_on_time
handles.SPCdata.stop_on_time=get(handles.edit21,'Value');
%handles.SPCdata.stop_on_time=str2num(get(handles.edit21,'String'));

% SPCdata.adc_resolution
if ~strcmp(state.spc.init.dllname, 'TH260lib')
    switch get(handles.popupmenu2,'Value')
        case 1
            handles.SPCdata.adc_resolution=6;
        case 2
            handles.SPCdata.adc_resolution=8;
        case 3
            handles.SPCdata.adc_resolution=10;
        case 4
            handles.SPCdata.adc_resolution=12;
        case 5
            handles.SPCdata.adc_resolution=0;
        case 6
            handles.SPCdata.adc_resolution=2;
        case 7
            handles.SPCdata.adc_resolution=4;
    end
    state.spc.acq.resolution = handles.SPCdata.adc_resolution;
else
    handles.SPCdata.adc_resolution = get(handles.popupmenu2,'Value')*64;
end


%handles.SPCdata.adc_resolution=str2num(get(handles.edit16,'String'));

% SPCdata.dither_range
switch get(handles.popupmenu3,'Value')
    case 1
        handles.SPCdata.dither_range=0;
    case 2
        handles.SPCdata.dither_range=32;
    case 3
        handles.SPCdata.dither_range=64;
    case 4
        handles.SPCdata.dither_range=128;
    case 5
        handles.SPCdata.dither_range=256;
end
%handles.SPCdata.dither_range=str2num(get(handles.edit23,'String'));

% SPCdata.count_incr
handles.SPCdata.count_incr=str2num(get(handles.edit24,'String'));

% SPCdata.collect,repeat,display_time
handles.SPCdata.collect_time=str2num(get(handles.edit18,'String'));
handles.SPCdata.repeat_time=str2num(get(handles.edit20,'String'));
handles.SPCdata.display_time=str2num(get(handles.edit19,'String'));

% SPCdata.dead_time_comp
handles.SPCdata.dead_time_comp=get(handles.edit26,'Value');
%handles.SPCdata.dead_time_comp=str2num(get(handles.edit26,'String'));




%handles.SPCdata.base_adr=str2num(get(handles.edit1,'String'));
%handles.SPCdata.init=str2num(get(handles.edit2,'String'));
handles.SPCdata.cfd_limit_low=str2num(get(handles.edit3,'String'));
%handles.SPCdata.cfd_limit_high=str2num(get(handles.edit4,'String'));
handles.SPCdata.cfd_zc_level=str2num(get(handles.edit5,'String'));
%handles.SPCdata.cfd_holdoff=str2num(get(handles.edit6,'String'));
handles.SPCdata.sync_zc_level=str2num(get(handles.edit7,'String'));
handles.SPCdata.sync_holdoff=str2num(get(handles.edit8,'String'));
handles.SPCdata.sync_threshold=str2num(get(handles.edit9,'String'));
handles.SPCdata.tac_range=str2num(get(handles.edit10,'String'));
handles.SPCdata.sync_freq_div=str2num(get(handles.edit11,'String'));
handles.SPCdata.tac_gain=str2num(get(handles.edit12,'String'));
handles.SPCdata.tac_offset=str2num(get(handles.edit13,'String'));
handles.SPCdata.tac_limit_low=str2num(get(handles.edit14,'String'));
handles.SPCdata.tac_limit_high=str2num(get(handles.edit15,'String'));
handles.SPCdata.ext_latch_delay=str2num(get(handles.edit17,'String'));
%handles.SPCdata.mem_bank=str2num(get(handles.edit25,'String'));
handles.SPCdata.scan_control=str2num(get(handles.edit27,'String'));
handles.SPCdata.routing_mode=str2num(get(handles.edit28,'String'));
handles.SPCdata.tac_enable_hold=str2num(get(handles.edit29,'String'));
%handles.SPCdata.pci_card_no=str2num(get(handles.edit30,'String'));
handles.SPCdata.test_eep=str2num(get(handles.edit32,'String'));
handles.SPCdata.scan_size_x=str2num(get(handles.edit33,'String'));
handles.SPCdata.scan_size_y=str2num(get(handles.edit34,'String'));
handles.SPCdata.scan_rout_x=str2num(get(handles.edit35,'String'));
handles.SPCdata.scan_rout_y=str2num(get(handles.edit36,'String'));
handles.SPCdata.scan_polarity=str2num(get(handles.edit37,'String'));
handles.SPCdata.scan_flyback=str2num(get(handles.edit38,'String'));
handles.SPCdata.scan_borders=str2num(get(handles.edit39,'String'));
handles.SPCdata.pixel_clock=str2num(get(handles.edit40,'String'));
handles.SPCdata.line_compression=str2num(get(handles.edit41,'String'));
handles.SPCdata.trigger=str2num(get(handles.edit42,'String'));
handles.SPCdata.pixel_time=str2num(get(handles.edit43,'String'))*1e-6;
handles.SPCdata.ext_pixclk_div=str2num(get(handles.edit44,'String'));
handles.SPCdata.rate_count_time=str2num(get(handles.edit45,'String'));
%handles.SPCdata.macro_time_clk=str2num(get(handles.edit46,'String'));
handles.SPCdata.add_select=str2num(get(handles.edit47,'String'));
%handles.SPCdata.adc_zoom=str2num(get(handles.edit48,'String'));

if strcmp(state.spc.init.dllname, 'TH260lib')
    state.spc.acq.SPCdata = handles.SPCdata;
    FLIM_setParameters;
    FLIM_FillParameters(handles);
else
    guidata(hObject,handles);
    FLIM_setParameters(handles);
    handles=FLIM_getParameters(hObject,handles);
    guidata(hObject,handles);
    FLIM_FillParameters(handles);
end
result = handles;
