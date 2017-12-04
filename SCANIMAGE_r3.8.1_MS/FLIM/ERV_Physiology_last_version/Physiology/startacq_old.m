%Physiology scope software
%Emiliano Rial Verde
%October-November 2005
%Updated for better performance in Matlab 2006a. November 2006
%
%Script to update variable values, start the scope, and calculate Rs and Ri
%if no Cm calculation is to be done

switch acqmode
    case 1
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
            set(findobj('tag', 'startsealbutton'), 'String', 'Start Seal');
            set(findobj('tag', 'resetgraphbutton'), 'Visible', 'on');
        else
            set(findobj('tag', 'startsealbutton'), 'String', 'Stop Seal');
            set(findobj('tag', 'resetgraphbutton'), 'Visible', 'off');
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
            triggers=str2double(get(findobj('Tag', 'triggeredit'), 'string'));
            if length(triggers)==1
                triggers=[triggers triggers];
            end
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
                        
            %Plotting of data and calculations
            acq_scope_plot;                
        end
end