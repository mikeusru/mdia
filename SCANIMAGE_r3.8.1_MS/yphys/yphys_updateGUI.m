function yphys_updateGUI
global gh;
global state;

% try
%     yphys_getGain;
% end

try
    set(gh.yphys.scope.vamp, 'String', num2str(state.yphys.acq.vamplitude));
    set(gh.yphys.scope.camp, 'String', num2str(state.yphys.acq.camplitude));
    set(gh.yphys.scope.vperiod, 'String', num2str(state.yphys.acq.vperiod));
    set(gh.yphys.scope.cperiod, 'String', num2str(state.yphys.acq.cperiod));
    
    
	set(gh.yphys.scope.vwidth, 'String', num2str(state.yphys.acq.vwidth));
    set(gh.yphys.scope.cwidth, 'String', num2str(state.yphys.acq.cwidth));
    set(gh.yphys.scope.fft, 'Value', state.yphys.internal.fft_on);
catch
end

% if ~state.yphys.acq.cclamp
%     set(gh.yphys.scope.cwidth, 'enable', 'off');
%     set(gh.yphys.scope.camp, 'enable', 'off');
%     set(gh.yphys.scope.cperiod, 'enable', 'off');
% else
%     set(gh.yphys.scope.cwidth, 'enable', 'on');
%     set(gh.yphys.scope.camp, 'enable', 'on');
%     set(gh.yphys.scope.cperiod, 'enable', 'on');
% end

try
    value = get(gh.yphys.scope.AutoS, 'Value');
    if value
        set(gh.yphys.scope.trace, 'YLimMode', 'Auto')
    else
        set(gh.yphys.scope.trace, 'YLimMode', 'Manual')
    end
end

%axtick = get(gca, 'XTick');  aytick = get(gca, 'YTick');
%plot(state.yphys.acq.data(:,1), state.yphys.acq.data(:, 2));  
%set(gca, 'ButtonDownFcn', 'yphys_Patch');

try
	if ~state.yphys.acq.cclamp
			data2 = state.yphys.acq.data(:, 2);
			factor = state.yphys.acq.inputRate/1000; %millisecond
			bstart = 1;
			bend = round(state.yphys.acq.vphase(1)*0.95*factor);
            min_pos = round(state.yphys.acq.vphase(1)*factor);
            max_pos = round((state.yphys.acq.vphase(1)+state.yphys.acq.vphase(2))*factor);
            
            rstart = max_pos - 20*factor;
            rend = max_pos - 5*factor;
            
            rsstart = min_pos - 2*factor;
            rsend = min_pos + 2*factor;
            if state.yphys.acq.vamplitude < 0            
                [peak, index] = min(data2(rsstart:rsend));
            else
                [peak, index] = max(data2(rsstart:rsend));
            end
            pulse = mean(data2(rstart:rend));
            base = mean(data2(bstart:bend));
            cchange = pulse-base;
            cschange = peak-base;
            if abs(cchange) > 0
                rinput = state.yphys.acq.vamplitude/cchange*1000; %mV/pA*1000 --- MOhm.
            else
                rinput = 0;
            end
            if abs(cschange) > 0
                rseriese = state.yphys.acq.vamplitude/cschange*1000; %mV/pA*1000 --- MOhm.
            else
                rseriese = 0;
            end

            if state.yphys.acq.vamplitude < 0  
                r=find(data2(rsstart:rend) < pulse-((pulse-peak)/exp(1)));
            else
                r=find(data2(rsstart:rend) > pulse-((pulse-peak)/exp(1)));
            end
            tau = length(r)/factor;
            if (rseriese*rinput) > 0
                Cm=(rseriese+rinput)*1000*tau/(rseriese*rinput);
            else
                Cm = 0;
            end
            state.yphys.acq.Cm = Cm;
            state.yphys.acq.rinput = rinput;
            state.yphys.acq.rseriese = rseriese;
            
            
            set(gh.yphys.scope.rin, 'String', num2str(rinput));
            set(gh.yphys.scope.rs, 'String', num2str(rseriese));
            set(gh.yphys.scope.cm, 'String', num2str(Cm));
    else
            set(gh.yphys.scope.rin, 'String', 'NAN');
            set(gh.yphys.scope.rs, 'String', 'NAN');
            set(gh.yphys.scope.cm, 'String', 'NAN');
        
    end
 end