%Physiology scope software
%Emiliano Rial Verde
%October-November 2005
%December 2005-January 2006 Version 2 changes
%Updated for better performance in Matlab 2006a. November 2006
%
%Script to collect data from the Multiclamp state
%
%Info from Multiclamp amplifiers read from text file into in structure "a"
%Serial_Number a{2}
%Channel_ID a{4}
%Mode a{6}
%Primary_Scale_Factor a{8}
%Primary_Scale_Factor_Units a{10}
%Primary_Gain a{12}
%Secondary_Scale_Factor a{14}
%Secondary_Scale_Factor_Units  a{16}
%Secondary_Gain a{18}
%External_Cmd_Sens  a{20}

a=[];
defaultyaxis=[];
gainscalefactor=[];
mode=[];
externalcommandsens=[];

for i=1:length(ampchannellayout)
    if isnan(ampchannellayout(i))
        eval(['set(findobj(''Tag'', ''mode', amplifiertext{i}, channeltext{i}, 'text''), ''String'', ''NA'');']);
        eval(['set(findobj(''Tag'', ''', amplifiertext{i}, channeltext{i}, 'gaintext''), ''String'', ''?'');']);
    else
        eval(['txt=fopen([''C:\Program Files\acq\amps\'', deblank(get(findobj(''Tag'', ''', ...
            amplifiertext{i}, 'serialtext''), ''String'')), ''_', channeltext{i}(end), '.txt''], ''r'');']);
        a=textscan(txt, '%s');
        a=a{:};
        fclose(txt);
        eval(['set(findobj(''Tag'', ''mode', amplifiertext{i}, channeltext{i}, 'text''), ''String'', a{6});']);

        if strcmp('V-Clamp', a{6})
            ax='Current in pA';
            mode=[mode; 0];
        elseif strcmp('I-Clamp', a{6})
            ax='Voltage in mV';
            mode=[mode; 1];
        end
        defaultyaxis=[defaultyaxis; ax];
        gainscalefactor=[gainscalefactor; 1000/(str2double(a{8})*str2double(a{12}))];
        externalcommandsens=[externalcommandsens; str2double(a{20})];
        eval(['set(findobj(''Tag'', ''', amplifiertext{i}, channeltext{i}, 'gaintext''), ''String'', a{12});']);
    end
end
if exist('scopeaxes', 'var')
    for i=1:ampchannelnum
        if isempty(scopeaxes{i})==0
            if get(findobj('Tag', 'autoscaleradio'), 'Value')==1
                set(scopeaxes{i}(1), 'YLimMode', 'auto');
                set(scopeaxes{i}(2), 'YLim', get(scopeaxes{i}(1), 'YLim'));
                set(ylabels{i}, 'string', defaultyaxis(i,:));
            else
                set(scopeaxes{i}, 'YLim', inputrange.*yaxesscalefactor.*gainscalefactor(i));
                set(ylabels{i}, 'string', defaultyaxis(i,:));
            end
        end
    end
end