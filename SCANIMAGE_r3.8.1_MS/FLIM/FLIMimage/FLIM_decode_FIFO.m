function [MT, ADC, Pixel, Line, Frame, Mark, MTOV, Rout, Invalid] = FLIM_decode_FIFO
global state

count1 = 10000;
data1 = ones(1,count1);
[out1, count1, data1] = calllib(state.spc.init.dllname,'SPC_read_fifo',state.spc.acq.module,count1,data1);
%data1 = data1(data1 ~= 0 & data1 ~= 1);
[str1, str0] = FLIM_hexBin(data1(1));
[str3, str2] = FLIM_hexBin(data1(2));
a1 = bin2dec(str0);
a2 = bin2dec(str1);
a3 = bin2dec(str2);
num1 = str2num([num2str(a1), num2str(a2), num2str(a3)]);
N_Routine = bin2dec(str3(2:5));

display(['Macro time clock = ', num2str(num1/10), 'ns']);
display(['Number of Routine bits = ', num2str(N_Routine)]);
n = (length(data1)-2)/2;

for i=1:n;
    j = i*2+1;
%     [str0, str1] = FLIM_hexBin(data1(j));
%     [str2, str3] = FLIM_hexBin(data1(j+1));
    [str1, str0] = FLIM_hexBin(data1(j));
    [str3, str2] = FLIM_hexBin(data1(j+1));

    MT(i) = bin2dec([str1(5:8), str0]);
    %ROUT{i} = str1(1:4);
    Pixel(i) = bin2dec(str1(4));
    Line(i) = bin2dec(str1(3));
    Frame(i) = bin2dec(str1(2));
    Rout(i) = bin2dec(str1(1)); %Should be 0???
    ADC(i) = bin2dec([str3(5:8), str2]);
    Mark(i) = bin2dec(str3(4));
    MTOV(i) = bin2dec(str3(2));
    Invalid(i) = bin2dec(str3(1));
end
ADC = (4095 - ADC)*state.spc.acq.SPCdata.tac_range /4096/state.spc.acq.SPCdata.tac_gain; 

function [strA, strB] = FLIM_hexBin(a)
str_a = dec2bin(a);
str0 = '0000000000000000';
str1 = [str0, str_a];
strA = str1(end-15:end-8);%The first half
strB = str1(end-7:end); %The second half