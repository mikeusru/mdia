function yphys_makeRoi(i);
global state
global spc
global gh

roisize = 6;
axes(state.internal.axis(1));

ind = find(gca==state.internal.axis);
if isempty(ind)
    return;
end
pa = findobj('Tag', num2str(i));
if size(pa) > 0
	for j = 1:size(pa)
        delete(pa(j));
    end
end

xlimit1 = get(state.internal.axis(1), 'Xlim');
ylimit1 = get(state.internal.axis(1), 'Ylim');
x_r = round(roisize*xlimit1(2)/128);
y_r = round(roisize*ylimit1(2)/128);

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
offset = [x_r, y_r]; %%%%%%%%%%%%%%
yphys_roi = round([p1, offset]);
axes(state.internal.axis(1));
gh.yphys.figure.yphys_roi(i) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
gh.yphys.figure.yphys_roiText(i) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
set(gh.yphys.figure.yphys_roiText(i), 'Color', 'Red');

for imageID = 2:4
    if strcmpi(get(state.internal.GraphFigure(imageID),'visible'), 'on')
        figure(state.internal.GraphFigure(imageID));
        gh.yphys.figure.yphys_roi2(i, imageID) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
        gh.yphys.figure.yphys_roiText2(i, imageID) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
        set(gh.yphys.figure.yphys_roiText2(i, imageID), 'Color', 'Red');
    end
end
for imageID = 1:4
    if strcmpi(get(state.internal.MaxFigure(imageID),'visible'), 'on')
        figure(state.internal.MaxFigure(imageID));
        gh.yphys.figure.yphys_roi3(i, imageID) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
        gh.yphys.figure.yphys_roiText3(i, imageID) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
        set(gh.yphys.figure.yphys_roiText3(i, imageID), 'Color', 'Red');
    end
end
% axes(state.internal.maxaxis(2));
% gh.yphys.figure.yphys_roi3(i) = rectangle('Position', yphys_roi, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
% gh.yphys.figure.yphys_roiText3(i) = text(yphys_roi(1)-3, yphys_roi(2)-3, num2str(i), 'Tag', num2str(i), 'ButtonDownFcn', 'yphys_roiDelete');
% set(gh.yphys.figure.yphys_roiText3(i), 'Color', 'Red');

%figure(101);
%gh.yphys.figure.yphys_roiA(i) = rectangle('Position', yphys_roi, 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(i));
