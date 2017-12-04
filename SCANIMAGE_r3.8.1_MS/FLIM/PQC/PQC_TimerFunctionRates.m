function PQC_TimerFunctionRates

global state spc gh

    if ~state.spc.internal.ifstart
		data.sync_rate=0;
        data.ch_rate = zeros(1, state.spc.acq.SPCdata.n_channels);

%             Syncrate = 0;
%             SyncratePtr = libpointer('int32Ptr', Syncrate);
%             [~, Syncrate] = calllib('TH260lib', 'TH260_GetSyncRate', state.spc.acq.module, SyncratePtr);
%             data.sync_rate = Syncrate;
%             
%             for i=0:state.spc.acq.SPCdata.n_channels-1              
%                 Countrate = 0;
%                 CountratePtr = libpointer('int32Ptr', Countrate);
%                 [~, Countrate] = calllib('TH260lib', 'TH260_GetCountRate', state.spc.acq.module, i, CountratePtr);
%                 data.ch_rate(i+1) = Countrate;
%             end;
        [ret, data] = state.spc.internal.hPQ.getRates;
        if ret < 0
            disp('RESET PicoQuant card!!');
        end

        if data.sync_rate > 1e6
    		spc.datainfo.pulseRate = data.sync_rate;
            spc.datainfo.pulseInt = 1/double(spc.datainfo.pulseRate)*1e9;
        end
        spc.datainfo.darkCount = data.ch_rate;
        
		datas.sync_rate=strrep(sprintf('%.3e',data.sync_rate),'e+00',' e+');
		datas.ch1_rate=strrep(sprintf('%.3e',data.ch_rate(1)),'e+00',' e+');
		datas.ch2_rate=strrep(sprintf('%.3e',data.ch_rate(2)),'e+00',' e+');
		
		globalHandles = gh.spc.pq_parameters;
		set(globalHandles.st_sync_rate,'String',datas.sync_rate);
		set(globalHandles.st_ch_rate1,'String',datas.ch1_rate);
		set(globalHandles.st_ch_rate2,'String',datas.ch2_rate);
        
    end


