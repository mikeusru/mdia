function yphys_updateAverage;
global gh;
global yphys;

valName = ['e', get(gh.yphys.stimScope.epochN, 'String'), 'p', get(gh.yphys.stimScope.pulseN, 'String')];
evalc([valName, '.aveData = yphys.aveData']);
evalc([valName, '.aveString = yphys.aveString']);
save(valName, valName);

