function MDIA_Measurement(eventName,eventData)
%MDIA_Measurement runs whenever FLIM_Measurement runs, collecting and
%setting autofocus and drift correction parameters
%   Detailed explanation goes here
global dia af ua state gh
try
    if strcmp(get(gh.mainControls.focusButton, 'String'), 'ABORT')
        focus = 1;
    else
        focus = 0;
    end
    if (af.params.isAFon || af.drift.on ) && ~focus
        isLooping = strcmp('ABORT',(get(gh.mainControls.startLoopButton,'String')));

        switch eventName
            case 'acquisitionStarting'
                MDIA_acquisitionStarting;
            case 'acquisitionDone'
                MDIA_acquisitionDone;
            case 'sliceDone'
                MDIA_sliceDone;
            case 'frameAcquired'
                MDIA_frameAcquired;
            case 'abortAcquisitionEnd'
                %                 MDIA_abortAcquisitionEnd;
            case 'startTriggerReceived'
                %                 MDIA_startTriggerReceived;
            case 'stripeAcquired'
                %                 MDIA_stripeAcquired;
            otherwise
        end
    end
catch ME
    disp(['****************************************']);
    disp(['ERROR ', ME.message]);
    for i=1:length(ME.stack)
        disp(['    in ', ME.stack(i).name, '(Line: ', num2str(ME.stack(i).line), ')']);
    end
    disp(['****************************************']);
end

    function MDIA_acquisitionStarting
        %calculate z position list
        if af.params.isAFon && state.acq.numberOfZSlices > 1
            af.position.af_list_abs_z =  state.internal.initialMotorPosition(3) - state.acq.stackCenteredOffset + state.acq.zStepSize * (0:state.acq.numberOfZSlices-1);
        else
            af.position.af_list_abs_z = state.motor.absZPosition;
        end
        if isLooping && state.internal.repeatCounter==0
            dia.acq.loopBackup.loopCounter = 0;
        end
    end

    function MDIA_acquisitionDone
        MDIA_sliceDone;
        if strcmp(af.params.mode,'singleMode')
            if isLooping
                pauseLoopAndDriftCorrect;
            end
        end
    end

    function MDIA_sliceDone
        if af.params.isAFon
            %record current Z position
            af.frameAbsZPosition = af.position.af_list_abs_z(state.internal.zSliceCounter);
        end
        af.images{state.internal.zSliceCounter}=getLastAcqImage; %record last image taken. AF does not need to be on since this can be used just for drift correction
    end

    function MDIA_frameAcquired
    end

end

