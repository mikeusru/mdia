function r_oneSecTimer

global state

try
    delete(state.yphys.timer.r_timer);
end
interval = 1;
state.yphys.timer.r_timerCount = 0;
state.yphys.timer.r_timerStart = clock;
state.yphys.timer.r_timer =timer('TimerFcn','r_oneSecTimerFnc','ExecutionMode','fixedSpacing','Period', interval);
start(state.yphys.timer.r_timer);

