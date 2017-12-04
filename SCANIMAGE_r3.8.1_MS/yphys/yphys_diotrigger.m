function yphys_diotrigger;
global state;

state.spc.yphys.triggertime = datenum(now);
if isfield(state, 'init')
    putvalue(state.init.triggerLine, 1);
    putvalue(state.init.triggerLine, 0);
else
    putvalue(state.yphys.init.triggerLine, 1);
    putvalue(state.yphys.init.triggerLine, 0);
end
