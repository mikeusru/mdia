%Physiology scope software
%Emiliano Rial Verde
%October-November 2005
%Updated for better performance in Matlab 2006a. November 2006
%
%Script to collect data from the main window before starting acquisition

%Info form DAQ board/s
device=get(findobj('Tag', 'devicepopup'), 'String');
device=device(get(findobj('Tag', 'devicepopup'), 'Value'),:);
device=deblank(device);
a=daqhwinfo;
if sum(strcmp(a.InstalledAdaptors, device))==0
    errordlg('The selected device is not available. Select another device.');
else
    if strcmp(device, 'winsound')
        inputrange=[-1 1]; %This is for winsound
        inputtype='AC-Coupled';
        defaultyaxis=['Soundcard volts'; 'Soundcard volts'];
        gainscalefactor=[1 1];
    elseif strcmp(device, 'nidaq')
        inputrange=[-10 10]; %This is for Multiclamp and nidaq
        inputtype='SingleEnded';
        a=daqhwinfo(device);
        if length(a.InstalledBoardIds)==1
            aidevicenum='Dev1';
            aodevicenum='Dev1';
        else
            if get(findobj('Tag', 'defaultboardradio'), 'Value')==1
                aidevicenum=1;%'Dev1';
                aodevicenum=1;%'Dev1';
            else
                if exist('boardsSelected', 'var')
                else
                    ok=0;
                    while ok==0
                        [aidevicenum,ok]=listdlg('ListString', a.BoardNames, 'Name', 'Select AI board', 'SelectionMode', 'single');
                    end
                    ok=0;
                    while ok==0
                        [aodevicenum,ok]=listdlg('ListString', a.BoardNames, 'Name', 'Select AO board', 'SelectionMode', 'single');
                    end
                    aidevicenum=a.InstalledBoardIds{aidevicenum};
                    aodevicenum=a.InstalledBoardIds{aodevicenum};
                    boardsSelected=1;
                end
            end
        end
    end

    %Channel info to assign graphic tags
    amplifiertext={'amp1'; 'amp1'; 'amp2'; 'amp2'};
    channeltext={'ch1'; 'ch2'; 'ch1'; 'ch2'};
    ampchannellayout=[str2double(get(findobj('Tag', 'a1ch1edit'), 'String')); ...
        str2double(get(findobj('Tag', 'a1ch2edit'), 'String')); ...
        str2double(get(findobj('Tag', 'a2ch1edit'), 'String')); ...
        str2double(get(findobj('Tag', 'a2ch2edit'), 'String'))];
    ampchannelnum=length(find(isnan(ampchannellayout)==0));
    scopeaxes{length(ampchannellayout)}=[];
    p{length(ampchannellayout)}=[];
    pcm{length(ampchannellayout)}=[];
    ylabels{length(ampchannellayout)}=[];

    %Resets the Y axes scale factor
    yaxesscalefactor=1;
    
    if strcmp(device, 'winsound')==1
        triggerconditionvalue=0.1;
    else
        %Calls the Multiclamp telegraph reader
        acq_mctele;
        if isnan(str2double(get(findobj('Tag', 'aosealedit'), 'string')))
            triggerconditionvalue=2; %This is for using the sync output of the amplifier
        else
            if mean(externalcommandsens)==0.02 || mean(externalcommandsens)==0.1
                triggerconditionvalue=str2double(get(findobj('Tag', 'testamplitudeedit'), 'String'))/( mean(externalcommandsens)*1000)/2;
            else
                errordlg('Make sure the External Command Sensitivity is the same for all headstages (20mV/V or 100mV/V)','External Command Sensitivity Error');
                triggerconditionvalue=NaN;
            end
        end
    end
    
    samplerate=str2double(get(findobj('Tag', 'samplerateedit'), 'String'));
    recsamplerate=str2double(get(findobj('Tag', 'recsamplerateedit'), 'String'));
    testpulselength=str2double(get(findobj('Tag', 'testlengthedit'), 'String')); %Test pulse length in milliseconds
    testpulseamplitude=str2double(get(findobj('Tag', 'testamplitudeedit'), 'String')); %Test pulse in mV
    defaulttimescalerange=[0 2*testpulselength]; %It goes from 0 to twice the length of the test pulse
    samplespertrigger=defaulttimescalerange(2)*samplerate/1000;
    timescale=0:1000/samplerate:(samplespertrigger*1000/samplerate)-1000/samplerate;

    %Info for seal test
    rswindow=[floor(testpulselength/2) floor(testpulselength/2)+str2double(get(findobj('Tag', 'rsedit'), 'String'))];
    riwindow=[floor(testpulselength/2)+testpulselength-str2double(get(findobj('Tag', 'riedit'), 'String')) floor(testpulselength/2)+testpulselength];
    basewindow=[1 floor(testpulselength/2)];
    rswindowstart=rswindow(1).*samplerate./1000;
    rswindowend=rswindow(2).*samplerate./1000;
    riwindowstart=riwindow(1).*samplerate./1000;
    riwindowend=riwindow(2).*samplerate./1000;
    basewindowstart=basewindow(1).*samplerate./1000;
    basewindowend=basewindow(2).*samplerate./1000;
end