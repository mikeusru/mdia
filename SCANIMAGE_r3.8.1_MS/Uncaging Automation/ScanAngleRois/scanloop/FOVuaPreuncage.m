function FOVuaPreuncage
%FOVuaPreuncage runs the pre-uncaging process

global dia ua state gh

disp('Begin Pre-uncaging');
ua.fov.acq.preUncage=true;
updateUAgui('currentStepText','Pre-Uncage Imaging');

% Set a timer to turn off looping after the set amount of time has passed.
ua.clk=clock;
ua.timerval=ua.params.preUncageTime*60;
ua.uncageTasks=floor(ua.params.preUncageTime*60/ua.params.preUncageFreq);
ua.totalTime=ua.timerval; %redundancy is for pausing timers
ua.timerTasks=ua.timerval;
ua.uncageTasksRemaining=ua.uncageTasks;

setupPreUncageTimers;

end
