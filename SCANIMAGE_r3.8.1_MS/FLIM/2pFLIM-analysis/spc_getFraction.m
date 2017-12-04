function [fraction, lifetime] = spc_getFraction(tau_m)
%Check that exp2gauss does not have any offset!!
global spc gui

if ~nargin
    tau_m = 1;
end

beta1 = spc.fit(gui.spc.proChannel).beta0;
range = spc.fit(gui.spc.proChannel).range;

%figure; hold on;
%tau_m 
t1 = 1:range(2)-range(1)+1;
t1 = t1;
for i=1:201
    fraction1(i) = i-51;    
    beta1(1) = 100*(100-fraction1(i));
    beta1(3) = 100*fraction1(i);
    curve1 = exp2gauss(beta1, t1);
    tau1(i) = sum(t1.*curve1)/sum(curve1); %*spc.datainfo.psPerUnit/1000;
    
    pop1 = beta1(1)/(beta1(1) + beta1(3));
    pop2 = 1 - pop1;
    tauD = beta1(2)*spc.datainfo.psPerUnit/1000;
    tauAD = beta1(4)*spc.datainfo.psPerUnit/1000;
    tau2(i) = (tauD*tauD*pop1+tauAD*tauAD*pop2)/(tauD*pop1 + tauAD*pop2);
    %plot(t1, curve1/max(curve1)); 
end

%plot(t1, spc.lifetime(range(1):range(2))/max(spc.lifetime), '-r', 'linewidth', 2);
%set(gca, 'Yscale', 'log');

fraction = interp1(tau1, fraction1, tau_m)/100;
lifetime = interp1(tau1, tau2, tau_m);

% figure; plot(tau1, tau2);