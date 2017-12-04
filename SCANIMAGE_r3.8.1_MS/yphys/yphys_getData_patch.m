function yphys_getData_patch(~, evnt)
global state;
global gh;

%data1 = evnt.data;
%evnt
data1 = state.yphys.init.phys_inputPatch.readAnalogData();

% if get(state.yphys.init.phys_input, 'SamplesAvailable') >= get(state.yphys.init.phys_input, 'SamplesPerTrigger')
%     data1 = getdata(state.yphys.init.phys_input);

if ~isempty(data1)
    if state.yphys.acq.cclamp
        gain = state.yphys.acq.gainC;
    else
        gain = state.yphys.acq.gainV;
    end
	rate = state.yphys.acq.inputRate;
    data2 = data1(:, 1)/gain;
    t = 1:length(data2);
	%plot(t/rate*1000, data2);
    if ishandle(gh.yphys.patchPlot)
        if ~state.yphys.internal.fft_on
    	    set(gh.yphys.patchPlot, 'XData', t/rate*1000, 'YData', data2);
            set(gh.yphys.scope.trace, 'XlimMode', 'auto');
        else
%             l1 = length(data2);
%             l2 = 2^floor(log(l1)/log(2));
            l2 = length(data2);
            a1 = abs(fft(data2(1:l2)));
            f1 = (0:length(a1)-1)*state.yphys.acq.inputRate/l2;
            range = 2:round(l2/2);
            set(gh.yphys.patchPlot, 'XData', f1(range), 'YData', a1(range));
            set(gh.yphys.scope.trace, 'Xlim', [0, 600]);
        end
    else
        %yphys_patch;% stop function
    end
    state.yphys.acq.data = [t(:)/rate*1000, data2(:)];
    yphys_updateGUI;
    %catch
else
    %disp('XXX');
end

   stop(state.yphys.init.phys_input);