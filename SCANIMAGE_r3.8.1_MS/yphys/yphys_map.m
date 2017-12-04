function yphys_map(mapDim);
global state;
global gh;
global yphys;

executeGrabOneCallBack(gh.mainControls.grabOneButton); 
pause(5);

nstim = state.yphys.acq.nstim;
freq = state.yphys.acq.freq;
dwell = state.yphys.acq.dwell;
amp = state.yphys.acq.amp;
delay = state.yphys.acq.delay;
ntrain = state.yphys.acq.ntrain;
interval = state.yphys.acq.interval;
%interval = 1;
ext = state.yphys.acq.ext;
ap = state.yphys.acq.ap;
uncage=state.yphys.acq.uncage;
theta = state.yphys.acq.theta;
sLength = state.yphys.acq.sLength;

try
    stop(state.yphys.init.phys);
    stop(state.yphys.init.phys_patch);
    stop(state.yphys.init.phys_input);
    stop(state.yphys.init.phys_setting);
    try
        set(gh.yphys.scope.start, 'String', 'START');
    end
    try
        stop(state.yphys.timer.patch_timer);
    end
    delete(state.yphys.timer.patch_timer);
end
if isempty(gh.yphys.figure.yphys_roi(1))
    gh.yphys.figure.yphys_roi(i) = rectangle('Position', [2,2,2,2], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(1));
    gh.yphys.figure.yphys_roiText(i) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
    set(gh.yphys.figure.yphys_roiText(i), 'Color', 'Red');
end

num = str2num(get(gh.yphys.stimScope.epochN, 'String'));
set (gh.yphys.stimScope.epochN, 'String', num2str(num+1));

state.yphys.acq.loopCounter = 1;
 state.yphys.acq.looping = 1;
 
xyCoords = yphys_makeMapCoordinate(mapDim);
state.yphys.acq.xyCoords = xyCoords;

t_function = ['yphys_mapLoopFcn(', num2str(mapDim), ')'];
state.yphys.timer.stim_timer =timer('TimerFcn',t_function,'ExecutionMode','fixedSpacing','Period', interval);
start(state.yphys.timer.stim_timer)

% 
