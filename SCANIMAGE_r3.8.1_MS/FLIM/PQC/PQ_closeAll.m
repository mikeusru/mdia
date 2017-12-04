function PQ_closeAll
global state spc gui gh


    try
        stop(state.spc.acq.timer.pqc_timerRates);
        delete(state.spc.acq.timer.pqc_timerRates);
    end

    SPCdata = state.spc.acq.SPCdata;
    fid = fopen('PQ_parameters.m');
    [fileName,permission, machineormat] = fopen(fid);
    [pathstr,name,ext] = fileparts(fileName);
    fclose(fid);
    save([pathstr, '\spc_init.mat'], 'SPCdata');
    
    try
        fig_pos.pq_parameters = get(gh.spc.pq_parameters.figure1, 'position');
        fig_pos.main = get(gui.spc.spc_main.spc_main, 'position');
        figName = {'lifetimeMap', 'lifetime', 'scanImgF', 'project'};
        for i = 1:length(figName)
            evalc(sprintf('fig_pos.%s = get(gui.spc.figure.%s, ''position'')', figName{i}, figName{i}));
        end
     
        save([pathstr, '\fig_pos.mat'], 'fig_pos');
    catch
        disp('failed saving figure parameters...');
    end

    try
        close(gui.spc.spc_main.spc_main);
        close(gui.spc.figure.project);
        close(gui.spc.figure.lifetimeMap);
        close(gui.spc.figure.lifetime);
        close(gui.spc.figure.scanImgF);
    end
    
    state.spc.internal.hPQ.closeDevice;
    delete(state.spc.internal.hPQ);
closereq;
