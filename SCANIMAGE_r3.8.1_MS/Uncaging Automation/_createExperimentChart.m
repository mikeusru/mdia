%%replaced in hPos

function createExperimentChart
%createExperimentChart Draws a timeline of the upcoming experiment
global ua dia
uncagingTime=1;

hT=figure('Name','Experiment Timeline','MenuBar','none','numberTitle','off');
hAx=axes('Parent',hT);

a0=dia.acq.initialImagingTime;
a=ua.params.preUncageTime;
b=ua.params.primaryTime;
ae=dia.acq.preUncageExclusiveTime;
be=dia.acq.postUncageExclusiveTime;
posns=cell2mat({ua.positions.posnID});
posCount=length(posns);
if dia.init.staggerOn
    tTotal=a0+(a+uncagingTime+ae+be)*posCount+b;
    exclStart=cell(1,posCount);
    exclEnd=cell(1,posCount);
    uncageStart=cell(1,posCount);
    uncageEnd=cell(1,posCount);
    for i=1:posCount
        if i==1
            exclStart{i}=a+a0;
        else
            exclStart{i}=exclEnd{i-1}(2)+a;
        end
            exclEnd{i}=exclStart{i}+ae;
            uncageStart{i}=exclEnd{i};
            uncageEnd{i}=uncageStart{i}+uncagingTime;
            exclStart{i}=[exclStart{i},uncageEnd{i}];
            exclEnd{i}=[exclEnd{i},exclStart{i}(2)+be];
    end
    [patchHndls] = timeline({ua.positions.posnID},exclStart,exclEnd,'facecolor','b','Parent',hAx);
    hold(hAx);
else
    tTotal=a0+a+uncagingTime*posCount+b;
    for i=1:posCount
        if i==1
            uncageStart{i}=a+a0;
        else
            uncageStart{i}=uncageEnd{i-1};
        end
        uncageEnd{i}=uncageStart{i}+uncagingTime;       
    end
end


[patchHndls] = timeline({ua.positions.posnID},uncageStart,uncageEnd,'facecolor','r','Parent',hAx);
xlim(hAx,[0 tTotal]);
legend_handle=legend(hAx,'Exclusive Imaging','Uncaging');
legend_markers = findobj(get(legend_handle, 'Children'), ...
    'Type', 'Patch');

set(legend_markers(1), 'FaceColor', 'r');
set(legend_markers(2), 'FaceColor', 'b');
xlabel(hAx,'Time (min)');
ylabel(hAx,'Position');
end

