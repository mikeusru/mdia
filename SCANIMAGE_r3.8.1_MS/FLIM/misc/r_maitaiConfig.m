function [out, a]=r_maitaiConfig (wl1, wl2)
global maitai

if nargin < 1
    wl1 = 0;
    wl2 = 0;
end

wl = [wl1, wl2];

maitai.port{1} = 'COM7';
maitai.port{2} = 'COM3';
maitai_baud = 38400;

out = 0;
a = [];
for i = 1:2;
disp (['*************************** Laser ', num2str(i), ' ***************************']);
    % close all open serial port objects on the same port and remove
    % the relevant object form the workspace
    if wl(i) == 0
    else
        port{i}=instrfind('Port', maitai.port{i});
        if length(port{i}) > 0; 
            fclose(port{i}); 
            delete(port{i});
            clear port;
        end
        lf = double(sprintf('\n'));
        maitai.serialPortHandle{i} = serial(maitai.port{i});
        set(maitai.serialPortHandle{i}, 'BaudRate', maitai_baud, 'Parity', 'none' , 'Terminator', 'CR', ...
            'StopBits', 1, 'DataBits', 8, 'Timeout', 5, 'Terminator', {lf, lf}, 'Name', 'Maitai');

        fopen(maitai.serialPortHandle{i});
        stat=get(maitai.serialPortHandle{i}, 'Status');
        if ~strcmp(stat, 'open')
            disp(['Maitiai: trouble opening port, ', maitai.port{i}, '; cannot to proceed']);
            maitai.serialPortHandle{i}=[];
            out=1;
        else
            a = configMaitai(i, wl, a);
        end    
    end
end

 
maitai.status = a;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = configMaitai(i, wl, a)
global maitai;
if wl(i) > 700 & wl(i) < 1030
else
    return;
end


%%%%Closing shutter and Turning on laser%%%%%%%%%%%%%%%%%%%%
sendSerialCommand(maitai.serialPortHandle{i}, 'SHUTTER 0');
sendSerialCommand(maitai.serialPortHandle{i},'ON');

%%%%Reading shutter%%%%%%%%%%%%%%%%%%%%%
sendSerialCommand(maitai.serialPortHandle{i},'SHUTTER?');
a.Shutter{i} = getSerialResponse(maitai.serialPortHandle{i});

%%%%Reading power%%%%%%%%%%%%%%%%%%%%%
sendSerialCommand(maitai.serialPortHandle{i}, 'READ:POWer?');
a.Power{i} = getSerialResponse(maitai.serialPortHandle{i});
if strcmp (a.Power{i}, '')
    disp(['ERROR IN COMMUNICATION.']);
    return;
end

%%%%Reading percent warmup%%%%%%%%%%%%%%%%%%%%%
sendSerialCommand(maitai.serialPortHandle{i},'READ:PCTWARMEDUP?');
a.warmed{i} = getSerialResponse(maitai.serialPortHandle{i});


%%%%Mode lock enabled%%%%%%%%%%%%%%%%%%%%%%%%%%
sendSerialCommand(maitai.serialPortHandle{i},'CONTROL:MLENABLE?');
a.mlenable{i} = getSerialResponse(maitai.serialPortHandle{i});

%%%%Reading Mode %%%%%%%%%%%%%%%%%%%%%%%%%%
%sendSerialCommand(maitai.serialPortHandle{i},'MODE POW');
%mode = getSerialResponse(maitai.serialPortHandle{i});


%%%%Reading mode lock%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    sendSerialCommand(maitai.serialPortHandle{i},'STB?');
    a.stb{i} = getSerialResponse(maitai.serialPortHandle{i});
    bit1 = num2str(dec2bin(str2num(a.stb{i})));
    bit1 = bit1(end-1:end-1);
    a.modelock{i} = bit1;
catch
    a.modelock{i} = '0';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sendSerialCommand(maitai.serialPortHandle{i},'READ:WAVELENGTH?');
a.Wavelength{i} = getSerialResponse(maitai.serialPortHandle{i});
wl1 = str2num(a.Wavelength{i}(1:end-2));
if wl1 < 950
    laserPMin = 0.5;
else
    laserPMin = 0.25;
end

pump_max{i} = 'Auto'; %8.5;
if i == 1
%%%%%%%%Setting power for 1st laser%%%%%%%%%%%%%%%%%%%%%%%
    %pump_max{i} = 'Auto'; %8.8
    pump_max{i} = 'Auto';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set to "Auto" if you want a default setting.
%Up to 10.5 W.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
%%%%%%%%Setting power for 2nd laser%%%%%%%%%%%%%%%%%%%%%%%    
    %pump_max{i} = '8'; 
    pump_max{i} = 'Auto';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set to "Auto" if you want a default setting.
%Up to 10.5 W.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if ~strcmp(pump_max{i}, 'Auto')
    sendSerialCommand(maitai.serialPortHandle{i},'MODE PPOWer');
    str = ['PLASer:POWer ', pump_max{i}];
    sendSerialCommand(maitai.serialPortHandle{i}, str);
else
    %sendSerialCommand(maitai.serialPortHandle{i},'MODE POW');
end
% 


%%%%%Reading pump laser power%%%%%%%%%%%%%%%%%%%%%%
sendSerialCommand(maitai.serialPortHandle{i}, 'READ:PLASer:POWer?');
a.pumpPower{i} = getSerialResponse(maitai.serialPortHandle{i});

%%%%%Reading wavelength%%%%%%%%%%%%%%%%%%%%%%
sendSerialCommand(maitai.serialPortHandle{i},'READ:WAVELENGTH?');
a.Wavelength{i} = getSerialResponse(maitai.serialPortHandle{i});

%%%%%If wavelength is different, move wavlength%%%%%%%%%%%%%%%%%%%%%%
wlR = str2num(a.Wavelength{i}(1:end-2));
if wlR ~= wl(i)
    sendSerialCommand(maitai.serialPortHandle{i}, sprintf('WAVELENGTH %s', num2str(wl(i))));
end

j=1;
while j < 100 & wlR ~= wl(i)
    pause(1);
    sendSerialCommand(maitai.serialPortHandle{i},'READ:WAVELENGTH?');
    a.Wavelength{i} = getSerialResponse(maitai.serialPortHandle{i});    
    wlR = str2num(a.Wavelength{i}(1:end-2));
    sendSerialCommand(maitai.serialPortHandle{i}, 'PLASer:POWer?');
    a.pumpPower{i} = getSerialResponse(maitai.serialPortHandle{i});
    sendSerialCommand(maitai.serialPortHandle{i}, 'READ:POWer?');
    a.Power{i} = getSerialResponse(maitai.serialPortHandle{i});
    disp (['Wavelength = ', a.Wavelength{i}, '; Laser = ', a.Power{i}, '; Pump = ', a.pumpPower{i}]);
    j = j+1;
end

%%%%Checking mode lock again%%%%%%%%%%%%%%%%%%%%%%%%%%
%Open only when it is modelocking%%%%%%%%%%%%%%%%%%%%%
if strcmp(a.modelock{i}, '0')
    try
        sendSerialCommand(maitai.serialPortHandle{i},'STB?');
        a.stb{i} = getSerialResponse(maitai.serialPortHandle{i});
        bit1 = num2str(dec2bin(str2num(a.stb{i})));
        bit1 = bit1(end-1:end-1);
        a.modelock{i} = bit1;
    catch
        a.modelock{i} = '0';
    end
    if str2num(a.modelock{i})
        disp (['Pulsing']);
        sendSerialCommand(maitai.serialPortHandle{i}, 'SHUTTER 1');
    else
        disp (['ERROR in Laser ', num2str(i), ': ****NOT PULSING****']);
        out = 1;
    end
else
    disp (['Pulsing']);
    sendSerialCommand(maitai.serialPortHandle{i}, 'SHUTTER 1');
end

%%%%Reading powers again%%%%%%%%%%%%%%%%%%%%
sendSerialCommand(maitai.serialPortHandle{i}, 'READ:POWer?');
a.Power{i} = getSerialResponse(maitai.serialPortHandle{i});
%
sendSerialCommand(maitai.serialPortHandle{i}, 'READ:PLASer:POWer?');
a.pumpPower{i} = getSerialResponse(maitai.serialPortHandle{i});
%

disp (['Wavelength =', a.Wavelength{i}]);
disp (['Warmed up =', a.warmed{i}]);
disp(['Pump power =', a.pumpPower{i}]);
disp (['Power =', a.Power{i}]);

port{i}=instrfind('Port', maitai.port{i});
if length(port{i}) > 0; 
    fclose(port{i}); 
    delete(port{i});
    clear port;
end

