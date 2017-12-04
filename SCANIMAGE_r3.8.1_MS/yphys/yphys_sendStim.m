function yphys_sendStim
%dwell in milisecond.

global state;
global gh;

ext = get(gh.yphys.stimScope.ext, 'value');
yphys_stopAll;
%yphys_setup;
yphys_getGain;

yphys_putSampleStim;

state.yphys.internal.waiting = 1;
state.yphys.init.phys_both.start();
state.yphys.init.phys_input.start();

state.spc.yphys.triggertime = datestr(now, 'yyyy-mmm-dd, HH:MM:SS:FFF');
if ~ext
    dioTrigger;
end   
