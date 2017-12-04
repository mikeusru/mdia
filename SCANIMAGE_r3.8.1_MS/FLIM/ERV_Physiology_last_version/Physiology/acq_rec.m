%Physiology scope software
%Emiliano Rial Verde
%October-November-December 2005
%
%Recording script
%
%File structure:
%
%File header:
%Year
%Month
%Day
%Number of channels acquired
%Acquisition rate in samples per second
%Sweep length in samples
%Inter-sweep interval
%Number of sweeps
%Header size
%Tail size
%
%Sweep tail (after each sweep of acquired data):
%Mode (0 is V-clamp, 1 is I-clamp)
%Gainscalefactor used
%Acquisition order
%Rs in megaOhms
%Ri in megaOhms
%Cm in picoFaradays
%
%

if exist('cmtimer', 'var')
    %stop(cmtimer)
    delete(cmtimer)
    clear cmtimer
end
if exist('ai1', 'var')
    %stop(ai1)
    delete(ai1)
    clear ai1
end
if exist('ai2', 'var')
    %stop(ai2)
    delete(ai2)
    clear ai2
end
if exist('ai', 'var')
    %stop(ai)
    delete(ai)
    clear ai
end
if exist('ao', 'var')
    %stop(ao)
    delete(ao)
    clear ao
end

set(findobj('Tag', 'recbutton'), 'String', 'Stop');
set(findobj('Tag', 'resetgraphbutton'), 'Visible', 'off');
set(findobj('tag', 'resetNIcardbutton'), 'Visible', 'off');
set(findobj('Tag', 'startsealbutton'), 'Visible', 'off');
%Input device and channel definitions
%Analog outputs (Note that Analog Outputs cannot be triggered with Analog Inputs)
a=[str2double(get(findobj('Tag', 'comch1edit'), 'String')); str2double(get(findobj('Tag', 'comch2edit'), 'String')); ...
    str2double(get(findobj('Tag', 'comch3edit'), 'String')); str2double(get(findobj('Tag', 'comch4edit'), 'String'))];
stimnumber=length(a(isnan(a)==0));
if isempty(a(isnan(a)==0))
else
    ao=analogoutput(device, aodevicenum);
    chout=addchannel(ao, a(isnan(a)==0));
    set(chout, 'OutputRange', inputrange, ...
        'UnitsRange', inputrange);
    if get(findobj('Tag', 'recpiftriggerradio'), 'Value')==1
        set(ao, 'SampleRate', recsamplerate, ...
            'TriggerType', 'HwDigital', ...  %Note that the TriggerCondition is NegativeEdge rather than PositiveEdge as stated in the help (Version: 7.1.0.246 (R14) Service Pack 3)
            'Tag', 'recanalogout');
    elseif get(findobj('Tag', 'recaitriggerradio'), 'Value')==1 %Note that this option does not provide precise timing!!!!!
        set(ao, 'SampleRate', recsamplerate, ...
            'TriggerType', 'Immediate', ...
            'Tag', 'recanalogout');
    else
        set(ao, 'SampleRate', recsamplerate, ...
            'TriggerType', 'Immediate', ...
            'Tag', 'recanalogout');
    end
    %Prepares the data to be outputed in the engine
    outputdata=[];
    dataout=[];
    for i=min(find(isnan(a)==0)):min(find(isnan(a)==0))+length(a(isnan(a)==0))-1
        eval(['outputdata=open([get(findobj(''Tag'', ''comch', num2str(i), ...
                'text''), ''UserData''), get(findobj(''Tag'', ''comch', ...
                num2str(i), 'text''), ''String'')]);']);
        if size(outputdata.outputdata,2)>1
            outputdata.outputdata=outputdata.outputdata';
        end
        dataout=[dataout outputdata.outputdata];
    end
    clear outputdata;
end

%Analog inputs
samplespertrigger=recsamplerate*str2double(get(findobj('Tag', 'sweeplengthedit'), 'String'))/1000;
triggerdelay=recsamplerate*str2double(get(findobj('Tag', 'rectimedelayedit'), 'String'))/1000;
triggerthreshold=str2double(get(findobj('Tag', 'recthresholdedit'), 'String'));
a=get(findobj('Tag', 'rectriggerconditionedit'), 'String');
if get(findobj('Tag', 'recpiftriggerradio'), 'Value')==1
    triggercondition=deblank(a(get(findobj('Tag', 'rectriggerconditionedit'), 'Value'),:));
    if strcmp('Rising', triggercondition)
        triggercondition='PositiveEdge';
    elseif strcmp('Falling', triggercondition)
        triggercondition='NegativeEdge';
    end
else
    triggercondition=deblank(a(get(findobj('Tag', 'rectriggerconditionedit'), 'Value'),:));
end

a=[str2double(get(findobj('Tag', 'recch1edit'), 'String')); str2double(get(findobj('Tag', 'recch2edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch3edit'), 'String')); str2double(get(findobj('Tag', 'recch4edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch5edit'), 'String')); str2double(get(findobj('Tag', 'recch6edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch7edit'), 'String')); str2double(get(findobj('Tag', 'recch8edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch9edit'), 'String')); str2double(get(findobj('Tag', 'recch10edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch11edit'), 'String')); str2double(get(findobj('Tag', 'recch12edit'), 'String'))];
a=a(isnan(a)==0);

if get(findobj('Tag', 'recpiftriggerradio'), 'Value')==1
    stimnumber=0;
elseif get(findobj('Tag', 'recaotriggerradio'), 'Value')==1 || get(findobj('Tag', 'recaitriggerradio'), 'Value')==1
    if isempty(find(a==get(findobj('Tag', 'rectriggerchanneledit'), 'Value')-1, 1))
        a=[a; get(findobj('Tag', 'rectriggerchanneledit'), 'Value')-1];
        triggerindex=length(a);
        stimnumber=1;
    else
        triggerindex=find(a==get(findobj('Tag', 'rectriggerchanneledit'), 'Value')-1);
        stimnumber=0;
    end
else
    stimnumber=0;
end

ai=analoginput(device, aidevicenum);
set(ai, 'InputType', inputtype);
chin=addchannel(ai, a);

set(chin, 'InputRange', inputrange, ...
    'SensorRange', inputrange, ...
    'UnitsRange', inputrange);

if get(findobj('Tag', 'recpiftriggerradio'), 'Value')==1
    set(ai, 'SamplesPerTrigger', samplespertrigger, ...
        'SampleRate', recsamplerate, ...
        'DataMissedFcn', 'status=5; statusfcn;', ...
        'InputOverRangeFcn', 'status=6; statusfcn;', ...
        'TriggerType', 'HwDigital', ...
        'Tag', 'recanalogin', ...
        'TriggerCondition', triggercondition, ...
        'TriggerDelay', triggerdelay, ...
        'TriggerDelayUnits', 'Samples');
elseif get(findobj('Tag', 'recaotriggerradio'), 'Value')==1 
    if exist('ao', 'var')
        set(ai, 'SamplesPerTrigger', samplespertrigger, ...
            'SampleRate', recsamplerate, ...
            'DataMissedFcn', 'status=5; statusfcn;', ...
            'InputOverRangeFcn', 'status=6; statusfcn;', ...
            'TriggerType', 'Software', ...
            'Tag', 'recanalogin', ...
            'TriggerChannel', chin(triggerindex), ...
            'TriggerCondition', triggercondition, ...
            'TriggerConditionValue', triggerthreshold, ...
            'TriggerDelay', triggerdelay, ...
            'TriggerDelayUnits', 'Samples');
    else
        h=warndlg({'No Analog Output channel and/or stimulation file selected.' 'Acquisition set to "no trigger" mode.'},'AO error!!!');
        set(ai, 'SamplesPerTrigger', samplespertrigger, ...
            'SampleRate', recsamplerate, ...
            'DataMissedFcn', 'status=5; statusfcn;', ...
            'InputOverRangeFcn', 'status=6; statusfcn;', ...
            'TriggerType', 'Immediate', ...
            'Tag', 'recanalogin');
    end
elseif get(findobj('Tag', 'recaitriggerradio'), 'Value')==1 
    set(ai, 'SamplesPerTrigger', samplespertrigger, ...
        'SampleRate', recsamplerate, ...
        'DataMissedFcn', 'status=5; statusfcn;', ...
        'InputOverRangeFcn', 'status=6; statusfcn;', ...
        'TriggerType', 'Software', ...
        'Tag', 'recanalogin', ...
        'TriggerChannel', chin(triggerindex), ...
        'TriggerCondition', triggercondition, ...
        'TriggerConditionValue', triggerthreshold, ...
        'TriggerDelay', triggerdelay, ...
        'TriggerDelayUnits', 'Samples');
    if exist('ao', 'var')
        set(ai, 'TriggerFcn', 'start(ao);'); %Note that this option does not provide precise timing!!!!!
    end
else
    set(ai, 'SamplesPerTrigger', samplespertrigger, ...
        'SampleRate', recsamplerate, ...
        'DataMissedFcn', 'status=5; statusfcn;', ...
        'InputOverRangeFcn', 'status=6; statusfcn;', ...
        'TriggerType', 'Immediate', ...
        'Tag', 'recanalogin');
end
%Channel info to assign graphic tags and indeces
a=[str2double(get(findobj('Tag', 'recch1edit'), 'String')); str2double(get(findobj('Tag', 'recch2edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch3edit'), 'String')); str2double(get(findobj('Tag', 'recch4edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch5edit'), 'String')); str2double(get(findobj('Tag', 'recch6edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch7edit'), 'String')); str2double(get(findobj('Tag', 'recch8edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch9edit'), 'String')); str2double(get(findobj('Tag', 'recch10edit'), 'String')); ...
        str2double(get(findobj('Tag', 'recch11edit'), 'String')); str2double(get(findobj('Tag', 'recch12edit'), 'String'))];

recchannelnum=sum(isnan(a)==0);
scopeaxes{12}=[];
p{12}=[];
pcm{4}=[];
ylabels{12}=[];

%Resets the Y axes scale factor
yaxesscalefactor=1;

%Calls the Multiclamp telegraph reader
acq_mctele;

%Info for graph_layout and seal test
timescale=0:1000/recsamplerate:(samplespertrigger*1000/recsamplerate)-1000/recsamplerate;
defaulttimescalerange=[0 timescale(end)];

%Info for seal test
if get(findobj('tag', 'recrsradio'), 'Value')==1 || get(findobj('tag', 'recriradio'), 'Value')==1 || get(findobj('tag', 'reccmradio'), 'Value')==1
    testpulseamplitude=str2double(get(findobj('Tag', 'rectestamplitudeedit'), 'String')); %Test pulse in mV
    testpulselength=str2double(get(findobj('Tag', 'rectestlengthedit'), 'String')); %Test pulse length in milliseconds
    testpulsestart=str2double(get(findobj('Tag', 'rectestpulsestartedit'), 'String'));
    baselineoffset=testpulsestart-str2double(get(findobj('Tag', 'recbaseedit'), 'String'));
    basewindow=[str2double(get(findobj('Tag', 'recbaseedit'), 'String'))-0.9*str2double(get(findobj('Tag', 'recbaseedit'), 'String')), ...
        0.9*str2double(get(findobj('Tag', 'recbaseedit'), 'String'))]+baselineoffset;
    rswindow=[testpulsestart testpulsestart+str2double(get(findobj('Tag', 'recrsedit'), 'String'))];
    riwindow=[testpulsestart+testpulselength-str2double(get(findobj('Tag', 'recriedit'), 'String')), ...
        testpulsestart+testpulselength-1]; %It subtracts 1ms from the end of the pulse to avoid artefacts
    rswindowstart=rswindow(1).*recsamplerate./1000;
    rswindowend=rswindow(2).*recsamplerate./1000;
    riwindowstart=riwindow(1).*recsamplerate./1000;
    riwindowend=riwindow(2).*recsamplerate./1000;
    basewindowstart=basewindow(1).*recsamplerate./1000;
    basewindowend=basewindow(2).*recsamplerate./1000;
end

%Graphics layout
acq_graph_layout;
acq_moregraph_layout;

if get(findobj('Tag', 'donotrecordradio'), 'Value')==0
    %Retrieves file information
    acquisitionfile=[get(findobj('Tag', 'recfiletext'), 'UserData'), get(findobj('Tag', 'recfiletext'), 'String')];
    bin=fopen(acquisitionfile, 'a+');

    %File header:
    %Year
    %Month
    %Day
    %Number of channels acquired
    %Acquisition rate in samples per second
    %Sweep length in samples
    %Inter-sweep interval
    %Number of sweeps
    %Header size
    %Tail size

    %Sweep tail (after each sweep of acquired data):
    %Mode (0 is V-clamp, 1 is I-clamp)
    %Gainscalefactor used
    %Acquisition order
    %Rs in megaOhms
    %Ri in megaOhms
    %Cm in picoFaradays
    rs=NaN;
    ri=NaN;
    cm=NaN;
    tail=zeros(6,1); %UPDATE IF TAIL SIZE CHANGES!!!
    headersize=10; %UPDATE IF HEADER SIZE CHANGES!!!
    headsweepnum=8; %UPDATE IF HEADER SIZE CHANGES!!! This is the position of the "number of sweeps" information in the header
    tailsize=6; %UPDATE IF TAIL SIZE CHANGES!!!
    a=fix(clock);
    head=[a(1); a(2); a(3); length(ai.Channel.Index)-stimnumber; recsamplerate; samplespertrigger; ...
        str2double(get(findobj('Tag', 'sweepintervaledit'), 'String')); ...
        str2double(get(findobj('Tag', 'sweepnumberedit'), 'String')); headersize; tailsize];
    fwrite(bin , head, 'float');
end

%Timer to define inter-sweep intervals
if str2double(get(findobj('Tag', 'sweepintervaledit'), 'String'))>0
    if exist('IStimer', 'var')
        delete(IStimer);
        clear IStimer
    end
    if get(findobj('Tag', 'recpiftriggerradio'), 'Value')==1 %PFI trigger case. The timer waits 500ms less than stated in IS interval to ensure the following trigger will be detected
        IStimer=timer('StartDelay',max([0 str2double(get(findobj('Tag', 'sweepintervaledit'), 'String'))/1000-0.5]), ...
            'StartFcn','set(findobj(''tag'', ''timerstatustext''), ''Visible'', ''on'');', ...
            'TimerFcn','set(findobj(''tag'', ''timerstatustext''), ''Visible'', ''off'');');
    else %AO trigger or immediate trigger cases. The IS timer waits all the stated interval
        IStimer=timer('StartDelay',str2double(get(findobj('Tag', 'sweepintervaledit'), 'String'))/1000, ...
            'StartFcn','set(findobj(''tag'', ''timerstatustext''), ''Visible'', ''on'');', ...
            'TimerFcn','set(findobj(''tag'', ''timerstatustext''), ''Visible'', ''off'');');
    end
end

%Acquisition timeout
if str2double(get(findobj('Tag', 'sweepintervaledit'), 'String'))==0
    waitingtime=str2double(get(findobj('Tag', 'sweeplengthedit'), 'String'))/1000+10;
else
    waitingtime=str2double(get(findobj('Tag', 'sweeplengthedit'), 'String'))/1000+10*str2double(get(findobj('Tag', 'sweepintervaledit'), 'String'))/1000;
end

%Starts acquisition
set(findobj('Tag', 'acqnumbertext'), 'String', '0');
status=7; statusfcn;
for k=1:str2double(get(findobj('Tag', 'sweepnumberedit'), 'String'))
    if strcmp('Stopping...', get(findobj('Tag', 'recstatustext'), 'String'))
        stoppinganswer = questdlg('Stop acquisition?','Confirm Stop','Stop','Continue','Stop');
        if strcmp('Stop', stoppinganswer)
            if get(findobj('Tag', 'donotrecordradio'), 'Value')==0
                fclose(bin);
                bin=fopen(acquisitionfile);
                a=fread(bin, 'float');
                fclose(bin);
                a(headsweepnum)=k-1;
                bin=fopen(acquisitionfile, 'w');
                fwrite(bin , a, 'float');
            end
            break
        else
            set(findobj('Tag', 'recstatustext'), 'String', 'Recording...')
        end
    end    
    start(ai)
    if exist('ao', 'var')
        putdata(ao, dataout)
        if get(findobj('Tag', 'recaotriggerradio'), 'Value')==1 || get(findobj('Tag', 'recpiftriggerradio'), 'Value')==1
            start(ao)
        end
    end
    wait(ai, waitingtime); %This function name used to be "waittilstop" before version 7.
    data=getdata(ai,samplespertrigger);
    stop(ai)
    if exist('ao', 'var')
        stop(ao)
    end
    acq_mctele;
    ydata=data(:,1); %This is just to have ydata in memory for faster access
    
    if get(findobj('tag', 'recmeanradio'), 'Value')==1
        onlinetraceaveragen=onlinetraceaveragen+1;
    else
        onlinetraceaveragen=0;
    end
    
    for j=1:ampchannelnum
        eval(['ydata=gainscalefactor(', num2str(j), ').*data(:, ' num2str(j), ');']);
        eval(['set(p{', num2str(j), '} ,''ydata'', ydata);']);

        %Online averaging routine
        if onlinetraceaveragen==0
            eval(['set(pav{', num2str(j), '} ,''visible'', ''off'');']);
        elseif onlinetraceaveragen==1
            eval(['onlinetraceaverage{', num2str(j), '}=ydata;']);
        elseif onlinetraceaveragen>1
            eval(['onlinetraceaverage{', num2str(j), '}=(((onlinetraceaveragen-1)*onlinetraceaverage{', num2str(j), '})+ydata)/onlinetraceaveragen;']);
            eval(['set(pav{', num2str(j), '} ,''ydata'', onlinetraceaverage{', num2str(j), '}, ''visible'', ''on'');']);
        end
        
        %Auto center routine
        if get(findobj('Tag', 'autocenterradio'), 'Value')==1
            centerpoint=mean(ydata);
            eval(['axislimit=get(scopeaxes{', num2str(j), '}(1) ,''YLim'');']);
            eval(['set(scopeaxes{', num2str(j), '}(1) ,''YLim'', [centerpoint-(axislimit(2)-axislimit(1))/2 centerpoint+(axislimit(2)-axislimit(1))/2]);']);
            eval(['set(scopeaxes{', num2str(j), '}(2), ''YLim'', get(scopeaxes{', num2str(j), '}(1), ''YLim''));']);
        end
        drawnow

        if get(findobj('tag', 'recrsradio'), 'Value')==1
            %Rs calculation
            baseline=mean(ydata(basewindowstart:basewindowend));
            rs=abs(testpulseamplitude)/(max(abs(ydata(rswindowstart:rswindowend)-baseline))*1e-3); %Rs in megaohms
            eval(['set(findobj(''tag'', ''rs', num2str(j), 'text''), ''String'', num2str(rs, ''%4.2f''));']);
        end
        if get(findobj('tag', 'recriradio'), 'Value')==1
            %Ri calculation
            ri=abs(1000*abs(testpulseamplitude)/(mean(ydata(riwindowstart:riwindowend))-baseline))-rs; %Ri in megaohms
            eval(['set(findobj(''tag'', ''ri', num2str(j), 'text''), ''String'', num2str(ri, ''%4.2f''));']);
        end

        if get(findobj('tag', 'reccmradio'), 'Value')==1
            %Cm calculation
            a=ydata(rswindowstart:rswindowend);
            if testpulseamplitude<0
                timeindex=rswindowstart+find(a==min(a))-1;
                a=a(find(a==(min(a))):end);
                t=(0:1/recsamplerate:(size(a,1)/recsamplerate)-(1/recsamplerate)).*1000; %Time scale in milliseconds
                betaa=nlinfit(t,(a)','acq_single_exp',[min(a) 1]);
                yhat=acq_single_exp(betaa, t);
                eval(['set(pcm{', num2str(j), '},''ydata'', yhat, ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                drawnow
            elseif testpulseamplitude>0
                timeindex=rswindowstart+find(a==max(a))-1;
                a=a(find(a==(max(a))):end);
                t=(0:1/recsamplerate:(size(a,1)/recsamplerate)-(1/recsamplerate)).*1000; %Time scale in milliseconds
                betaa=nlinfit(t,(a)','acq_single_exp',[max(a) 1]);
                yhat=acq_single_exp(betaa, t);
                eval(['set(pcm{', num2str(j), '},''ydata'', yhat, ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                drawnow
            end
            cm=1000*betaa(2)/(ri*rs/(ri+rs));
            eval(['set(findobj(''tag'', ''cm', num2str(j), 'text''), ''String'', num2str(cm, ''%4.2f''));']);
        end
        if get(findobj('Tag', 'donotrecordradio'), 'Value')==0
            %Records the acquired data to a file
            tail=[mode; gainscalefactor; j; rs; ri; cm];
            fwrite(bin , [ydata; tail], 'float');
        end
    end

    if recchannelnum>ampchannelnum
        for j=j+1:recchannelnum
            eval(['ydata=data(:, ' num2str(j), ');']);
            eval(['set(p{', num2str(j), '} ,''ydata'', ydata);']);
            drawnow

            if get(findobj('Tag', 'donotrecordradio'), 'Value')==0
                %Records the acquired data to a file
                tail=[nan; nan; j; nan; nan; nan];
                fwrite(bin , [ydata; tail], 'float');
            end
        end
    end

    set(findobj('Tag', 'acqnumbertext'), 'String', num2str(k));
    
    %Sweep interval
    if k~=str2double(get(findobj('Tag', 'sweepnumberedit'), 'String')) %It does not wait after acquiring the last sweep 
        if str2double(get(findobj('Tag', 'sweepintervaledit'), 'String'))>0
            start(IStimer);
            wait(IStimer) %This function name used to be "waittilstop" before version 7.
        end
    end
end

if str2double(get(findobj('Tag', 'sweepintervaledit'), 'String'))>0
    if exist('IStimer', 'var')
        delete(IStimer);
        clear IStimer
    end
end

if get(findobj('Tag', 'donotrecordradio'), 'Value')==0
    fclose(bin);
    a=get(findobj('Tag', 'recfiletext'), 'String');
    numstart=strfind(a, '_')+1;
    numend=strfind(a, '.')-1;
    set(findobj('Tag', 'recfiletext'), 'String', ...
        [a(1:7), num2str(str2double(a(numstart:numend))+1), '.dat']);
end
status=8; statusfcn;
set(findobj('Tag', 'recbutton'), 'String', 'Record');
set(findobj('Tag', 'resetgraphbutton'), 'Visible', 'on');
set(findobj('tag', 'resetNIcardbutton'), 'Visible', 'on');
set(findobj('Tag', 'startsealbutton'), 'Visible', 'on');