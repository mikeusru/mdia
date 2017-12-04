function PQC_setParametersGUI(update_from_GUI)
global state gh spc

if update_from_GUI
    st = fieldnames(gh.spc.pq_parameters);
    hl = struct2array(gh.spc.pq_parameters);
    for i = 1:length(st)
        if ~strcmp(st{i}(1:3), 'st_') & ~strcmp(st{i}, 'figure1') & ~strcmp(st{i}(1:4), 'pnl_') ...
                & ~strcmp(st{i}, 'output') & ~strcmp(st{i}(1:3), 'cb_') & ~strcmp(st{i}(1:3), 'pb_') 
            a = get(hl(i), 'string');
            if st{i}(end) == '1' || st{i}(end) == '2'
                str1 = [st{i}(1:end-1), '(', st{i}(end), ')'];
                evalc(['state.spc.acq.SPCdata.', str1, '=',  a]);
            else
                evalc(['state.spc.acq.SPCdata.', st{i}, '=', a]);
            end
            
        end
    end
    state.spc.acq.FLIM_afterFocus = get(gh.spc.pq_parameters.cb_FLIM_focus, 'value');
    state.spc.acq.spc_takeFLIM = get(gh.spc.pq_parameters.cb_flim_check, 'value');
    state.spc.acq.uncageBox = get(gh.spc.pq_parameters.cb_uncage, 'value');
    state.internal.usePage = get(gh.spc.pq_parameters.cb_page, 'value');
end

state.spc.internal.hPQ.setParameters;
set(gh.spc.pq_parameters.st_resolution, 'string', sprintf('%d ps', state.spc.acq.SPCdata.resolution));

spc.SPCdata = state.spc.acq.SPCdata;