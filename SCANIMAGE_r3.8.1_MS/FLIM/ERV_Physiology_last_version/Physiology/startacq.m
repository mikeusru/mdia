%Physiology scope software
%Emiliano Rial Verde
%October-November 2005
%Updated for better performance in Matlab 2006a. November 2006
%
%Script to update variable values, start the scope, and calculate Rs and Ri
%if no Cm calculation is to be done

switch acqmode
    case 1
        set(findobj('tag', 'statustext'), 'String', 'Updating...');
        drawnow
        for i=1:length(scopeaxes)
            eval(['set(scopeaxes{', num2str(i), '}, ''Visible'', ''off'');', ...
                'delete(scopeaxes{', num2str(i), '});']);
        end
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
        clear scopeaxes p pcm
        acq2;
        set(findobj('tag', 'statustext'), 'String', 'Ready');
    case 2
        if strcmp('Stop Seal', get(findobj('tag', 'startsealbutton'), 'String'))
            if exist('ai1', 'var') && exist('ai2', 'var')
                wait(ai1, 2); %This function name used to be "waittilstop" before version 7.
                wait(ai2, 2);
                set(findobj('tag', 'statustext'), 'String', 'Ready');
            elseif exist('ai1', 'var')
                stop(ai1);
            elseif exist('ai2', 'var')
                stop(ai2);
            end
            if exist('ao', 'var')
                stop(ao)
            end
            set(findobj('tag', 'startsealbutton'), 'String', 'Start Seal');
            set(findobj('tag', 'resetgraphbutton'), 'Visible', 'on');
            set(findobj('tag', 'resetNIcardbutton'), 'Visible', 'on');
        else
            set(findobj('tag', 'startsealbutton'), 'String', 'Stop Seal');
            set(findobj('tag', 'resetgraphbutton'), 'Visible', 'off');
            set(findobj('tag', 'resetNIcardbutton'), 'Visible', 'off');
            for i=1:length(scopeaxes)
                eval(['set(scopeaxes{', num2str(i), '}, ''Visible'', ''off'');', ...
                    'delete(scopeaxes{', num2str(i), '});']);
            end
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
            clear scopeaxes p pcm
            acq2;

            if exist('ao', 'var')
                delete(ao)
                clear ao
            end
            if exist('ai1', 'var')
                delete(ai1);
                clear ai1
            end
            if exist('ai2', 'var')
                delete(ai2);
                clear ai2
            end
            
            %Graphics layout
            acq_graph_layout;
            
            %Resets the Ri Rs Cm text to "-"
            set(findobj('Tag', 'rs1text'), 'String', '-');
            set(findobj('Tag', 'ri1text'), 'String', '-');
            set(findobj('Tag', 'cm1text'), 'String', '-');
            set(findobj('Tag', 'rs2text'), 'String', '-');
            set(findobj('Tag', 'ri2text'), 'String', '-');
            set(findobj('Tag', 'cm2text'), 'String', '-');
            set(findobj('Tag', 'rs3text'), 'String', '-');
            set(findobj('Tag', 'ri3text'), 'String', '-');
            set(findobj('Tag', 'cm3text'), 'String', '-');
            set(findobj('Tag', 'rs4text'), 'String', '-');
            set(findobj('Tag', 'ri4text'), 'String', '-');
            set(findobj('Tag', 'cm4text'), 'String', '-');
            
            %Device and channel definitions
            triggers=str2num(get(findobj('Tag', 'triggeredit'), 'string')); %Do not use str2double because it is unable to interpret comma separated numbers
            if length(triggers)==1
                triggers=[triggers triggers];
            end
            aoseal=str2double(get(findobj('Tag', 'aosealedit'), 'string'));
            if isnan(aoseal) %If AO for the seal test is NaN, the program uses the trigger of the amplifiers
                %Amplifier 1 acquisition object
                a=[str2double(get(findobj('Tag', 'a1ch1edit'), 'String')); str2double(get(findobj('Tag', 'a1ch2edit'), 'String')); ...
                    triggers(1)];
                if isempty(a(isnan(a(1:2))==0))
                else
                    if strcmp(device, 'winsound')==1
                        ai1=analoginput(device);
                    else
                        ai1=analoginput(device, aidevicenum);
                    end
                    set(ai1, 'InputType', inputtype);
                    ch1=addchannel(ai1, a(isnan(a)==0));
                    set(ch1, 'InputRange', inputrange, ...
                        'SensorRange', inputrange, ...
                        'UnitsRange', inputrange);
                    if isnan(triggers(1))
                        set(ai1, 'SamplesPerTrigger', samplespertrigger, ...
                            'SampleRate', samplerate, ...
                            'DataMissedFcn', 'status=1; statusfcn;', ...
                            'InputOverRangeFcn', 'status=2; statusfcn;', ...
                            'StartFcn', 'status=3; statusfcn;', ...
                            'StopFcn', 'status=4; statusfcn;', ...
                            'TriggerType', 'Immediate', ...
                            'TriggerRepeat', inf, ...
                            'TriggerDelay', 0, ...
                            'TriggerDelayUnits', 'Seconds', ...
                            'Tag', 'analogin1');
                    else
                        set(ai1, 'SamplesPerTrigger', samplespertrigger, ...
                            'SampleRate', samplerate, ...
                            'DataMissedFcn', 'status=1; statusfcn;', ...
                            'InputOverRangeFcn', 'status=2; statusfcn;', ...
                            'StartFcn', 'status=3; statusfcn;', ...
                            'StopFcn', 'status=4; statusfcn;', ...
                            'TriggerChannel', ch1(length(a(isnan(a)==0))), ...
                            'TriggerType', 'Software', ...
                            'TriggerRepeat', Inf, ...
                            'TriggerCondition', 'Falling', ...
                            'TriggerConditionValue', triggerconditionvalue, ...
                            'TriggerDelay', floor(testpulselength/2)*samplerate/1000, ...
                            'TriggerDelayUnits', 'Samples', ...
                            'Tag', 'analogin1');
                    end
                end

                %Amplifier 2 acquisition object
                a=[str2double(get(findobj('Tag', 'a2ch1edit'), 'String')); str2double(get(findobj('Tag', 'a2ch2edit'), 'String')); ...
                    triggers(2)];
                if isempty(a(isnan(a(1:2))==0))
                else
                    ai2=analoginput(device, aidevicenum);
                    set(ai2, 'InputType', inputtype);
                    ch2=addchannel(ai2, a(isnan(a)==0));
                    set(ch2, 'InputRange', inputrange, ...
                        'SensorRange', inputrange, ...
                        'UnitsRange', inputrange);
                    if isnan(triggers(2))
                        set(ai2, 'SamplesPerTrigger', samplespertrigger, ...
                            'SampleRate', samplerate, ...
                            'DataMissedFcn', 'status=1; statusfcn;', ...
                            'InputOverRangeFcn', 'status=2; statusfcn;', ...
                            'StartFcn', 'status=3; statusfcn;', ...
                            'StopFcn', 'status=4; statusfcn;', ...
                            'TriggerType', 'Immediate', ...
                            'TriggerRepeat', inf, ...
                            'TriggerDelay', 0, ...
                            'TriggerDelayUnits', 'Seconds', ...
                            'Tag', 'analogin2');
                    else
                        set(ai2, 'SamplesPerTrigger', samplespertrigger, ...
                            'SampleRate', samplerate, ...
                            'DataMissedFcn', 'status=1; statusfcn;', ...
                            'InputOverRangeFcn', 'status=2; statusfcn;', ...
                            'StartFcn', 'status=3; statusfcn;', ...
                            'StopFcn', 'status=4; statusfcn;', ...
                            'TriggerChannel', ch2(length(a(isnan(a)==0))), ...
                            'TriggerType', 'Software', ...
                            'TriggerRepeat', inf, ...
                            'TriggerCondition', 'Falling', ...
                            'TriggerConditionValue', triggerconditionvalue, ...
                            'TriggerDelay', floor(testpulselength/2)*samplerate/1000, ...
                            'TriggerDelayUnits', 'Samples', ...
                            'Tag', 'analogin2');
                    end
                end
            else %AO is not NaN a single acquisition object used for all headstages
                %Amplifiers acquisition object
                a=[str2double(get(findobj('Tag', 'a1ch1edit'), 'String')); str2double(get(findobj('Tag', 'a1ch2edit'), 'String')); ...
                    str2double(get(findobj('Tag', 'a2ch1edit'), 'String')); str2double(get(findobj('Tag', 'a2ch2edit'), 'String')); triggers(1)];
                if isempty(a(isnan(a(1:end-1))==0))
                else
                    ao=analogoutput(device, aodevicenum);
                    chout=addchannel(ao, aoseal);
                    set(chout, 'OutputRange', inputrange, ...
                        'UnitsRange', inputrange);
                    set(ao, 'SampleRate', samplerate, ...
                        'TriggerType', 'Immediate', ...
                        'RepeatOutput', Inf, ...
                        'Tag', 'recanalogout');
                    %Prepares the data to output controlling the repetition rate with the length of the vector dataout 
                    if ampchannelnum<3
                        dataout=zeros(100*samplerate/1000,1); %Total signal length is 100ms. So the pulse will be given at 10Hz
                    elseif ampchannelnum==3
                        dataout=zeros(150*samplerate/1000,1); %Total signal length is 150ms. So the pulse will be given at 7.5Hz
                    else
                        dataout=zeros(200*samplerate/1000,1); %Total signal length is 200ms. So the pulse will be given at 5Hz
                    end
                    dataout(120:370)=str2double(get(findobj('Tag', 'testamplitudeedit'), 'String'))/( mean(externalcommandsens)*1000);
                    %set(ao,'RepeatOutput', Inf);
                    putdata(ao, dataout);
                    if strcmp(device, 'winsound')==1
                        ai1=analoginput(device);
                    else
                        ai1=analoginput(device, aidevicenum);
                    end
                    set(ai1, 'InputType', inputtype);
                    ch1=addchannel(ai1, a(isnan(a)==0));
                    set(ch1, 'InputRange', inputrange, ...
                        'SensorRange', inputrange, ...
                        'UnitsRange', inputrange);
                    set(ai1, 'SamplesPerTrigger', samplespertrigger, ...
                        'SampleRate', samplerate, ...
                        'DataMissedFcn', 'status=1; statusfcn;', ...
                        'InputOverRangeFcn', 'status=2; statusfcn;', ...
                        'StartFcn', 'status=3; statusfcn;', ...
                        'StopFcn', 'status=4; statusfcn;', ...
                        'TriggerChannel', ch1(length(a(isnan(a)==0))), ...
                        'TriggerType', 'Software', ...
                        'TriggerRepeat', Inf, ...
                        'TriggerCondition', 'Falling', ...
                        'TriggerConditionValue', triggerconditionvalue, ...
                        'TriggerDelay', -(floor(testpulselength/2)+str2double(get(findobj('Tag', 'rsedit'), 'String'))/5)*samplerate/1000, ...
                        'TriggerDelayUnits', 'Samples', ...
                        'Tag', 'analogin1');
                end
            end
            %Plotting of data and calculations
            acq_scope_plot;
        end
end