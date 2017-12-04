function startFOVua(  )
%startFOVua starts imaging for the FOV mode
global dia ua state gh

updateUAgui();

if dia.etl.acq.etlOn
    dia.etl.acq.voltageMin=0;
end
dia.acq.startTime=clock;

dia.acq.pageAcqOn = false;
%record grab values in case single position drift and af is used
% dia.acq.numberOfZSlices=state.acq.numberOfZSlices;
% dia.acq.zStepSize=state.acq.zStepSize;

dia.acq.returnHome=state.acq.returnHome;
if dia.acq.returnHome %turn off 'Return Home' to speed up imaging
    disp('turning off ''Return Home'' to speed up multiposition imaging');
    set(gh.motorControls.cbReturnHome,'Value',0);
    genericCallback(gh.motorControls.cbReturnHome);
end

% reset working positions
dia.hPos.setWorkingPositions(1);

%set timer for job queue
dia.acq.jobQueue=cell(2,0);
dia.acq.jobQueueTimer = timer('TimerFcn',@jobQueuePicker,'ExecutionMode','fixedRate','busymode','drop','period',.1);
setJobQueueTimer(1);

%make stagger and start initial positions
dia.hPos.staggerAndStartInitialPositions;

end

