%Physiology scope software
%Emiliano Rial Verde
%October-November 2005
%Updated for better performance in Matlab 2006a. November 2006
%
%Script to get the data from the engine and plot it on the scope window
clear data
if exist('ai1', 'var') && exist('ai2', 'var')
    ch1number=[str2double(get(findobj('Tag', 'a1ch1edit'), 'String')); str2double(get(findobj('Tag', 'a1ch2edit'), 'String'))];
    ch2number=[str2double(get(findobj('Tag', 'a2ch1edit'), 'String')); str2double(get(findobj('Tag', 'a2ch2edit'), 'String'))];
    if isnan(triggers(1)) && isnan(triggers(2))
        set(findobj('Tag', 'rsricm1'), 'Visible', 'off');
        set(findobj('Tag', 'rs1text'), 'Visible', 'off');
        set(findobj('Tag', 'ri1text'), 'Visible', 'off');
        set(findobj('Tag', 'cm1text'), 'Visible', 'off');
        set(findobj('Tag', 'rsricm2'), 'Visible', 'off');
        set(findobj('Tag', 'rs2text'), 'Visible', 'off');
        set(findobj('Tag', 'ri2text'), 'Visible', 'off');
        set(findobj('Tag', 'cm2text'), 'Visible', 'off');
        set(findobj('Tag', 'rs3text'), 'Visible', 'off');
        set(findobj('Tag', 'ri3text'), 'Visible', 'off');
        set(findobj('Tag', 'cm3text'), 'Visible', 'off');
        set(findobj('Tag', 'rs4text'), 'Visible', 'off');
        set(findobj('Tag', 'ri4text'), 'Visible', 'off');
        set(findobj('Tag', 'cm4text'), 'Visible', 'off');
    elseif isnan(triggers(1))
    elseif isnan(triggers(2))
    end
    
    set(ai1, 'TriggerRepeat', 1, 'StopFcn', '', 'StartFcn', '');
    set(ai2, 'TriggerRepeat', 1, 'StopFcn', '', 'StartFcn', '');
    set(findobj('tag', 'statustext'), 'String', 'Acquiring...');

     
    %This is just to have the variables in memory for faster access
    data1=zeros(samplespertrigger, 3);
    data2=zeros(samplespertrigger, 3);
    ydata=zeros(samplespertrigger,1);
    
    %Loop to get and plot the data
    for i=1:Inf
        
        acq_mctele;
        
        start(ai1);
        data1=getdata(ai1,samplespertrigger);
        if isnan(triggers(1))
        else
            data1(:, end)=[]; %Gets rid of the trigger channel
        end
        for j=1:size(data1,2)
            eval(['ydata=gainscalefactor(', num2str(j), ').*data1(:, ' num2str(j), ');']);
            eval(['set(p{', num2str(j), '} ,''ydata'', ydata);']);
            
            %Auto center routine
            if get(findobj('Tag', 'autocenterradio'), 'Value')==1
                centerpoint=mean(ydata);
                eval(['axislimit=get(scopeaxes{', num2str(j), '}(1) ,''YLim'');']);
                eval(['set(scopeaxes{', num2str(j), '}(1) ,''YLim'', [centerpoint-(axislimit(2)-axislimit(1))/2 centerpoint+(axislimit(2)-axislimit(1))/2]);']);
                eval(['set(scopeaxes{', num2str(j), '}(2), ''YLim'', get(scopeaxes{', num2str(j), '}(1), ''YLim''));']);
            end
            
            drawnow
            
            if isnan(triggers(1))
            else
                %Rs calculation
                baseline=mean(ydata(basewindowstart:basewindowend));
                rs=abs(testpulseamplitude)/(max(abs(ydata(rswindowstart:rswindowend)-baseline))*1e-3); %Rs in megaohms
                eval(['set(findobj(''tag'', ''rs', num2str(j), 'text''), ''String'', num2str(rs, ''%4.2f''));']);
                %Ri calculation
                ri=abs(1000*abs(testpulseamplitude)/(mean(ydata(riwindowstart:riwindowend))-baseline))-rs; %Ri in megaohms
                eval(['set(findobj(''tag'', ''ri', num2str(j), 'text''), ''String'', num2str(ri, ''%4.2f''));']);

                %Cm calculation
                if get(findobj('tag', 'cmradio'), 'Value')==1
                    a=ydata(rswindowstart:rswindowend);
                    if testpulseamplitude<0
                        timeindex=rswindowstart+find(a==min(a))-1;
                        a=a(find(a==(min(a))):end);
                        t=(0:1/samplerate:(size(a,1)/samplerate)-(1/samplerate)).*1000; %Time scale in milliseconds
                        betaa=nlinfit(t,(a-max(a))','acq_single_exp',[min(a) 1]);
                        yhat=acq_single_exp(betaa, t);
                        eval(['set(pcm{', num2str(j), '},''ydata'', yhat+max(a), ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                        drawnow
                    elseif testpulseamplitude>0
                        timeindex=rswindowstart+find(a==max(a))-1;
                        a=a(find(a==(max(a))):end);
                        t=(0:1/samplerate:(size(a,1)/samplerate)-(1/samplerate)).*1000; %Time scale in milliseconds
                        betaa=nlinfit(t,(a+min(a))','acq_single_exp',[max(a) 1]);
                        yhat=acq_single_exp(betaa, t);
                        eval(['set(pcm{', num2str(j), '},''ydata'', yhat-min(a), ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                        drawnow
                    end
                    cm=1000*betaa(2)/(ri*rs/(ri+rs));
                    eval(['set(findobj(''tag'', ''cm', num2str(j), 'text''), ''String'', num2str(cm, ''%4.2f''));']);
                end
            end
        end
        wait(ai1, 2); %This function name used to be "waittilstop" before version 7.

        start(ai2);
        data2=getdata(ai2,samplespertrigger);
        if isnan(triggers(2))
        else
            data2(:, end)=[]; %Gets rid of the trigger channel
        end
        for j=size(data1,2)+1:size(data1,2)+size(data2,2)
            eval(['ydata=gainscalefactor(', num2str(j), ').*data2(:, ' num2str(j-size(data1,2)), ');']);
            eval(['set(p{', num2str(j), '} ,''ydata'', ydata);']);
            %Auto center routine
            if get(findobj('Tag', 'autocenterradio'), 'Value')==1
                centerpoint=mean(ydata);
                eval(['axislimit=get(scopeaxes{', num2str(j), '}(1) ,''YLim'');']);
                eval(['set(scopeaxes{', num2str(j), '}(1) ,''YLim'', [centerpoint-(axislimit(2)-axislimit(1))/2 centerpoint+(axislimit(2)-axislimit(1))/2]);']);
                eval(['set(scopeaxes{', num2str(j), '}(2), ''YLim'', get(scopeaxes{', num2str(j), '}(1), ''YLim''));']);
            end

            drawnow
            
            if isnan(triggers(2))
            else
                %Rs calculation
                baseline=mean(ydata(basewindowstart:basewindowend));
                rs=abs(testpulseamplitude)/(max(abs(ydata(rswindowstart:rswindowend)-baseline))*1e-3); %Rs in megaohms
                eval(['set(findobj(''tag'', ''rs', num2str(j), 'text''), ''String'', num2str(rs, ''%4.2f''));']);
                %Ri calculation
                ri=abs(1000*abs(testpulseamplitude)/(mean(ydata(riwindowstart:riwindowend))-baseline))-rs; %Ri in megaohms
                eval(['set(findobj(''tag'', ''ri', num2str(j), 'text''), ''String'', num2str(ri, ''%4.2f''));']);

                %Cm calculation
                if get(findobj('tag', 'cmradio'), 'Value')==1
                    a=ydata(rswindowstart:rswindowend);
                    if testpulseamplitude<0
                        timeindex=rswindowstart+find(a==min(a))-1;
                        a=a(find(a==(min(a))):end);
                        t=(0:1/samplerate:(size(a,1)/samplerate)-(1/samplerate)).*1000; %Time scale in milliseconds
                        betaa=nlinfit(t,(a-max(a))','acq_single_exp',[min(a) 1]);
                        yhat=acq_single_exp(betaa, t);
                        eval(['set(pcm{', num2str(j), '},''ydata'', yhat+max(a), ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                        drawnow
                    elseif testpulseamplitude>0
                        timeindex=rswindowstart+find(a==max(a))-1;
                        a=a(find(a==(max(a))):end);
                        t=(0:1/samplerate:(size(a,1)/samplerate)-(1/samplerate)).*1000; %Time scale in milliseconds
                        betaa=nlinfit(t,(a+min(a))','acq_single_exp',[max(a) 1]);
                        yhat=acq_single_exp(betaa, t);
                        eval(['set(pcm{', num2str(j), '},''ydata'', yhat-min(a), ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                        drawnow
                    end
                    cm=1000*betaa(2)/(ri*rs/(ri+rs));
                    eval(['set(findobj(''tag'', ''cm', num2str(j), 'text''), ''String'', num2str(cm, ''%4.2f''));']);
                end
            end
        end
        wait(ai2, 2); %This function name used to be "waittilstop" before version 7.
        
        if strcmp('Start Seal', get(findobj('tag', 'startsealbutton'), 'String'))
            break
        end
    end

elseif exist('ai1', 'var')
    aicount=1;
    if ~isnan(aoseal)
        chnumber=[str2double(get(findobj('Tag', 'a1ch1edit'), 'String')); str2double(get(findobj('Tag', 'a1ch2edit'), 'String')); str2double(get(findobj('Tag', 'a2ch1edit'), 'String')); str2double(get(findobj('Tag', 'a2ch2edit'), 'String'))];
        chandtr=[str2double(get(findobj('Tag', 'a1ch1edit'), 'String')); str2double(get(findobj('Tag', 'a1ch2edit'), 'String')); str2double(get(findobj('Tag', 'a2ch1edit'), 'String')); str2double(get(findobj('Tag', 'a2ch2edit'), 'String')); triggers(1)];
        start(ao);
    else
        chnumber=[str2double(get(findobj('Tag', 'a1ch1edit'), 'String')); str2double(get(findobj('Tag', 'a1ch2edit'), 'String'))];
        chandtr=[str2double(get(findobj('Tag', 'a1ch1edit'), 'String')); str2double(get(findobj('Tag', 'a1ch2edit'), 'String')); triggers(1)];
    end
    start(ai1);
    data=zeros(samplespertrigger, length(chandtr(isnan(chandtr)==0)));

    %Index of the trigger channels in the data to remove them after getdata is called
    if isnan(triggers(1)) %No trigger case
        trimindex=0;
        set(findobj('Tag', 'rsricm1'), 'Visible', 'off');
        set(findobj('Tag', 'rs1text'), 'Visible', 'off');
        set(findobj('Tag', 'ri1text'), 'Visible', 'off');
        set(findobj('Tag', 'cm1text'), 'Visible', 'off');
        set(findobj('Tag', 'rsricm2'), 'Visible', 'off');
        set(findobj('Tag', 'rs2text'), 'Visible', 'off');
        set(findobj('Tag', 'ri2text'), 'Visible', 'off');
        set(findobj('Tag', 'cm2text'), 'Visible', 'off');
        set(findobj('Tag', 'rs3text'), 'Visible', 'off');
        set(findobj('Tag', 'ri3text'), 'Visible', 'off');
        set(findobj('Tag', 'cm3text'), 'Visible', 'off');
        set(findobj('Tag', 'rs4text'), 'Visible', 'off');
        set(findobj('Tag', 'ri4text'), 'Visible', 'off');
        set(findobj('Tag', 'cm4text'), 'Visible', 'off');
    else
        trimindex=length(chnumber(isnan(chnumber)==0))+1;
    end
    
    while strcmp(ai1.Running, 'On')
        if ai1.SamplesAcquired > samplespertrigger*aicount
            %Winsound case only happens in ai1
            if strcmp(device, 'winsound')==1
                if get(findobj('Tag', 'autoscaleradio'), 'Value')==1
                    if isnan(str2double(get(findobj('Tag', 'a1ch1edit'), 'String')))
                    else
                        set(scopeaxes{1}(1), 'YLimMode', 'auto');
                        set(scopeaxes{1}(2), 'YLim', get(scopeaxes{1}(1), 'YLim'));
                    end
                    if isnan(str2double(get(findobj('Tag', 'a1ch2edit'), 'String')))
                    else
                        set(scopeaxes{2}(1), 'YLimMode', 'auto');
                        set(scopeaxes{2}(2), 'YLim', get(scopeaxes{2}(1), 'YLim'));
                    end
                else
                    if isnan(str2double(get(findobj('Tag', 'a1ch1edit'), 'String')))
                    else
                        set(scopeaxes{1}(1), 'YLim', inputrange*yaxesscalefactor);
                        set(scopeaxes{1}(2), 'YLim', get(scopeaxes{1}(1), 'YLim'));
                    end
                    if isnan(str2double(get(findobj('Tag', 'a1ch2edit'), 'String')))
                    else
                        set(scopeaxes{2}(1), 'YLim', inputrange*yaxesscalefactor);
                        set(scopeaxes{2}(2), 'YLim', get(scopeaxes{2}(1), 'YLim'));
                    end
                end
            else
                acq_mctele;
            end
            if trimindex==0
                data=getdata(ai1,samplespertrigger);
            else
                data=getdata(ai1,samplespertrigger);
                data(:, trimindex)=[];
            end
            ydata=data(:,1); %This is just to have ydata in memory for faster access
            for j=1:size(data,2)
                eval(['ydata=gainscalefactor(', num2str(j), ').*data(:, ' num2str(j), ');']);
                eval(['set(p{', num2str(j), '} ,''ydata'', ydata);']);
                %Auto center routine
                if get(findobj('Tag', 'autocenterradio'), 'Value')==1
                    centerpoint=mean(ydata);
                    eval(['axislimit=get(scopeaxes{', num2str(j), '}(1) ,''YLim'');']);
                    eval(['set(scopeaxes{', num2str(j), '}(1) ,''YLim'', [centerpoint-(axislimit(2)-axislimit(1))/2 centerpoint+(axislimit(2)-axislimit(1))/2]);']);
                    eval(['set(scopeaxes{', num2str(j), '}(2), ''YLim'', get(scopeaxes{', num2str(j), '}(1), ''YLim''));']);
                end
                drawnow
                
                if isnan(triggers(1)) %In the no trigger case, no calculations are necessary
                else
                    %Rs calculation
                    baseline=mean(ydata(basewindowstart:basewindowend));
                    rs=abs(testpulseamplitude)/(max(abs(ydata(rswindowstart:rswindowend)-baseline))*1e-3); %Rs in megaohms
                    eval(['set(findobj(''tag'', ''rs', num2str(j), 'text''), ''String'', num2str(rs, ''%4.2f''));']);
                    %Ri calculation
                    ri=abs(1000*abs(testpulseamplitude)/(mean(ydata(riwindowstart:riwindowend))-baseline))-rs; %Ri in megaohms
                    eval(['set(findobj(''tag'', ''ri', num2str(j), 'text''), ''String'', num2str(ri, ''%4.2f''));']);

                    %Cm calculation
                    if get(findobj('tag', 'cmradio'), 'Value')==1
                        a=ydata(rswindowstart:rswindowend);
                        if testpulseamplitude<0
                            timeindex=rswindowstart+find(a==min(a))-1;
                            a=a(find(a==(min(a))):end);
                            t=(0:1/samplerate:(size(a,1)/samplerate)-(1/samplerate)).*1000; %Time scale in milliseconds
                            betaa=nlinfit(t,(a-max(a))','acq_single_exp',[min(a) 1]);
                            yhat=acq_single_exp(betaa, t);
                            eval(['set(pcm{', num2str(j), '},''ydata'', yhat+max(a), ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                            drawnow
                        elseif testpulseamplitude>0
                            timeindex=rswindowstart+find(a==max(a))-1;
                            a=a(find(a==(max(a))):end);
                            t=(0:1/samplerate:(size(a,1)/samplerate)-(1/samplerate)).*1000; %Time scale in milliseconds
                            betaa=nlinfit(t,(a+min(a))','acq_single_exp',[max(a) 1]);
                            yhat=acq_single_exp(betaa, t);
                            eval(['set(pcm{', num2str(j), '},''ydata'', yhat-min(a), ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                            drawnow
                        end
                        cm=1000*betaa(2)/(ri*rs/(ri+rs));
                        eval(['set(findobj(''tag'', ''cm', num2str(j), 'text''), ''String'', num2str(cm, ''%4.2f''));']);
                    end
                end
            end
            aicount=aicount+1;
        end
    end
    
elseif exist('ai2', 'var')
    chnumber=[str2double(get(findobj('Tag', 'a2ch1edit'), 'String')); str2double(get(findobj('Tag', 'a2ch2edit'), 'String'))];
    aicount=1;
    start(ai2);
    chandtr=[str2double(get(findobj('Tag', 'a2ch1edit'), 'String')); str2double(get(findobj('Tag', 'a2ch2edit'), 'String')); triggers(2)];
    data=zeros(samplespertrigger, length(chandtr(isnan(chandtr)==0)));

    %Index of the trigger channels in the data to remove them after getdata is called
    if isnan(triggers(2))
        trimindex=0;
        set(findobj('Tag', 'rsricm1'), 'Visible', 'off');
        set(findobj('Tag', 'rs1text'), 'Visible', 'off');
        set(findobj('Tag', 'ri1text'), 'Visible', 'off');
        set(findobj('Tag', 'cm1text'), 'Visible', 'off');
        set(findobj('Tag', 'rsricm2'), 'Visible', 'off');
        set(findobj('Tag', 'rs2text'), 'Visible', 'off');
        set(findobj('Tag', 'ri2text'), 'Visible', 'off');
        set(findobj('Tag', 'cm2text'), 'Visible', 'off');
        set(findobj('Tag', 'rs3text'), 'Visible', 'off');
        set(findobj('Tag', 'ri3text'), 'Visible', 'off');
        set(findobj('Tag', 'cm3text'), 'Visible', 'off');
        set(findobj('Tag', 'rs4text'), 'Visible', 'off');
        set(findobj('Tag', 'ri4text'), 'Visible', 'off');
        set(findobj('Tag', 'cm4text'), 'Visible', 'off');
    else
        trimindex=length(chnumber(isnan(chnumber)==0))+1;
    end

    while strcmp(ai2.Running, 'On')
        while ai2.SamplesAcquired > samplespertrigger*aicount
            acq_mctele;
            if trimindex==0
                data=getdata(ai2,samplespertrigger);
            else
                data=getdata(ai2,samplespertrigger);
                data(:, trimindex)=[];
            end
            ydata=data(:,1); %This is just to have ydata in memory for faster access
            for j=1:size(data,2)
                eval(['ydata=gainscalefactor(', num2str(j), ').*data(:, ' num2str(j), ');']);
                eval(['set(p{', num2str(j), '} ,''ydata'', ydata);']);
                %Auto center routine
                if get(findobj('Tag', 'autocenterradio'), 'Value')==1
                    centerpoint=mean(ydata);
                    eval(['axislimit=get(scopeaxes{', num2str(j), '}(1) ,''YLim'');']);
                    eval(['set(scopeaxes{', num2str(j), '}(1) ,''YLim'', [centerpoint-(axislimit(2)-axislimit(1))/2 centerpoint+(axislimit(2)-axislimit(1))/2]);']);
                    eval(['set(scopeaxes{', num2str(j), '}(2), ''YLim'', get(scopeaxes{', num2str(j), '}(1), ''YLim''));']);
                end
                drawnow
                if isnan(triggers(2))
                else
                    %Rs calculation
                    baseline=mean(ydata(basewindowstart:basewindowend));
                    rs=abs(testpulseamplitude)/(max(abs(ydata(rswindowstart:rswindowend)-baseline))*1e-3); %Rs in megaohms
                    eval(['set(findobj(''tag'', ''rs', num2str(j), 'text''), ''String'', num2str(rs, ''%4.2f''));']);
                    %Ri calculation
                    ri=abs(1000*abs(testpulseamplitude)/(mean(ydata(riwindowstart:riwindowend))-baseline))-rs; %Ri in megaohms
                    eval(['set(findobj(''tag'', ''ri', num2str(j), 'text''), ''String'', num2str(ri, ''%4.2f''));']);

                    %Cm calculation
                    if get(findobj('tag', 'cmradio'), 'Value')==1
                        a=ydata(rswindowstart:rswindowend);
                        if testpulseamplitude<0
                            timeindex=rswindowstart+find(a==min(a))-1;
                            a=a(find(a==(min(a))):end);
                            t=(0:1/samplerate:(size(a,1)/samplerate)-(1/samplerate)).*1000; %Time scale in milliseconds
                            betaa=nlinfit(t,(a-max(a))','acq_single_exp',[min(a) 1]);
                            yhat=acq_single_exp(betaa, t);
                            eval(['set(pcm{', num2str(j), '},''ydata'', yhat+max(a), ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                            drawnow
                        elseif testpulseamplitude>0
                            timeindex=rswindowstart+find(a==max(a))-1;
                            a=a(find(a==(max(a))):end);
                            t=(0:1/samplerate:(size(a,1)/samplerate)-(1/samplerate)).*1000; %Time scale in milliseconds
                            betaa=nlinfit(t,(a+min(a))','acq_single_exp',[max(a) 1]);
                            yhat=acq_single_exp(betaa, t);
                            eval(['set(pcm{', num2str(j), '},''ydata'', yhat-min(a), ''xdata'', timescale(timeindex:rswindowend), ''Visible'', ''on'');']);
                            drawnow
                        end
                        cm=1000*betaa(2)/(ri*rs/(ri+rs));
                        eval(['set(findobj(''tag'', ''cm', num2str(j), 'text''), ''String'', num2str(cm, ''%4.2f''));']);
                    end
                end
            end
            aicount=aicount+1;
        end
    end
end
