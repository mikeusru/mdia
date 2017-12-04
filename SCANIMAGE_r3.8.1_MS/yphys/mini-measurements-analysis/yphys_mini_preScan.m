function [peak_pos, peak_amp, base_amp] = yphys_mini_preScan (yphys, tau1, tau2);

tau1 = 1;
tau2 = 7;
deltat = 0.2;
% filterW = 10; %5 KHz

data1 = yphys.data(:,2);
data1 = data1(:)';

if yphys.inputRate == 10000
    data1 = mean(reshape(data1, 2, length(data1)/2), 1);
end

template = yphys_mini_makeTemplate(tau1,tau2, 0, deltat);
npt = length(template);

%ndata_r = 50000;
ndata_r = length(data1)-npt;
scaleB = sum(template.^2) - sum(template) * sum(template) / npt;
%
scaleU1 = filter(template(end:-1:1), 1, data1);
scaleU1 = scaleU1(npt:npt+ndata_r);
%scaleU1 = template * repmat(data1, [npt, 1]);
meanData2 = filter(ones(1, npt)/npt, 1, data1);
meanData2 = meanData2(npt:npt+ndata_r);
scaleU2 = sum(template)*meanData2;
scaleA = (scaleU1 - scaleU2) / scaleB;
offsetA = meanData2 - scaleA * mean(template);

Term1 = filter(ones(1, npt), 1, data1.^2);
Term1 = Term1(npt:npt+ndata_r);
Term2 = scaleA.^2 * sum(template.^2);
Term3 = npt*offsetA.^2;
Term4 = scaleA .* scaleU1;
Term5 = offsetA .* meanData2*npt;
Term6 = - scaleA.*offsetA*sum(template);

sseA = Term1 + Term2 + Term3 - 2 * (Term4 + Term5 + Term6);
sseA = sqrt(sseA / (npt-1));
sse = scaleA ./ sseA;
scale = scaleA;
offset = offsetA;

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
    peak_pos = peak_all;
    peak_amp = scale(peak_all);
    base_amp = offset(peak_all);
else
    peak_pos = nan;
    rise_time = nan;
    peak_amp = nan;
    decay_time = nan;
    base_amp = nan;
end
