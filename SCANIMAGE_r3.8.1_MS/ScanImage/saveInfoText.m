function saveInfoText( origin )
%saveInfoText( origin )saves a text file with the relevant info, assuming a
%directory and stuff has been chosen. it's called when grab or loop is
%pressed.
%

global state

filename=state.files.fullFileName;
a=clock;
if ~state.files.autoSave %make sure autosave is turned on
    return
end

fid=fopen([filename,'.txt'],'wt'); %create textfile

fprintf(fid,'%s%s\n','Capture type: ',origin);
fprintf(fid,'%s','Date (y/m/d): ',num2str(a(1)),'/',num2str(a(2)),'/',num2str(a(3)));
fprintf(fid,'%s\n',''); %blank space
fprintf(fid,'%s','Time: ',num2str(a(4)),':',num2str(a(5)),':',num2str(round(a(6))));
fprintf(fid,'%s\n',''); %blank space
fprintf(fid,'%s\n',''); %blank space
fprintf(fid,'%s\n','Main Controls Settings:');
fprintf(fid,'%s\n',''); %blank space
fprintf(fid,'%s%s\n','Zoom: ',num2str(state.acq.zoomFactor));
fprintf(fid,'%s%s\n','Number of frames averaged: ',num2str(state.acq.numAvgFramesSave));
fprintf(fid,'%s%s\n','Repeat period: ',num2str(state.acq.repeatPeriod));
fprintf(fid,'%s%s\n','Number of Z slices: ',num2str(state.acq.numberOfZSlices));
fprintf(fid,'%s%s\n','µm/Slice: ',num2str(state.acq.zStepSize));
if strcmp(origin,'loop')
    fprintf(fid,'%s%s\n','Number of repeats: ',num2str(state.acq.numberOfRepeats));
end
try
    
    fprintf(fid,'%s\n',''); %blank space
    fprintf(fid,'%s\n','yphys_stimScope parameters:');
    fprintf(fid,'%s\n',''); %blank space
    fprintf(fid,'%s%s\n','Freq: ',num2str(state.yphys.acq.freq));
    fprintf(fid,'%s%s\n','#Stim: ',num2str(state.yphys.acq.nstim));
    fprintf(fid,'%s%s\n','Dwell: ',num2str(state.yphys.acq.dwell));
    fprintf(fid,'%s%s\n','Amp: ',num2str(state.yphys.acq.amp));
    fprintf(fid,'%s%s\n','Delay: ',num2str(state.yphys.acq.delay));
    fprintf(fid,'%s%s\n','Ext. Trig: ',num2str(state.yphys.acq.ext));
    fprintf(fid,'%s%s\n','Patch: ',num2str(state.yphys.acq.ap));
    fprintf(fid,'%s%s\n','Stim: ',num2str(state.yphys.acq.stim));
    fprintf(fid,'%s%s\n','Uncage: ',num2str(state.yphys.acq.uncage));
    fprintf(fid,'%s%s\n','Theta: ',num2str(state.yphys.acq.theta));
    fprintf(fid,'%s%s\n','Add pulse: ',num2str(state.yphys.acq.addP));
    fprintf(fid,'%s%s\n','Epoch: ',num2str(state.yphys.acq.epochN));
    fprintf(fid,'%s%s\n','Delay: ',num2str(state.yphys.acq.delay));
    
    pulseN=state.yphys.acq.pulseN;
    fprintf(fid,'%s%s\n','Program#: ',num2str(pulseN));
    fprintf(fid,'%s%s\n','Length: ',num2str(state.yphys.acq.sLength(pulseN)));
    fprintf(fid,'%s%s\n','#Train: ',num2str(state.yphys.acq.ntrain(pulseN)));
    fprintf(fid,'%s%s\n','Interval: ',num2str(state.yphys.acq.interval(pulseN)));
    fprintf(fid,'%s%s\n','Pulse Name: ',state.yphys.acq.sLength{pulseN});
    
catch err
end

try
    fprintf(fid,'%s\n',''); %blank space
    fprintf(fid,'%s\n','FLIM Parameters:');
    fprintf(fid,'%s\n',''); %blank space
    fprintf(fid,'%s%s\n','Flim: ',num2str(state.spc.acq.spc_takeFLIM));
    fprintf(fid,'%s%s\n','Binning: ',num2str(state.spc.acq.spc_binning));
    fprintf(fid,'%s%s\n','Bin factor: ',num2str(state.spc.acq.binFactor));
    fprintf(fid,'%s%s\n','Page acq mode: ',num2str(state.internal.usePage));
catch err
end

try
    fprintf(fid,'%s\n',''); %blank space
    fprintf(fid,'%s\n','Scanning Configuration:');
    fprintf(fid,'%s\n',''); %blank space
    fprintf(fid,'%s%s\n','Configuration Name: ',state.configName);
    fprintf(fid,'%s%s\n','Pixels / Line: ',num2str(state.acq.pixelsPerLine));
    fprintf(fid,'%s%s\n','Lines / Frame: ',num2str(state.acq.linesPerFrame));
    fprintf(fid,'%s%s\n','Ms / Line: ',num2str(state.acq.frameRateGUI));
    fprintf(fid,'%s%s\n','Bidirectional Scan: ',num2str(state.acq.bidirectionalScan));
catch err
end
fclose(fid);

end

