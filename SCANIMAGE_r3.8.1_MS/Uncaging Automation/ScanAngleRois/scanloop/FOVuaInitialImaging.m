function FOVuaInitialImaging
%FOVuaInitialImaging runs the initial imaging cycle

global dia ua state gh

disp('Begin Initial Imaging');
ua.fov.acq.initialImaging=true;
updateUAgui('currentStepText','Initial Imaging');

% Set a timer to turn off looping after the set amount of time has passed.
ua.clk=clock;
ua.timerval=dia.acq.initialImagingTime*60;
ua.uncageTasks=floor(dia.acq.initialImagingTime*60/dia.acq.initialImagingPeriod);
ua.totalTime=ua.timerval; %redundancy is for pausing timers
ua.timerTasks=ua.timerval;
ua.uncageTasksRemaining=ua.uncageTasks;

setupInitialImagingTimers;

end
