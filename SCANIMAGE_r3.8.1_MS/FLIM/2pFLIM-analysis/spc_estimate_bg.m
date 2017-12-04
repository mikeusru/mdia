function spc_estimate_bg
global gui spc
spc_redrawSetting(1);
set(gui.spc.spc_main.beta7, 'string', num2str(spc.fit(gui.spc.proChannel).background ));