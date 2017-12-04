function [  ] = updateUAgui( field,inText )
%updateUAgui updates the values in the UA gui
% field signifies which variables to update. no input means update
% the default stuff
% inText is an optional field to show certain text in some parameters
global ua dia af

if nargin<1
    field='default';
end

if strcmp(field,'default')
    
%     sortUApositionsByZ;
    
    %% update UA GUI table
    dia.hPos.makeTableForGUIs(dia.handles.mdia.SpineSelectUitable,1);
%     cNames={'Position','Spine','Z Depth','Ref Img','RefImg2','FOV'};
%     cWidth={48 45 60 51 51 45};
%     cDataType={'char', 'char', 'char', 'logical', 'logical', 'char'};
       
%     if ua.params.fovModeOn
%         fieldCount=6;
%     else
%         fieldCount=5;
%     end
%     cNames2=cNames(1:fieldCount);
%     cWidth2=cWidth(1:fieldCount);
%     cDataType2=cDataType(1:fieldCount);
    
%     if isfield(ua,'positions') && isfield(ua.positions,'roiNum')
%         table_disp=cell(1,fieldCount); %preallocate table length
%         for i=1:length(ua.positions)
%             posID=ua.positions(i).posnID;
%             if i>1
%                 if ismember(ua.positions(i).posnID,cell2mat(table_disp(:,1))) %add rois to appropriate positions
%                     ind=find(cell2mat(table_disp(:,1))==posID);
%                     table_disp{ind,2}=[table_disp{ind,2} ', ' num2str(ua.positions(i).roiNum)];
%                 else
%                     ind=size(table_disp,1)+1;
%                     table_disp{ind,2}=num2str(ua.positions(i).roiNum);
%                 end
%             else
%                 ind=1;
%                 table_disp{ind,2}=num2str(ua.positions(i).roiNum);
                
%             end
%             table_disp{ind,1}=ua.positions(i).posnID;
%             table_disp{ind,4}=ua.positions(i).hasRef;
%             table_disp{ind,5}=ua.positions(i).hasRefZoomOut;
%             table_disp{ind,3}=[num2str(round(ua.positions(i).zRoofOffset*100)/100), ' µm'];
%             if ua.params.fovModeOn
%                 if isfield(ua.positions(i),'FOVnum') && ~isempty(ua.positions(i).FOVnum)
%                     table_disp{ind,6}=ua.positions(i).FOVnum;
%                 else
%                     table_disp{ind,6}='NaN';
%                     ua.positions(i).FOVnum='NaN';
%                 end
%             end
%         end
        
%     else table_disp=[];
%     end
    
    
    
%     try
%         set(dia.handles.mdia.SpineSelectUitable,'ColumnName',cNames);
%         set(dia.handles.mdia.SpineSelectUitable,'data',uidata);
%         set(dia.handles.mdia.SpineSelectUitable,'ColumnWidth',cWidth);
%         set(dia.handles.mdia.SpineSelectUitable,'ColumnFormat',cDataType);
%     end
    
    %% update UA param values
    if isfield(ua,'params')
        try
            set(dia.handles.mdia.postUncageTimeEdit,'String',num2str(ua.params.primaryTime));
            set(dia.handles.mdia.postUncageFrequencyEdit,'String',num2str(ua.params.primaryFreq));
            set(dia.handles.mdia.preUncageTimeEdit,'String',num2str(ua.params.preUncageTime));
            set(dia.handles.mdia.preUncageFreqEdit,'String',num2str(ua.params.preUncageFreq));
            %         set(ua.handles.edit4,'String',num2str(ua.params.secondaryTime));
            %         set(ua.handles.edit5,'String',num2str(ua.params.secondaryFreq));
        catch 
        end
    end
    
    %% Update DriftCorrect table and GUI table

    if isfield(ua,'drift') && isfield (ua.drift,'handles')...
            && ishandle(ua.drift.handles.figure1)
                dia.hPos.makeTableForGUIs(ua.drift.handles.uitable1,2);

%         table_disp2=table_disp(:,[1,3,4]);
%         
%         try
%             set(ua.drift.handles.uitable1,'data',table_disp2); %set values to table;
%             set(ua.drift.handles.uitable1,'ColumnName',cNames2(:,[1,3,4]));
%             set(ua.drift.handles.uitable1,'ColumnWidth',cWidth2(:,[1,3,4]));
%             set(ua.drift.handles.uitable1,'ColumnFormat',cDataType2(:,[1,3,4]));
%         end
    end
    
    if isfield(ua.params,'zRoof') % set z roof for dwell
        set(dia.handles.mdia.zRoofEdit,'String',num2str(ua.params.zRoof));
    end
    
    %FOV mode settings
    if ua.params.fovModeOn
%         set(dia.handles.mdia.posText,'String','Current FOV :');
        set(dia.handles.mdia.updateXyzPushbutton,'String','Update Position');
        set(dia.handles.mdia.driftCorrectModePanel,'SelectedObject',dia.handles.mdia.scanDriftMode);
        set(dia.handles.mdia.goToPushbutton,'String','ScanShift GoTo');
        set(dia.handles.mdia.groupByFovPushbutton,'Enable','on');
    else
%         set(dia.handles.mdia.posText,'String','Current Position :');
        set(dia.handles.mdia.updateXyzPushbutton,'String','Update Motor Position');
        set(dia.handles.mdia.goToPushbutton,'String','Motor GoTo');
        set(dia.handles.mdia.groupByFovPushbutton,'Enable','off');
    end
    
    %Single Position selection 
%     set(dia.handles.mdia.singlePosAfUaCheckbox,'Value',dia.init.useOnePos);
%     if dia.init.useOnePos
%         set(dia.handles.mdia.afDriftPosEdit,'String',num2str(dia.acq.refPosition));
%     end
    
    %Pause Button
    if dia.acq.pauseOn
        set(dia.handles.mdia.pausePushButton,'String','Unpause','ForegroundColor','r');
    else
        set(dia.handles.mdia.pausePushButton,'String','Pause','ForegroundColor','k');
    end
    
    %ETL
    if ~dia.init.etl.etlOn
        dia.etl.acq.etlOn=0;
        dia.etl.acq.stackOnlyMode=0;
        set(findobj('Parent',dia.handles.mdia.etlUipanel),'Enable','off');
    end
    set(dia.handles.mdia.etlZLimitEdit,'String',num2str(dia.etl.acq.absZlimit));
    set(dia.handles.mdia.etlRangeEdit,'String',num2str(dia.etl.acq.autoRange));
    set(dia.handles.mdia.stacksOnlyETLCheckbox,'Value',dia.etl.acq.stackOnlyMode);
    set(dia.handles.mdia.useEtlCheckbox,'Value',dia.etl.acq.etlOn);
        
end

%%
if strcmp(field,'default') || strcmp(field,'afmode')
    %Focus and Drift Correct Settings
    switch af.params.mode
        case 'singleMode'
            set(dia.handles.mdia.setRefPushbutton,'Enable','on');
        case 'multiMode'
            set(dia.handles.mdia.setRefPushbutton,'Enable','off');
    end
end
%%
if strcmp(field,'currentPosText')
    set(dia.handles.mdia.currentPosText,'String',inText)
end

% if strcmp(field,'currentStepText')
%     set(dia.handles.mdia.currentStepText,'String',inText);
% end

end


