function FOVuaPostUncage
%FOVuaPostUncage runs the post-uncage imaging cycle
global ua state gh dia

disp('Begin Post-uncaging Imaging');
ua.fov.acq.postUncage=true;
updateUAgui('currentStepText','Post-Uncaging');

for i=1:length(ua.filestruct)
    ua.filestruct(i).currentSavepath=ua.filestruct(i).savepath;
end

% Set a timer to turn off looping after the set amount of time has passed.

ua.timerval=ua.params.primaryTime*60;
ua.clk=clock;
ua.uncageTasks=floor(ua.params.primaryTime*60/ua.params.primaryFreq);
ua.totalTime=ua.timerval; %redundancy here is for pausing timers
ua.timerTasks=ua.timerval;
ua.uncageTasksRemaining=ua.uncageTasks;

setupPostUncageTimers;



end

