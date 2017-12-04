function acq_defaults

%Physiology scope software
%Emiliano Rial Verde
%January 2007
%
%User Defaults loader
%User defaults file structure:
%
%1) Acquisition device: 1=nidaq 2=winsound.
%2) Default acquisition board: 1=Uses the default acquisition board 0=Selects the board manually.
%3) Trigger Channel/s: Enter "nan" for continuous mode (no trigger). Separate with commas if more than one (different triggers for amplifier 1 and 2 for example).
%4) Amplifier 1 Channel 1: Enter "nan" if you don't want to acquire, or the channel number using NIDAQ nomenclature (0 to 31 for PCI 6959).
%5) Amplifier 1 Channel 2: Enter "nan" if you don't want to acquire, or the channel number using NIDAQ nomenclature (0 to 31 for PCI 6959).
%6) Amplifier 2 Channel 1: Enter "nan" if you don't want to acquire, or the channel number using NIDAQ nomenclature (0 to 31 for PCI 6959).
%7) Amplifier 2 Channel 2: Enter "nan" if you don't want to acquire, or the channel number using NIDAQ nomenclature (0 to 31 for PCI 6959).
%8) Test pulse amplitude in mV.
%9) Test pulse length in ms.
%10) Length of the window (in ms) over which peak current is searched to calculate series resistance.
%11) Length of the window (in ms) over which current is averaged to calculate input resistance.
%12) Membrane capacitance calculation: 1=Performs the calculation 0=It does not calculate Cm.
%13) Acquisition rate for the seal test in Hz.
%14) Sweep length in ms.
%15) Inter-sweep interval in ms.
%16) Number of sweeps to acquire (inf is a valid entry).
%17) Recording channel number 5 (1 to 4 are reserved for the amplifiers. Defaults number 4 to 7).
%18) Recording channel number 6 (1 to 4 are reserved for the amplifiers. Defaults number 4 to 7).
%19) Recording channel number 7 (1 to 4 are reserved for the amplifiers. Defaults number 4 to 7).
%20) Recording channel number 8 (1 to 4 are reserved for the amplifiers. Defaults number 4 to 7).
%21) Recording channel number 9 (1 to 4 are reserved for the amplifiers. Defaults number 4 to 7).
%22) Recording channel number 10 (1 to 4 are reserved for the amplifiers. Defaults number 4 to 7).
%23) Recording channel number 11 (1 to 4 are reserved for the amplifiers. Defaults number 4 to 7).
%24) Recording channel number 12 (1 to 4 are reserved for the amplifiers. Defaults number 4 to 7).
%25) Analog output channel number 1: Enter "nan" if you don't want to use AO, or the channel number using NIDAQ nomenclature (0 to 3 for PCI 6959).
%26) Analog output channel number 2: Enter "nan" if you don't want to use AO, or the channel number using NIDAQ nomenclature (0 to 3 for PCI 6959).
%27) Analog output channel number 3: Enter "nan" if you don't want to use AO, or the channel number using NIDAQ nomenclature (0 to 3 for PCI 6959).
%28) Analog output channel number 4: Enter "nan" if you don't want to use AO, or the channel number using NIDAQ nomenclature (0 to 3 for PCI 6959).
%29) Default location of stimulation files
%30) Default stimulation file for analog output channel number 1: ?=no file.
%31) Default stimulation file for analog output channel number 2: ?=no file.
%32) Default stimulation file for analog output channel number 3: ?=no file.
%33) Default stimulation file for analog output channel number 4: ?=no file.
%34) Analog input channel that triggers acquisition using NIDAQ nomenclature (0 to 31 for PCI 6959).
%35) Trigger threshold level. This is Volts into the trigger channel.
%36) Length, in ms, of the pre/post-trigger (negative values for pre-triggers and positive values for post-triggers).
%37) Default trigger condition: 1=Rising 2=Falling
%38) Default trigger mode. Valid values (use all capitals): AO, AI, PFI, NONE.
%39) Series resistance calculation: 1=Performs the calculation 0=It does not calculate Rs
%40) Input resistance calculation: 1=Performs the calculation 0=It does not calculate Ri
%41) Membrane capacitance calculation: 1=Performs the calculation 0=It does not calculate Cm
%42) Length of the baseline for Rs, Ri and Cm calculation in recording mode (in ms).
%43) Default folder to save acquisition files (without last "\").
%44) Default recording mode. 1=Do not record. 0=Record.
%45) Duration, in ms, of the pulse sent by the "Stimulation" button. Minimum is 0.1ms.
%46) Analog output used by the "Stimulation" button using NIDAQ nomenclature (0 to 3 for PCI 6959)
%47) Acquisition rate for Recording in Hz.
%48) Analog output channel to use for seal test (to use the amplifier test pulse enter nan)
%49) Start of the test pulse for Rs, Ri and Cm calculation in recording mode (in ms after the start of the sweep).
%50) ERV Physiology Scope window position. This 4 number vector lets you customize the window size and position.
%51) ERV Physiology Recorder window position. This 4 number vector lets you customize the window size and position.


%Reads the defaults file
filename=get(findobj('Tag','defaultspopup'), 'String');
filename=filename{get(findobj('Tag','defaultspopup'), 'Value')};
fid=fopen(['C:\Program Files\acq\settings\', filename]);
a=textscan(fid, '%s', 'commentStyle', '%', 'delimiter', '');
a=a{1};
fclose(fid);

%Resizes the windows if necessary. Note: Use STR2NUM instead of STR2DOUBLE
if str2num(a{50})~=0
    set(findobj('Tag', 'mainwindow'), 'Position', str2num(a{50}));
end
if str2num(a{51})~=0
    set(findobj('Tag', 'recwindow'), 'Position', str2num(a{51}));
end

%Applies scope window defaults
set(findobj('Tag', 'devicepopup'), 'Value', str2double(a{1}));
set(findobj('Tag', 'defaultboardradio'), 'Value', str2double(a{2}));
if str2double(a{2})==1
    set(findobj('Tag', 'selectboardradio'), 'Value', 0);
else
    set(findobj('Tag', 'selectboardradio'), 'Value', 1);
end
set(findobj('Tag','triggeredit'), 'String', a{3});
set(findobj('Tag','a1ch1edit'), 'String', a{4});
set(findobj('Tag','a1ch2edit'), 'String', a{5});
set(findobj('Tag','a2ch1edit'), 'String', a{6});
set(findobj('Tag','a2ch2edit'), 'String', a{7});
set(findobj('Tag','testamplitudeedit'), 'String', a{8});
set(findobj('Tag','testlengthedit'), 'String', a{9});
set(findobj('Tag','rsedit'), 'String', a{10});
set(findobj('Tag','riedit'), 'String', a{11});
set(findobj('Tag', 'cmradio'), 'Value', str2double(a{12}));
set(findobj('Tag','samplerateedit'), 'String', a{13});
set(findobj('Tag','aosealedit'), 'String', a{48});


%Applies recorder window defaults
set(findobj('Tag','sweeplengthedit'), 'String', a{14});
set(findobj('Tag','sweepintervaledit'), 'String', a{15});
set(findobj('Tag','sweepnumberedit'), 'String', a{16});
set(findobj('Tag','acqtimetext'), 'String',num2str(str2double(a{16})*str2double(a{14})*0.001));
set(findobj('Tag','acqtime2text'), 'String',num2str(str2double(a{16})*(str2double(a{14})+str2double(a{15}))*0.001));
set(findobj('Tag','recch1edit'), 'String', a{4});
set(findobj('Tag','recch2edit'), 'String', a{5});
set(findobj('Tag','recch3edit'), 'String', a{6});
set(findobj('Tag','recch4edit'), 'String', a{7});
set(findobj('Tag','recch5edit'), 'String', a{17});
set(findobj('Tag','recch6edit'), 'String', a{18});
set(findobj('Tag','recch7edit'), 'String', a{19});
set(findobj('Tag','recch8edit'), 'String', a{20});
set(findobj('Tag','recch9edit'), 'String', a{21});
set(findobj('Tag','recch10edit'), 'String', a{22});
set(findobj('Tag','recch11edit'), 'String', a{23});
set(findobj('Tag','recch12edit'), 'String', a{24});
set(findobj('Tag','comch1edit'), 'String', a{25});
set(findobj('Tag','comch2edit'), 'String', a{26});
set(findobj('Tag','comch3edit'), 'String', a{27});
set(findobj('Tag','comch4edit'), 'String', a{28});
set(findobj('Tag','comch1text'), 'String', a{30}, 'UserData', a{29}, 'ToolTipString', ['Stim. file for AO #1: ', a{29}, a{30}]);
set(findobj('Tag','comch2text'), 'String', a{31}, 'UserData', a{29}, 'ToolTipString', ['Stim. file for AO #2: ', a{29}, a{31}]);
set(findobj('Tag','comch3text'), 'String', a{32}, 'UserData', a{29}, 'ToolTipString', ['Stim. file for AO #3: ', a{29}, a{32}]);
set(findobj('Tag','comch4text'), 'String', a{33}, 'UserData', a{29}, 'ToolTipString', ['Stim. file for AO #4: ', a{29}, a{33}]);
set(findobj('Tag', 'rectriggerchanneledit'), 'Value', str2double(a{34})+1);
set(findobj('Tag','recthresholdedit'), 'String', a{35});
set(findobj('Tag','rectimedelayedit'), 'String', a{36});
set(findobj('Tag', 'rectriggerconditionedit'), 'Value', str2double(a{37}));
if strcmp(a{38}, 'AO')
    set(findobj('Tag', 'recaotriggerradio'), 'Value', 1, 'Visible', 'on');
    set(findobj('Tag', 'recaotriggertext'), 'Visible', 'on');
    set(findobj('Tag', 'recaitriggerradio'), 'Value', 0, 'Visible', 'off');
    set(findobj('Tag', 'recpiftriggerradio'), 'Value', 0, 'Visible', 'off');
elseif strcmp(a{38}, 'AI')
    set(findobj('Tag', 'recaotriggerradio'), 'Value', 0, 'Visible', 'off');
    set(findobj('Tag', 'recaotriggertext'), 'Visible', 'off');        
    set(findobj('Tag', 'recaitriggerradio'), 'Value', 1, 'Visible', 'on');
    set(findobj('Tag', 'recpiftriggerradio'), 'Value', 0, 'Visible', 'off');
elseif strcmp(a{38}, 'PFI')
    set(findobj('Tag', 'recaotriggerradio'), 'Value', 0, 'Visible', 'off');
    set(findobj('Tag', 'recaotriggertext'), 'Visible', 'off');
    set(findobj('Tag', 'recaitriggerradio'), 'Value', 0, 'Visible', 'off');
    set(findobj('Tag', 'recpiftriggerradio'), 'Value', 1, 'Visible', 'on');
else
    set(findobj('Tag', 'recaotriggerradio'), 'Value', 0, 'Visible', 'on');
    set(findobj('Tag', 'recaotriggertext'), 'Visible', 'off');
    set(findobj('Tag', 'recaitriggerradio'), 'Value', 0, 'Visible', 'on');
    set(findobj('Tag', 'recpiftriggerradio'), 'Value', 0, 'Visible', 'on');
end
set(findobj('Tag', 'recrsradio'), 'Value', str2double(a{39}));
set(findobj('Tag', 'recriradio'), 'Value', str2double(a{40}));
set(findobj('Tag', 'reccmradio'), 'Value', str2double(a{41}));
set(findobj('Tag','rectestamplitudeedit'), 'String', a{8});
set(findobj('Tag','rectestlengthedit'), 'String', a{9});
set(findobj('Tag','recrsedit'), 'String', a{10});
set(findobj('Tag','recriedit'), 'String', a{11});
set(findobj('Tag','recbaseedit'), 'String', a{42});
set(findobj('Tag','rectestpulsestartedit'), 'String', a{49});
d=dir([a{43}, '\', datestr(date, 'mmddyy'), '_*.dat']);
str={d.name};
if isempty(str)
    str=[datestr(date, 'mmddyy'), '_1.dat'];
else
    b=[];
    for i=1:length(str)
        b=[b str2double(str{i}(strfind(str{i}, '_')+1:end-4))];
    end
    str=[datestr(date, 'mmddyy'), '_', num2str(max(b)+1), '.dat'];
end
set(findobj('Tag','recfiletext'), 'String', str, 'ToolTipString', [a{43}, '\', str], 'UserData', [a{43}, '\']);
set(findobj('Tag', 'donotrecordradio'), 'Value', str2double(a{44}));
set(findobj('Tag','stimulationdurationedit'), 'String', a{45});
set(findobj('Tag','stimulationchannelnedit'), 'Value', str2double(a{46})+1);
set(findobj('Tag','recsamplerateedit'), 'String', a{47});