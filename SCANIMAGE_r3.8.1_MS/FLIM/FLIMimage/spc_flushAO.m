function spc_flushAO

global state;


objs = [state.init.ao1, state.init.ao2, state.init.ai, state.spc.init.spc_ao, state.spc.init.pockels_ao];

stop(objs);

for objCounter = 1 : length(objs)
    if ~isempty(get(objs(objCounter), 'SamplesAvailable')) && get(objs(objCounter), 'SamplesAvailable') > 0 && strcmp(get(objs(objCounter), 'Running'), 'Off')
        start(objs(objCounter));
        stop(objs(objCounter));
    end
end