%Physiology scope software
%Emiliano Rial Verde
%January 2006
%Updated for better performance in Matlab 2006a. November 2006
%
%Script to update the status indicator text in the Scope and Recording windows

switch status
    %Scope window
    case 1
        set(findobj('tag', 'statustext'), 'String', 'Missed!');
    case 2
        set(findobj('tag', 'statustext'), 'String', 'Overload!');
        if exist('status_timer', 'var')
            delete(status_timer);
            clear status_timer
        end
        status_timer=timer('StartDelay',0.1,'TimerFcn','set(findobj(''tag'', ''statustext''), ''String'', ''Acquiring...'');');
        start(status_timer);
    case 3
        set(findobj('tag', 'statustext'), 'String', 'Acquiring...');
    case 4
        if exist('status_timer', 'var')
            delete(status_timer);
            clear status_timer
        end
        status_timer=timer('StartDelay',0.11,'TimerFcn','set(findobj(''tag'', ''statustext''), ''String'', ''Ready'');');
        start(status_timer);
     
    %Recording window
    case 5
        set(findobj('tag', 'recstatustext'), 'String', 'Missed!');
    case 6
        set(findobj('tag', 'recstatustext'), 'String', 'Overload!');
        if exist('status_timer', 'var')
            delete(status_timer);
            clear status_timer
        end
        status_timer=timer('StartDelay',0.1,'TimerFcn','set(findobj(''tag'', ''recstatustext''), ''String'', ''Recording...'');');
        start(status_timer);
    case 7
        set(findobj('tag', 'recstatustext'), 'String', 'Recording...');
    case 8
        if exist('status_timer', 'var')
            delete(status_timer);
            clear status_timer
        end
        status_timer=timer('StartDelay',0.11,'TimerFcn',...
            'set(findobj(''tag'', ''recstatustext''), ''String'', ''Ready''); set(findobj(''tag'', ''acqnumbertext''), ''String'', ''0'');');
        start(status_timer);
end