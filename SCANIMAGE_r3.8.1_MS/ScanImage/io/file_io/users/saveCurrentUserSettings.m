function out=saveCurrentUserSettings()
global state
out=0;
if length(state.userSettingsName)==0 | isnumeric(state.userSettingsName)
    saveCurrentUserSettingsAs;
    return
end
status=state.internal.statusString;
setStatusString('Saving user settings...');
recordWindowPositions;
[fid, message]=fopen(fullfile(state.userSettingsPath, [state.userSettingsName '.usr']), 'wt');
if fid==-1
    disp(['saveCurrentUserSettings: Error cannot open output file ' fullfile(state.userSettingsPath, [state.userSettingsName '.usr']) ]);
    setStatusString('Can''t open file...');
    return
end

createConfigFileFast(4, fid, 1);

% append the SI3 usr-properties struct
state.hSI.saveUSRProperties(fid);

fclose(fid);
updateGUIByGlobal('state.userSettingsName');
setStatusString('Saved User Settings'); %VI020609A
