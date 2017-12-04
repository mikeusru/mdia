function spc_stopFocus
global state;



stop([state.spc.init.spc_aoF state.init.ao1F state.init.ao2F state.init.aiF]);

while ~strcmp([state.init.aiF.Running  state.init.ao2F.Running], ['Off' 'Off'])
end	