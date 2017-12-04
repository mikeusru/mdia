function PQC_fillParameters
global state gh spc

st = fieldnames(gh.spc.pq_parameters);
hl = struct2array(gh.spc.pq_parameters);
for i = 1:length(st)
   if ~strcmp(st{i}(1:3), 'st_') & ~strcmp(st{i}, 'figure1') & ~strcmp(st{i}(1:4), 'pnl_') ...
           & ~strcmp(st{i}, 'output') & ~strcmp(st{i}(1:3), 'cb_') & ~strcmp(st{i}(1:3), 'pb_')
       
       if st{i}(end) == '1' || st{i}(end) == '2'
           str1 = [st{i}(1:end-1), '(', st{i}(end), ')'];
           evalc(['a=state.spc.acq.SPCdata.', str1]);
       else
           evalc(['a=state.spc.acq.SPCdata.', st{i}]);
       end
       
       set(hl(i), 'string', num2str(a));
   end
end

set(gh.spc.pq_parameters.cb_flim_check, 'value', state.spc.acq.spc_takeFLIM);
set(gh.spc.pq_parameters.cb_uncage, 'value', state.spc.acq.uncageBox);
set(gh.spc.pq_parameters.cb_page, 'value', state.internal.usePage);
set(gh.spc.pq_parameters.cb_FLIM_focus, 'value', state.spc.acq.FLIM_afterFocus);