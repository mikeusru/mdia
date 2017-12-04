function FOVuaPreuncageDone
%FOVuaPreuncageDone is called by the preUncageDisplayFOVtimer when it
%completes
global ua dia

if ~ua.UAmodeON %check if process has been aborted
    return
end

fovNum=ua.fov.acq.currentFOV;

stop(ua.timers.preUncageDisplayFOVtimer);
stop(ua.timers.preUncageActionFOVtimer);
try
    delete(ua.timers.preUncageDisplayFOVtimer);
    delete(ua.timers.preUncageActionFOVtimer);
catch err
    disp(err.message);
end

%initialize uncaging mode
ua.fov.acq.preUncage=false;
if dia.init.staggerOn
    runExclusiveUAStagger(fovNum);
else
    
    ua.fov.acq.Uncage=true;
    updateUAgui('currentStepText','Uncaging');
    
    ua.fov.acq.uncageCounter=0;
    %uncage at different positiosn
    rotateAndUncageFOV(fovNum);
    % rotateThroughFOVPositions('uncage',false,fovNum);
end
%when this is finished, uncaging is done. move onto post-uncaging imaging.
% ua.fov.acq.Uncage=false;
% FOVuaPostUncage;
end

