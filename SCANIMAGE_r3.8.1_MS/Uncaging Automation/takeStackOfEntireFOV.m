function takeStackOfEntireFOV
global state dia
%for all these parameters, make functions which remember the old values and
%change the parameters. these functions can be in their own class or their
%own function of functions.

if ~dia.hPos.collectFOVstackWhenDone
    return
end

ds = dia.hPos.allPositionsDS;
zRange = [min(ds.motorZ) - (state.acq.numberOfZSlices*state.acq.zStepSize/2),...
    max(ds.motorZ) + (state.acq.numberOfZSlices*state.acq.zStepSize/2)];

%set appropriate slice number
numZSlices = ceil(range(zRange)/state.acq.zStepSize);

pixelsPerLine = 1024;
linesPerFrame = 1024;

changeOrRevertAcquisitionValues(true, 'savePath', dia.originalSavePath, ...
    'baseName', 'FullFOV', 'fileCounter', 1, 'numberOfZSlices', numZSlices,...
    'pixelsPerLine', pixelsPerLine, 'linesPerFrame', linesPerFrame, ...
    'scanShiftFast', 0, 'scanShiftSlow', 0, 'scanRotation', 0);

%set Z center
zCenter = min(ds.motorZ) + range(ds.motorZ)/2;

%move to appropriate motor position
fovNum = ds.FOVnum(1);
motorX = obj.fovDS.motorX(fovNum,1);
motorY = obj.fovDS.motorY(fovNum,1);
motorOrETLMove([motorX,motorY,zCenter],1);

%grab, then revert to old values
try
    grabAndWait;
    doRevert = true;
catch
    fullRevert;
    doRevert = false;
end
if doRevert
    fullRevert;
end


function fullRevert
changeOrRevertAcquisitionValues(false, 'savePath', [], ...
    'baseName', [], 'fileCounter', [], 'numberOfZSlices', [],...
    'pixelsPerLine', [], 'linesPerFrame', [], ...
    'scanShiftFast', [], 'scanShiftSlow', [], 'scanRotation', []);