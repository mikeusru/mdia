function [out, a]=r_maitaiConfig
global maitai

maitai.port{1} = 'COM3';
maitai.port{2} = 'COM2';
maitai_baud = 9600;

out = 0;
a = [];
for i = 1:2;
disp (['*************************** Laser ', num2str(i), ' ***************************']);
        port{i}=instrfind('Port', maitai.port{i});
        if length(port{i}) > 0; 
            fclose(port{i}); 
            delete(port{i});
            clear port;
        end
        lf = double(sprintf('\n'));
        maitai.serialPortHandle{i} = serial(maitai.port{i});
        set(maitai.serialPortHandle{i}, 'BaudRate', maitai_baud, 'Parity', 'none' , 'Terminator', 'CR', ...
            'StopBits', 1, 'DataBits', 8, 'Timeout', 2, 'Terminator', {lf, lf}, 'Name', 'Maitai');
        
        fopen(maitai.serialPortHandle{i});
        stat=get(maitai.serialPortHandle{i}, 'Status');
end
           a = monitorMaitai;

for i=1:2
    port{i}=instrfind('Port', maitai.port{i});
    if length(port{i}) > 0; 
        fclose(port{i}); 
        delete(port{i});
        clear port;
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = monitorMaitai
global maitai;

figure;
b1 = [0];
b2 = [0];
h1 = plot(1,b1, 'g-');
hold on;
h2 = plot(1,b2, 'r-');
for j=1:1000;
    pause(0.1);
    for i=1:2;
        sendSerialCommand(maitai.serialPortHandle{i},'READ:WAVELENGTH?');
        a.Wavelength{i} = getSerialResponse(maitai.serialPortHandle{i});    
        sendSerialCommand(maitai.serialPortHandle{i}, 'PLASer:POWer?');
        a.pumpPower{i} = getSerialResponse(maitai.serialPortHandle{i});
        sendSerialCommand(maitai.serialPortHandle{i}, 'READ:POWer?');
        a.Power{i} = getSerialResponse(maitai.serialPortHandle{i});
        %disp (['Wavelength = ', a.Wavelength{i}, '; Laser = ', a.Power{i}, '; Pump = ', a.pumpPower{i}]);
    end
    b1(j)=str2num(a.Power{1}(1:end-1));
    b2(j)=str2num(a.Power{2}(1:end-1));
    if j > 1
        bn1 = (b1 - b1(1))/b1(1)*100;
        bn2 = (b2 - b2(1))/b2(1)*100;
        set(h1, 'YData', bn1, 'XData', [1:j]);
        set(h2, 'YData', bn2, 'XData', [1:j]);
    end

end;



