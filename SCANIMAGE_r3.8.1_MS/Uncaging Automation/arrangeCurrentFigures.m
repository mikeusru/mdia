function arrangeCurrentFigures
%arrangeCurrentFigures arranges visible figures and GUIs
%   if windowPositions.mat exists, figures are arraged according to the
%   saved information. Otherwise, they are arranged automatically

global dia

try
    if dia.guiStuff.arrangeFigs
        
        [fPath,~,~]=fileparts(mfilename('fullpath'));
        
        if exist([fPath,'\inifile\windowPositions.mat'],'file')
            hInfo=load([fPath,'\inifile\windowPositions.mat'],'windowNames','allPositions','windowUnits');
            setWindowPositions( hInfo )
            
        else
            
            windowOrder={'MAIN CONTROLS','MOTOR CONTROLS','IMAGE CONTROLS',...
                'POWER CONTROL','Acquisition of Channel 1',...
                'Acquisition of Channel 2','Dendrite Imaging Automation',...
                'Max Projection of Channel 1','Max Projection of Channel 2',...
                'yphys_stimScope'};
            
            handles=findall(0,'Type','Figure','Visible','On');
            windowOrder=fliplr(windowOrder);
            windowNames=get(handles,'Name');
            for i=1:length(windowOrder)
                cellInd=strfind(windowNames,windowOrder{i});
                ind=find(~cellfun(@isempty,cellInd));
                if ~isempty(ind)
                    windowNames(ind)=[];
                    windowNames=[windowOrder{i};windowNames];
                    tagHandle=handles(ind);
                    handles(ind)=[];
                    handles=[tagHandle;handles];
                end
            end
            arrangeFigures(handles);
        end
    end
catch ME
    disp(ME.message);
end



end

