function r_dragRoi;

point1 = get(gca,'CurrentPoint'); % button down detected
point1 = point1(1,1:2);              % extract x and y

RoiRect = get(gco, 'Position');
rectFigure = get(gcf, 'Position');
rectAxes = get(gca, 'Position');
RoiN = str2num(get(gco, 'Tag'));

Xlimit = get(gca, 'XLim');
Ylimit = get(gca, 'Ylim');
Ylimit = Ylimit(2);
Xlimit = Xlimit(2);


xmag = (rectFigure(3)*rectAxes(3))/Xlimit;  %pixel/screenpixel
xoffset =rectAxes(1)*rectFigure(3);
ymag = (rectFigure(4)*rectAxes(4))/Ylimit;
yoffset = rectAxes(2)*rectFigure(4);

%rect1 = [xmag*RoiRect(1)+xoffset, ymag*RoiRect(2)+yoffset, xmag*RoiRect(3), ymag*RoiRect(4)];
rect1 = [xmag*RoiRect(1)+xoffset+0.5, ymag*(Ylimit-RoiRect(2)-RoiRect(4))+yoffset+0.5, xmag*RoiRect(3), ymag*RoiRect(4)];

tag1 = round(RoiRect(3)/5+0.5);
tag2 = round(RoiRect(4)/5+0.5);

% if (point1(1) > RoiRect(1)+RoiRect(3)-tag1) & (point1(2) > RoiRect(2)+RoiRect(4)-tag2)
%     fixedpoint = [rect1(1), rect1(2)+rect1(4)];
%     rect2 = rbbox(rect1, fixedpoint);
%     point2 = get(gca,'CurrentPoint');    % button up detected
%     point2 = point2(1,1:2);
%     offset = -(point1-point2);
%     spc_roi = round([RoiRect(1), RoiRect(2), RoiRect(3)+offset(1), RoiRect(4)+offset(2)]);
% else
    rect2 = dragrect(rect1);
    spc_roi = [round((rect2(1)-xoffset)/xmag), round(Ylimit-RoiRect(4)-(rect2(2)-yoffset)/ymag), RoiRect(3), RoiRect(4)];
% 
% end



if spc_roi(1)<1
    spc_roi(1) = 1;
end
if spc_roi(3)+spc_roi(1) > Xlimit-1
    spc_roi(3)=Ylimit-spc_roi(1);
end

if spc_roi(2)<1
    spc_roi(1) = 1;
end
if spc_roi(2)+spc_roi(4) > Ylimit-1
    spc_roi(4) = Xlimit-spc_roi(2);
end

color_a = {'green', 'red', 'white', 'cyan', 'magenda'};
roiobj = findobj('Tag', 'ROI');
nRoi = length(roiobj);


set(gco, 'Position', spc_roi);
