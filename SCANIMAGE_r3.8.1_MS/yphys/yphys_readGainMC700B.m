function a = yphys_readGainMC700B

%global state
%
MultiClampTelegraph('broadcast');
%
token = MultiClampTelegraph('getAllAmplifiers');

if ~isempty(token)
    for i=1
        a.ID = token{i}.ID;
        token2 = MultiClampTelegraph('getAmplifier', double(a.ID));
        a.Mode = token2.uOperatingMode;
        a.Primary_Gain = token2.dAlpha;
        a.ScaleFactor = token2.dScaleFactor;
        a.External_Cmd_Sens = token2.dExtCmdSens;
    end
end


% 
% filename = state.yphys.init.multiClampFileName;
% %'C:\Program Files\acq\amps\00000000_1.txt';
% fid = fopen(filename, 'rt');
% y = 0;
% while feof(fid) == 0
%    tline = fgetl(fid);
%    [token, remain] = strtok(tline, ':');
%    if strcmp(token, 'Mode')
%        a.Mode = remain(3:end);
%    else
%        evalc(['a.', token, '=', remain(2:end)]);
%    end
%    
% end

% if strcmp(a.Mode, 'V-Clamp')
%     state.yphys.acq.commandSensV = a.External_Cmd_Sens*1000;
%     state.yphys.acq.gainV = a.Primary_Gain*0.5/1000;
% else
%     state.yphys.acq.commandSensC = a.External_Cmd_Sens*1000;
%     state.yphys.acq.gainC = a.Primary_Gain*10/1000;
% end
%fclose(fid);