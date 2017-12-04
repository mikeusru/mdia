function FOVuaPostUncageDone
%FOVuaPostUncageDone hits when the timer for post-uncage imaging finishes.
%it either finishes the process or sends it to restart for the next FOV.
global ua dia state

if ~ua.UAmodeON %if aborted, stop everything
    return
end
try
    stop(ua.timers.postUncageDisplayFOVtimer);
    stop(ua.timers.postUncageActionFOVtimer);
    
end
try
    delete(ua.timers.postUncageDisplayFOVtimer);
    delete(ua.timers.postUncageActionFOVtimer);
catch err
    %     disp(err.message)
end

if ~(dia.hPos.workingFOV>=length(ua.fov.FOVposStruct)) %if imaging is not done
    %set next FOV and position index
    dia.hPos.workingFOV=dia.hPos.workingFOV+1;
    % Start next iteration;
    startFOVua;
else
    disp('Finished Final Loop');
    takeStackOfEntireFOV;
    UA_Abort;
end

try
    if dia.guiStuff.emailWhenDone
        a=round(clock);
        sendmail(dia.acq.cellInfo.email,'Imaging Done',['Imaging Done at ', num2str(a(4:6))]);
    end
end

animateUAdata(state.files.savePath);
end

