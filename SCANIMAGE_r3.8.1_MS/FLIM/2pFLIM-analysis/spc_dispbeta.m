function spc_dispbeta
global gui;
global spc;

if isfield(spc.fit(gui.spc.proChannel), 'beta0')
    
	handles = gui.spc.spc_main;
	betahat = spc.fit(gui.spc.proChannel).beta0;
	
	tau = betahat(2)*spc.datainfo.psPerUnit/1000;
	tau2 = betahat(4)*spc.datainfo.psPerUnit/1000;
	%peaktime = (betahat(5)+range(1))*spc.datainfo.psPerUnit/1000;
    peaktime = (betahat(5))*spc.datainfo.psPerUnit/1000;
    if length(betahat) >= 6
        tau_g = betahat(6)*spc.datainfo.psPerUnit/1000;
    end
	
%     fix1 = spc.fit(gui.spc.proChannel).fixtau1; % get(gui.spc.spc_main.fixtau1, 'value');
%     fix2 = spc.fit(gui.spc.proChannel).fixtau2; %get(gui.spc.spc_main.fixtau2, 'value');
%     fix_g = spc.fit(gui.spc.proChannel).fix_delta; %get(gui.spc.spc_main.fix_g, 'value');
%     fix_d = spc.fit(gui.spc.proChannel).fix_g; %get(gui.spc.spc_main.fix_delta, 'value');

    fixtau = spc.fit(gui.spc.proChannel).fixtau;
    
    set(handles.fixtau1, 'Value', fixtau(2));
    set(handles.fixtau2, 'Value', fixtau(4));
    set(handles.fix_g, 'Value', fixtau(5));
    set(handles.fix_delta, 'Value', fixtau(6));
    
    set(handles.beta1, 'String', num2str(betahat(1)));
    set(handles.beta3, 'String', num2str(betahat(3)));
    set(handles.beta2, 'String', num2str(tau));
    set(handles.beta4, 'String', num2str(tau2));
        

	set(handles.beta5, 'String', num2str(peaktime));
    set(handles.beta6, 'String', num2str(tau_g));
	
	pop1 = betahat(1)/(betahat(3)+betahat(1));
	pop2 = betahat(3)/(betahat(3)+betahat(1));
	set(handles.pop1, 'String', num2str(pop1));
	set(handles.pop2, 'String', num2str(pop2));
    mean_tau = (tau*tau*pop1+tau2*tau2*pop2)/(tau*pop1 + tau2*pop2);
	set(handles.average, 'String', num2str(mean_tau));

end

try
    set(handles.F_offset, 'String', num2str(spc.fit(gui.spc.proChannel).t_offset));
catch
    set(handles.F_offset, 'String', 'NAN');
end

range1 = round(spc.fit(gui.spc.proChannel).range.*spc.datainfo.psPerUnit/100)/10;
set(handles.spc_fitstart, 'String', num2str(range1(1)));
set(handles.spc_fitend, 'String', num2str(range1(2)));
