function FLIM_TimerFunctionRates

global state spc gh

%if state.spc.acq.spc_image
    if ~state.spc.internal.ifstart
    	%data=libstruct('s_rate_values');
		data.sync_rate=0;
        data.cfd_rate=0;
        data.tac_rate=0;
        data.adc_rate=0;
        if strfind(state.spc.init.dllname, 'spcm')
            [out1, data]=calllib(state.spc.init.dllname,'SPC_read_rates',state.spc.acq.module,data);
        elseif strcmp(state.spc.init.dllname, 'TH260lib')
            Syncrate = 0;
            SyncratePtr = libpointer('int32Ptr', Syncrate);
            [ret, Syncrate] = calllib('TH260lib', 'TH260_GetSyncRate', state.spc.acq.module, SyncratePtr);
            data.sync_rate = Syncrate;
            
            for i=0:state.spc.acq.SPCdata.n_channels-1              
                Countrate = 0;
                CountratePtr = libpointer('int32Ptr', Countrate);
                [ret, Countrate] = calllib('TH260lib', 'TH260_GetCountRate', state.spc.acq.module, i, CountratePtr);
                if i == 0
                    data.cfd_rate = Countrate;
                elseif i == 1
                    data.tac_rate = Countrate;
                end
                
            end;
            
        end
        if data.sync_rate > 1e6
    		spc.datainfo.pulseRate = data.sync_rate;
            spc.datainfo.pulseInt = 1/double(spc.datainfo.pulseRate)*1e9;
        end
        
		datas.sync_rate=strrep(sprintf('%.3e',data.sync_rate),'e+00',' e+');
		datas.cfd_rate=strrep(sprintf('%.3e',data.cfd_rate),'e+00',' e+');
		datas.tac_rate=strrep(sprintf('%.3e',data.tac_rate),'e+00',' e+');
		datas.adc_rate=strrep(sprintf('%.3e',data.adc_rate),'e+00',' e+');
		
		globalHandles = gh.spc.FLIMimage;
		set(globalHandles.edit2,'String',datas.sync_rate);
		set(globalHandles.edit3,'String',datas.cfd_rate);
		set(globalHandles.edit4,'String',datas.tac_rate);
		set(globalHandles.edit5,'String',datas.adc_rate);
        
        %
        try
            if state.spc.init.infinite_Nframes
                if strcmp(state.spc.init.dllname, 'TH260lib')
                    div = 1;
                else
                    div = state.spc.init.numSlicesPerFrames;
                end
                 set(gh.spc.FLIMimage.frameRate, 'String', sprintf('%0.2f Hz', 1 / (state.acq.linesPerFrame*state.acq.msPerLine/1000) / div));
            else
                set(gh.spc.FLIMimage.frameRate, 'String', sprintf('%0.2f Hz', 1 / (state.acq.linesPerFrame*state.acq.msPerLine/1000)));
            end
        end
        
        try
            yphys_pageControls('etPageInterval_Callback',gh.yphys.yphys_pageControls.etPageInterval,[],guidata(gh.yphys.yphys_pageControls.etPageInterval));
        end
    end
%end


