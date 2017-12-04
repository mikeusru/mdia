function yphys_mini
global state;
global yphys;
global gh;

AmpGain = 20;
duration = 60; % measurement time in sec
updateDuration = 1;
updateRate = round(1 / updateDuration);
yphys_setup;
yphys_getGain;


if state.yphys.acq.cclamp
    gain = state.yphys.acq.gainC*AmpGain;
else
    gain = state.yphys.acq.gainV*AmpGain;
end
%%%%%%%%%%%%
%setting
%analoginput
samplesize = state.yphys.acq.inputRate*duration;
ai1 = analoginput('nidaq',state.yphys.init.phys_boardIndex);
set(ai1, 'SampleRate', state.yphys.acq.inputRate, 'Tag', 'yphys');
set(ai1, 'SamplesPerTrigger', samplesize);
set(ai1, 'TriggerType', 'Immediate');
addchannel(ai1, state.yphys.init.phys_dataIndex);

figure;
updatesize = updateDuration * state.yphys.acq.inputRate;
%%%%%%%%%%%%
set(gcf, 'doublebuffer', 'on');
P = plot(zeros(updatesize, 1));
xlabel('Time(s)');
if state.yphys.acq.cclamp
    ylabel('V (mV)');
else
    ylabel('I (pA)');
end
data1 = [];

start(ai1);
for i=0:duration*updateRate-1
   while get(ai1, 'SamplesAvailable') < updatesize
       pause(0.1);
   end
   data = getdata(ai1, updatesize)/gain;
   data1 = [data1; data];
   xdata1 = [1:length(data1)]/state.yphys.acq.inputRate;
   size(data1);
   set(P, 'xdata', xdata1, 'ydata', data1);
end

miniData = [xdata1(:), data1(:)];


%%%%%%%%%%%%%%%%%Save%%%%%%%%%%%%%%%%%%%%%%%%%%
state.yphys.acq.data = miniData;
if ~isfield (state.yphys.acq, 'phys_counter')
    state.yphys.acq.phys_counter = 1;
end
if state.yphys.acq.phys_counter == 1;
    filenames=dir(fullfile(state.files.savePath, '\spc\yphys*.mat'));
    if prod(size(filenames)) ~= 0
        b=struct2cell(filenames);
        [sorted, whichfile] = sort(datenum(b(2, :)));
        newest = whichfile(end);
        filename = filenames(newest).name;
        pos1 = strfind(filename, '.');
        state.yphys.acq.phys_counter = str2num(filename(pos1-3:pos1-1))+1;
    else
        state.yphys.acq.phys_counter = 1;
    end
else
    state.yphys.acq.phys_counter =  state.yphys.acq.phys_counter + 1;
end

if isfield(state, 'files')
    numchar = sprintf('%03d', state.yphys.acq.phys_counter);
    filen = ['yphys', numchar];
    evalc([filen, '= state.yphys.acq']);
    filedir = [state.files.savePath, 'spc\'];
end
if exist(filedir)
    cd(filedir);
    save(filen, filen);
else
    cd ([filedir, '\..\']);
    mkdir('spc');
    cd(filedir);
    save(filen, filen);
end