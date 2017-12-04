function PQC_acqTimerFcn(focus)
%global state spc gh
try
    PQC_acqTimer_inside(focus)
catch ME
    disp(['****************************************']);
    disp(['ERROR ', ME.message]);
    for i=1:length(ME.stack)
       disp(['    in ', ME.stack(i).name, '(Line: ', num2str(ME.stack(i).line), ')']);       
    end
    disp(['****************************************']);
end

end


function PQC_acqTimer_inside(focus)
global state spc gh

if focus
    h = gh.mainControls.focusButton;
    val=get(h, 'String');
    
else
    h = gh.mainControls.grabOneButton;
    val=get(h, 'String');
    
    if ~strcmp(val, 'ABORT')
        h = gh.mainControls.startLoopButton;
        val=get(h, 'String');
    end
end

if ~strcmp(val, 'ABORT')
    pause(0.1);
    return;
else
    %pause(0.001);
end



if spc.datainfo.pulseRate == 0 %|| spc.datainfo.darkCount(1) == 0
    fprintf('###PQC_acqTimerFcn ###\n');
    fprintf('Laser pulse rate %d or PMT count %d!!!\n', spc.datainfo.pulseRate, spc.datainfo.darkCount(1));
    fprintf('###PQC_acqTimerFcn ###\n');
    if focus
        if strcmp(val, 'ABORT')
            executeFocusCallback(h);
        end
        
    else
        if strcmp(val, 'ABORT')
            executeGrabOneCallback(h);
        end
    end
    state.files.autoSave = 1;
    state.spc.internal.ifstart = 0;
    return;
end

if ~strcmp(val, 'ABORT')
    return;
end

for i = 1:25
    if focus
        [ret, nLines, acqLines] = PQC_makeStripe;
    else
        [ret, nLines, acqLines] = PQC_makeFrameByStripes;
    end
    %disp(state.spc.internal.lineCounter);
    if ret < 0 || acqLines > 5000
        fprintf('###PQC_acqTimerFcn ###\n');
        fprintf('ERROR DURING IMAGE ACQ, Return code: %d!!!\n', ret);
        fprintf('###PQC_acqTimerFcn ###\n');
        if focus
            if strcmp(val, 'ABORT')
                executeFocusCallback(h);
            end
            
        else
            if strcmp(val, 'ABORT')
                executeGrabOneCallback(h);
            end
        end
    elseif nLines < -1000
        return;
    end
    
    if acqLines > state.acq.linesPerFrame/state.internal.numberOfStripes * 2
        %Should display again!!
        %         fprintf('Acq big');
        %         disp([nLines, acqLines]);
    else
        if nLines > 10
            break;
        else
            %             disp([nLines, acqLines]);
        end
    end
end
end