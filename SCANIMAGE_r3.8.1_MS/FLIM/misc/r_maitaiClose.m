function out=r_maitaiClose (offLaser)
global maitai

if ~nargin
    offLaser = 1;
end

maitai.port1 = 'COM7';
maitai.port2 = 'COM3';
maitai_baud = 9600;


% close all open serial port objects on the same port and remove
% the relevant object form the workspace
port1=instrfind('Port', maitai.port1);
if length(port1) > 0; 
    fclose(port1); 
    delete(port1);
    clear port;
end

port2=instrfind('Port', maitai.port2);
if length(port2) > 0; 
    fclose(port2); 
    delete(port2);
    clear port;
end


%Laser1
    lf = double(sprintf('\n'));
	maitai.serialPortHandle1  = serial(maitai.port1);
	set(maitai.serialPortHandle1, 'BaudRate', maitai_baud, 'Parity', 'none' , 'Terminator', 'CR', ...
		'StopBits', 1, 'DataBits', 8, 'Timeout', 5, 'Terminator', {lf, lf}, 'Name', 'Maitai');
%Laser 2
	maitai.serialPortHandle2 = serial(maitai.port2);
	set(maitai.serialPortHandle2, 'BaudRate', maitai_baud, 'Parity', 'none' , 'Terminator', 'CR', ...
		'StopBits', 1, 'DataBits', 8, 'Timeout', 5, 'Terminator', {lf, lf}, 'Name', 'Maitai');
    
        
% open and check status 
% %start RK
% get(maitai.serialPortHandle1, 'Status') 
% maitai.port1
% %end RK

	fopen(maitai.serialPortHandle1);
   
	stat=get(maitai.serialPortHandle1, 'Status');
	if ~strcmp(stat, 'open')
		disp(['Maitiai: trouble opening port; cannot to proceed']);
		maitai.serialPortHandle1=[];
		out=1;
		return;
    end

    fopen(maitai.serialPortHandle2);
	stat=get(maitai.serialPortHandle2, 'Status');
	if ~strcmp(stat, 'open')
		disp([' Maitiai: trouble opening port; cannot to proceed']);
		maitai.serialPortHandle2=[];
		out=1;
		return;
    end

if offLaser
    sendSerialCommand(maitai.serialPortHandle1,'OFF');
end
sendSerialCommand(maitai.serialPortHandle1, 'SHUTTER 0');

if offLaser
    sendSerialCommand(maitai.serialPortHandle2,'OFF');
end
sendSerialCommand(maitai.serialPortHandle2, 'SHUTTER 0');

pause(5);

sendSerialCommand(maitai.serialPortHandle1, 'READ:POWer?');
a.Power1 = getSerialResponse(maitai.serialPortHandle1);

sendSerialCommand(maitai.serialPortHandle1,'READ:PCTWARMEDUP?');
a.warmed1 = getSerialResponse(maitai.serialPortHandle1);

sendSerialCommand(maitai.serialPortHandle1,'READ:WAVELENGTH?');
a.Wavelength1 = getSerialResponse(maitai.serialPortHandle1);
sendSerialCommand(maitai.serialPortHandle1,'SHUTTER?');

a.Shutter1 = getSerialResponse(maitai.serialPortHandle1);
sendSerialCommand(maitai.serialPortHandle1,'CONTROL:MLENABLE?');
a.mlenable1 = getSerialResponse(maitai.serialPortHandle1);

sendSerialCommand(maitai.serialPortHandle2, 'READ:POWer?');
a.Power2 = getSerialResponse(maitai.serialPortHandle2);

sendSerialCommand(maitai.serialPortHandle2,'READ:WAVELENGTH?');
a.Wavelength2 = getSerialResponse(maitai.serialPortHandle2);

sendSerialCommand(maitai.serialPortHandle2,'READ:PCTWARMEDUP?');
a.warmed2 = getSerialResponse(maitai.serialPortHandle2);

sendSerialCommand(maitai.serialPortHandle2,'SHUTTER?');
a.Shutter2 = getSerialResponse(maitai.serialPortHandle2);

sendSerialCommand(maitai.serialPortHandle2,'CONTROL:MLENABLE?');
a.mlenable2 = getSerialResponse(maitai.serialPortHandle2);



maitai.status = a;
a

port1=instrfind('Port', maitai.port1);
if length(port1) > 0; 
    fclose(port1); 
    delete(port1);
    clear port;
end

port2=instrfind('Port', maitai.port2);
if length(port2) > 0; 
    fclose(port2); 
    delete(port2);
    clear port;
end

out=0;

