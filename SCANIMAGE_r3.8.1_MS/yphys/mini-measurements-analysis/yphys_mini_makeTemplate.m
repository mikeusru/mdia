function template = yphys_mini_makeTemplate(tau1,tau2, shift, deltat)

%deltat = 0.2;
nbtau = 10;
ntau = 30;
plus = 1;
if shift < -nbtau
    shift = -nbtau;
elseif shift > nbtau
    shift = nbtau;
end
ds = shift - floor(shift);
shift = floor(shift);
% tau1  - rise time constant (us)
% tau2  - decay time constant (ms)
% deltat - 'sampling interval'
% nbtau - initial baseline interval in millisecond
% ntau  - total length in milliseconds
% plus  - to make number of points odd
tau1 = abs(tau1);
tau2 = abs(tau2);

npoints = round(ntau/deltat)+plus;
template = zeros(1,npoints);
timebase=deltat:deltat:(ntau-nbtau)+deltat*plus - deltat*shift;
ds = ds*deltat;

%template(round(nbtau/deltat):size(template,2))=-(1-exp(-timebase/tau1)).*exp(-timebase/tau2);
if tau1 == tau2
    template(round(nbtau/deltat)+1+shift:size(template,2))= -tau1 * exp(-timebase/tau1);  
else
    template(round(nbtau/deltat)+1+shift:size(template,2))=-abs(exp(-(timebase-ds)/tau1) - exp(-(timebase-ds)/tau2));
end

template = -template / min(template);

