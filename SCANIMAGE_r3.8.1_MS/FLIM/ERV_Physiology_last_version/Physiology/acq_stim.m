%Physiology scope software
%Emiliano Rial Verde
%January 2006
%Updated for better performance in Matlab 2006a. November 2006
%
%Script to send a +5V pulso to an AO channel
%The samplerate is 10000Hz so the minimum pulse duration is 0.1ms

if exist('ao', 'var')
    stop(ao)
    delete(ao)
    clear ao
end

ao=analogoutput(device, aodevicenum);
chout=addchannel(ao, get(findobj('Tag', 'stimulationchannelnedit'), 'value')-1);
set(chout, 'OutputRange', inputrange, ...
    'UnitsRange', inputrange);
set(ao, 'SampleRate', 10000, ...
    'TriggerType', 'Immediate');

%Prepares the data to be outputed in the engine
stimdata=[zeros(10,1); zeros(10*str2double(get(findobj('Tag', 'stimulationdurationedit'), 'string')),1)+5; zeros(10,1)];
putdata(ao, stimdata);
start(ao)

wait(ao, 1); %This function name used to be "waittilstop" before version 7.

stop(ao)
delete(ao)
clear ao
