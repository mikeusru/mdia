function pauseLoopAndDriftCorrect
%PAUSELOOPANDDRIFTCORRECT runs between a certain amount of loop grabs when
%single position mode is turned on
global dia af ua state gh

% check if it's time for autofocus and drift correction
dia.acq.loopBackup.loopCounter = dia.acq.loopBackup.loopCounter+1;
disp(dia.acq.loopBackup.loopCounter);
if dia.acq.loopBackup.loopCounter < af.params.frequency
    return
end

%save looping info and stop loop
dia.acq.loopBackup.loopCounter = 0;

% dia.acq.loopBackup.zStepSize = state.acq.zStepSize;
% dia.acq.loopBackup.numberOfZSlices = state.acq.numberOfZSlices;

if ~isinf(state.acq.numberOfRepeats)
    dia.acq.loopBackup.repeatCounter =  state.internal.repeatCounter + 1;
end

%stop looping
mainControls('startLoopButton_Callback',gh.mainControls.startLoopButton);

%run autofocus on the position
runDriftCorrect;

%resume looping
if ~isinf(state.acq.numberOfRepeats)
    state.acq.numberOfRepeats = state.acq.numberOfRepeats - dia.acq.loopBackup.repeatCounter;
end
mainControls('startLoopButton_Callback',gh.mainControls.startLoopButton);


end

