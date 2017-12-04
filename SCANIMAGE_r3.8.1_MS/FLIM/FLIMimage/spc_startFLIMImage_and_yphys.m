function spc_startFLIMIMage_and_yphys (eventName, eventData)

try
     FLIMimage;
     %PQ_parameters;
     yphys_stimScope;
     yphys_pageControls;
catch ME
    disp(['****************************************']);
    disp(['ERROR ', ME.message]);
    for i=1:length(ME.stack)
       disp(['    in ', ME.stack(i).name, '(Line: ', num2str(ME.stack(i).line), ')']);       
    end
    disp(['****************************************']);
end