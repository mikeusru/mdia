function yphys_mapLoopFcn(mapDim);
global state
global gh


%get(gh.yphys.stimScope);

set(gh.yphys.stimScope.start, 'Enable', 'Off');
amp = state.yphys.acq.amp;
nstim = state.yphys.acq.nstim;
delay = state.yphys.acq.delay;
dwell= state.yphys.acq.dwell;
uncage = state.yphys.acq.uncage;
freq = state.yphys.acq.freq;
ap = state.yphys.acq.ap;
ext = state.yphys.acq.ext;
theta = state.yphys.acq.theta;
sLength = state.yphys.acq.sLength;

% j = floor(state.yphys.acq.loopCounter / mapDim)+1;
% i = state.yphys.acq.loopCounter - floor(state.yphys.acq.loopCounter / mapDim)*mapDim + 1;
if state.yphys.acq.loopCounter > mapDim * mapDim
        stop(state.yphys.timer.stim_timer);
        delete(state.yphys.timer.stim_timer);
        set(gh.yphys.stimScope.start, 'String', 'Start');
        set(gh.yphys.stimScope.start, 'Enable', 'On');
        yphys_generateMap;
        figfile = ['map', num2str(state.files.fileCounter-1)];
        cd([state.files.savePath, 'spc']);
        saveas(gcf, figfile, 'fig');
else
    set(gh.yphys.stimScope.start, 'String', 'Stop');
	
	
	
	j = state.yphys.acq.xyCoords(state.yphys.acq.loopCounter, 1);
	i = state.yphys.acq.xyCoords(state.yphys.acq.loopCounter, 2);
	
	im_size = size(get(state.internal.imagehandle(1), 'CData'));
	map_size1 = im_size(1);
	map_size2 = im_size(2);
	set(gh.yphys.figure.yphys_roi(1), 'Position', [map_size1/mapDim*i, map_size2/mapDim*j, 2,2]);
    try
	    yphys_uncage(freq, nstim, dwell, amp, delay, sLength);
    catch
        stop(state.yphys.timer.stim_timer);
        delete(state.yphys.timer.stim_timer);
        set(gh.yphys.stimScope.start, 'String', 'Start');
        set(gh.yphys.stimScope.start, 'Enable', 'On');
    end
	
	
	set(gh.yphys.stimScope.counter, 'String', ['Looping: (', num2str(i), ',', num2str(j),  ')/', '(', num2str(mapDim), ',', num2str(mapDim), ')']);
	state.yphys.acq.loopCounter = state.yphys.acq.loopCounter + 1;
	
	set(gh.yphys.stimScope.start, 'Enable', 'On');
end
% for i=0.5:1:mapDim(1)-0.5
%     for j=0.5:1:mapDim(2)-0.5
%         set(gh.yphys.figure.yphys_roi(1), 'Position', [im_size(1)/mapDim(1)*i, im_size(2)/mapDim(2)*j, 2,2]);
%         yphys_uncage(freq, nstim, dwell, amp, delay, sLength);
%     end
% end