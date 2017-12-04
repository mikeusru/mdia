function UA_Drift_RoiDisp( posID )
%UA_Drift_RoiDisp displays the ROIs for the posnID input in the UA_DriftCorrect window axes.
global ua dia

axes(ua.drift.handles.axes1);
yphys_roi=dia.hPos.allPositionsDS.roiPosition{dia.hPos.allPositionsDS.posID==posID};
roiNum=dia.hPos.allPositionsDS.roiNum(dia.hPos.allPositionsDS.posID==posID);
% for j=1:length(ua.positions)
%     if ua.positions(j).posnID==posID
%         yphys_roi=ua.positions(j).roiPosition;
%         roiNum=ua.positions(j).roiNum;
        ua.drift.handles.yphys_roi(roiNum) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(roiNum));
        ua.drift.handles.yphys_roiText(roiNum) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(roiNum), 'Tag', num2str(roiNum));
        set(ua.drift.handles.yphys_roiText(roiNum), 'Color', 'Red');
%     end
% end

end

