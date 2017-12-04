function showUncagingRois( posID, uncaging )
%showUncagingRois clears the currently displayed uncaging ROIs and brings
%up the ones relevant to the input position ID
%
% uncaging is a boolean value notifying the function whether actual
% uncaging is happening. default is false. If true, ROIs are shown starting
% from #1 instead of their actual numbering
global ua gh state dia

if nargin<2
    uncaging=false;
end

%% Delete all current uncaging ROIs
for i=1:length(gh.yphys.figure.yphys_roi)
    if ishandle(gh.yphys.figure.yphys_roi(i))
        a=findobj('Tag', num2str(i));
        if size(a) > 0
            for j = 1:size(a)
                delete(a(j));
            end
        end
%         delete(a);
    end
end


gh.yphys.figure.yphys_roi=[];
gh.yphys.figure.yphys_roiText=[];
gh.yphys.figure.yphys_roi2=[];
gh.yphys.figure.yphys_roiText2=[];
gh.yphys.figure.yphys_roi3=[];
gh.yphys.figure.yphys_roiText3=[];

%% show uncaging ROIs in current position
% roiCounter=1;
% for j=1:length(ua.positions)
%     if ua.positions(j).posnID==posID
%         yphys_roi=ua.positions(j).roiPosition;
        yphys_roi = dia.hPos.allPositionsDS.roiPosition{dia.hPos.allPositionsDS.posID==posID};
        %         i=ua.positions(j).roiNum;
        if uncaging
            i=1;
        else
            i=dia.hPos.allPositionsDS.roiNum(dia.hPos.allPositionsDS.posID==posID);
        end
        axes(state.internal.axis(1));
        gh.yphys.figure.yphys_roi(i) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
        gh.yphys.figure.yphys_roiText(i) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
        set(gh.yphys.figure.yphys_roiText(i), 'Color', 'Red');
        
        axes(state.internal.axis(2));
        gh.yphys.figure.yphys_roi2(i) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
        gh.yphys.figure.yphys_roiText2(i) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
        set(gh.yphys.figure.yphys_roiText2(i), 'Color', 'Red');
        
        axes(state.internal.maxaxis(2));
        gh.yphys.figure.yphys_roi3(i) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
        gh.yphys.figure.yphys_roiText3(i) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
        set(gh.yphys.figure.yphys_roiText3(i), 'Color', 'Red');
%         roiCounter=roiCounter+1;
%     end
% end


end

