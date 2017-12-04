function start_spc_FLIMImage_yphys_AF (eventName, eventData)

try
    start_mdia;
    spc_startFLIMImage_and_yphys;
    
    %% turn this on if controlling OptoLens through serial port
    % initializeOptLensController;

catch ME
    disp(['****************************************']);
    disp(['ERROR ', ME.message]);
    for i=1:length(ME.stack)
       disp(['    in ', ME.stack(i).name, '(Line: ', num2str(ME.stack(i).line), ')']);       
    end
    disp(['****************************************']);
end

arrangeCurrentFigures;