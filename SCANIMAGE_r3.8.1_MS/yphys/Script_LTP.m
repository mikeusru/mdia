function [time_aq, peak1, RI, RS] = Script_LTP(num, LTPn)


delay = 200; %millisecond. time of stimulation.
windowSize = 1; %millisecond around the peak
signalStart = 1;
signalEnd =50; %millisecond after stimulation.
%maxS = 100; %pA. Ignore signal larger than this.

%testPulseN = 57; %protocol number for test pulse.

baseStart = -20;
baseEnd = -2;

time_aq = [];
peak1 = [];
%fname = dir('yphys*.mat');


figure; 
hold on;
for i=1:length(num)
    %fn = fname(i).name;
    fn = sprintf('yphys%03d.mat', num(i));
    load(fn);
    finfo1 = dir(fn);
    time_aq(i) = finfo1(1).datenum;
    evalc(['yphys=', fn(1:end-4)]);
    
%     if yphys.pulseN == testPulseN
        ws = windowSize * yphys.inputRate/1000;
        time1 = yphys.data(:, 1);
        data1 = yphys.data(:, 2);

        signal_start = (delay+signalStart)*yphys.inputRate/1000;
        signal_end = (delay + signalEnd)*yphys.inputRate/1000;
        base_start = (delay + baseStart)*yphys.inputRate/1000;
        base_end = (delay + baseEnd)*yphys.inputRate/1000;

        data1 = data1 - mean(data1(base_start:base_end));    
        data2 = imfilter(data1(signal_start:signal_end), ones(ws, 1)/ws, 'replicate');
        peak1(i) = -min(data2);

        %Resitance
        pulseP = yphys.pulse{1, yphys.pulseN};
        v_amplitude = pulseP.amp;
        if abs(v_amplitude) > 0 && pulseP.nstim >= 1 && pulseP.dwell > 10
            RTest_bstart = (pulseP.delay-100) *yphys.inputRate/1000;
            RTest_bend = (pulseP.delay-5) *yphys.inputRate/1000;
            RTest_RSstart = (pulseP.delay-1) *yphys.inputRate/1000;
            RTest_RSend = (pulseP.delay+10) *yphys.inputRate/1000;
            RTest_RIstart = (pulseP.delay + pulseP.dwell -10)*yphys.inputRate/1000;
            RTest_RIend = (pulseP.delay + pulseP.dwell -1)*yphys.inputRate/1000;

            ccharge = (mean(data1(RTest_RIstart:RTest_RIend)) - mean(data1(RTest_bstart:RTest_bend)));

            if v_amplitude <= 0
                csharge = (min(data1(RTest_RSstart:RTest_RSend)) - mean(data1(RTest_bstart:RTest_bend)));
            else
                csharge = (max(data1(RTest_RSstart:RTest_RSend)) - mean(data1(RTest_bstart:RTest_bend)));
            end
            RI(i) = abs(v_amplitude) / abs(ccharge) * 1000;
            RS(i) = abs(v_amplitude) / abs(csharge) * 1000;
        else
            RI(i) = nan;
            RS(i) = nan;
        end
        
        time2 = time1(signal_start:signal_end);
        if num(i) > LTPn
            plot(time2, data2,'-r');
        else
            plot(time2, data2, '-b');
        end
        pause(0.01);
        %ylim([-5, maxS]);
%     else
%         afterLTP = 1;
%         LTPS = i;
%         peak1(i) = nan;
%     end
end

%peak1(peak1 > maxS) = nan;
figure; 
time_aq = (time_aq - time_aq(1))*60*24;

plot(time_aq(num < LTPn), peak1(num < LTPn), '-ob');
hold on;
plot(time_aq(num > LTPn), peak1(num > LTPn), '-or');

