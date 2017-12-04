function spc_stopGrab

global state;
global gh;

objs = [state.init.ao1, state.init.ao2, state.init.ai, state.spc.init.spc_ao, state.spc.init.pockels_ao];

stop(objs);

