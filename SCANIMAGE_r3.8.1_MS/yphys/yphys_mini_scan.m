function [peak_pos, peak_amp, base_amp] = yphys_mini_scan (yphys);

tau1 = 2;
tau2 = 8;
scanW = 10;
deltat = 0.2;

filterW = 10;
disp('Prescanning ...');
[peak_pos, peak_amp, base_amp] = yphys_mini_preScan (yphys, tau1, tau2, filterW);
peak_pos

disp('scanning ...');
data1 = yphys.data(:,2);
data1 = data1(:)';

%deltat = 1/yphys.inputRate*1000;
if yphys.inputRate == 10000
    data1 = mean(reshape(data1, 2, length(data1)/2), 1);
end

template = yphys_mini_makeTemplate(tau1,tau2, 0, deltat);
npt = length(template);

%ndata_r = 50000;
ndata_r = length(data1)-npt;
scaleB = sum(template.^2) - sum(template) * sum(template) / npt;
%for i=1:length(data1)- npt;

for j=1:length(peak_pos)
    for i=peak_pos(j) - scanW : peak_pos(j) + scanW
        data2 = data1(i:i+npt-1);
        scaleU = sum(template.*data2) - sum(template)*sum(data2)/npt;
        scale1 = scaleU / scaleB;
        offset1 = mean(data2) - scale1 * mean(template);
        fitted_temp = template*scale1 + offset1;
        sse1 = sum((data2 - fitted_temp).^2);
        sse1 = sqrt(sse1 / (npt-1));
        offset(i) = offset1;
        scale(i) = scale1;
        sse(i) = scale1 / sse1;
    end
end
fsse3 = find(sse > 3);

%Peak picking;
npeak = 0;
if length(fsse3) > 0
    peak1 = fsse3(1);
    npeak = 1;
    peak_all = [];
    i=1;
    
    while i <= length(fsse3)-1
        i=i+1;
        if fsse3(i) - peak1(end)  <= 2
            peak1 = [peak1, fsse3(i)];
        else
            [val, pos] = max(sse(peak1)); 
            peak_all(npeak)  = peak1(pos);
            npeak = npeak + 1;
            peak1 = fsse3(i);
        end
    end
    [val, pos] = max(sse(peak1)); 
    peak_all(npeak)  = peak1(pos);
    peak_pos = peak_all*filterW - round(filterW/2);
    peak_amp = scale(peak_all);
    base_amp = offset(peak_all);
else
    peak_pos = nan;
    rise_time = nan;
    peak_amp = nan;
    decay_time = nan;
    base_amp = nan;
end
