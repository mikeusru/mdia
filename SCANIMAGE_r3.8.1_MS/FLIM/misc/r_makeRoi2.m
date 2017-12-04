function Aout = r_makeRoi2(Roi_size)

global state;
global gh;

if ~nargin
    Roi_size = 16;
end
%axes(state.internal.maxaxis(1));


%figure(gcf);
waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
%rectangle('Position', [p1, offset]);
ROI = round([p1, offset]);

roiobj = findobj('Tag', 'ROIy');
nRoi = length(roiobj);
color_a = {'green', 'red', 'white', 'cyan', 'magenda'};
ROI(3) = Roi_size;
ROI(4) =  Roi_size/4;
%gh.yphys.figure.roiCalcium(nRoi+1) = rectangle('Position', ROI, 'EdgeColor', color_a{nRoi+1}, 'ButtonDownFcn', 'r_dragRoi', 'Tag', 'ROI', 'Curvature', [1 1]);
gh.yphys.figure.roiCalcium(nRoi+1) = rectangle('Position', ROI, 'EdgeColor', color_a{nRoi+1}, 'ButtonDownFcn', 'r_dragRoi2', 'Tag', 'ROIy');
%set(gco, 'UserData', nRoi+1);

% 
% color_a = {'green', 'red', 'white', 'cyan', 'magenda'};
% roiobj = findobj('Tag', 'ROI');
% nRoi = length(roiobj);
% for j = 1:nRoi
% %     set(roiobj(j), 'Visible', 'Off'); 
% %     set(roiobj(j), 'Visible', 'On');
%     spc_roi = get(roiobj(j), 'Position');
%     spc_roi(3) = Roi_size;
%     spc_roi(4) = Roi_size/4;
%     set(roiobj(j), 'Position', spc_roi, 'Curvature', [1 1]);
%     set(roiobj(j), 'EdgeColor', color_a{j});
%     set(roiobj(j), 'Position', spc_roi, 'Curvature', [1 1]);
%     set(roiobj(j), 'UserData', color_a{j});
% end
% %set(gh.yphys.figure.yphys_roiText(RoiN), 'Position', [spc_roi(1)-3, spc_roi(2)-3]);