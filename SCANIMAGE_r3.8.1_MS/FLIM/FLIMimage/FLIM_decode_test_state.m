function [armed, measure, wait, timerout, filled] = FLIM_decode_test_state (display1, display2)

global state

if nargin == 0
    display1 = 1;
    display2 = 0;
end

if nargin == 1
    display2 = 0;
end

status=0;
[out1, status]=calllib(state.spc.init.dllname,'SPC_test_state',state.spc.acq.module,status);

if status  < 0
    %disp('ERROR during SPC_test_state');
    error1 = FLIM_get_error_string (out1);    
    disp(['Error during SPC_test_state:', error1]);
    armed = 0; 
    measure = 0;
    wait = 0;
    timerout = 0;
    filled = 0;
    return;
end

a=dec2bin(double(status), 16);

if display1
    b=a(end-0);
    disp(['Stopped on overflow  ', a(end-0)]);
    disp(['Overflow occured  ', a(end-1)]);
    disp(['Stopped on expiration of collection timer  ', a(end-2)]);
    disp(['collection timer expired  ', a(end-3)]);
    disp(['Stopped on user command  ', a(end-4)]);
    disp(['Repeat timer expired  ', a(end-5)]);
    disp(['Measurement active (Running)', a(end-6)]);
    disp(['Measurement in progress (current bank)  ', a(end-7)]);%SPC_ARMED 0x80
    disp(['Second overflow of collection timer  ', a(end-8)]); %SPC_COLTIM_OVER 0x100
    disp(['Second overflow of repeat timer  ', a(end-9)]); %SPC_REPTIM_2OVER 0x200
    if state.spc.acq.SPCdata.mode == 2
        disp(['Scan ready (data can be read)  ', a(end-10)]); %0x400
        disp(['Flow back of scan finished  ', a(end-11)]); %0x800
    elseif state.spc.acq.SPCdata.mode == 5
        disp(['Fifo overflow, data lost  ', a(end-10)]); %0x400
        disp(['Fifo empty  ', a(end-11)]); %0x800
    end
    disp(['Wait for external trigger  ', a(end-12)]);  %0x1000
    if state.spc.acq.SPCdata.mode == 2
        disp(['Sequencer is waiting for other bank to be armed ', a(end-13)]); % 0x2000
    elseif state.spc.acq.SPCdata.mode == 5
        disp(['FIFO IMAGE measurement waits for the frame signal to stop  ', a(end-13)]); % 0x2000
    end
    disp(['disarmed (measurement stopped) by sequencer  ', a(end-14)]); % %0x4000
    disp(['hardware fill not finished  ', a(end-15)]); % %0x8000
    disp('--------');
end

armed = str2num(a(end-7));
measure = str2num(a(end-6));
wait = str2num(a(end-12));
filled = ~str2num(a(end-15));
timerout = str2num(a(end-2));

if display2
    fprintf('Armed: %d, Measure: %d, Wait: %d, timerout: %d, Filled %d\n', armed, measure, wait, timerout, filled);
end