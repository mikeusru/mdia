function [ output_args ] = showSelectFigure( input_args )
%showSelectFigure creates a figure showing the relative locations of the
%imaging positions which have spines assigned to them. it then lets the
%user select a field of view which encompasses them.
global ua state dia

hPos = dia.hPos;
fovwidth=ua.fov.fovwidth;
fovheight=ua.fov.fovheight;
% fovwidth=245; %a crude measurement suggests the entire 60x FOV is around 230um wide.
% fovheight=285; % scan shift doesn't seem to be even for x and y
imzoom=ua.params.initialZoom; %the zoom scale at which images will be taken
% identify unique positions
posns = hPos.allPositionsDS.posID;
posnXYZ = hPos.getPosCoordinates;
nposns=length(posns); %identify number of unique positions

% collect all position coordinates into an array and make an image showing
% where they are next to each other

ha=ua.fov.handles.axes1;
% clear axes
cla(ha,'reset');

lowXlim=mean(posnXYZ(:,1));
lowYlim=mean(posnXYZ(:,2));
lowZlim=mean(posnXYZ(:,3));
graph_offset=[lowXlim lowYlim lowZlim];
posnXYZ_graph=bsxfun(@minus,posnXYZ,graph_offset);

%create color spectrum based on z range
map=jet;
cLow=min(posnXYZ_graph(:,3))-1;
cHigh=max(posnXYZ_graph(:,3))+1;
cRange=size(map,1)/diff([cLow cHigh]);

% show motor position rectangles
for i=1:nposns
    color=map(round((posnXYZ_graph(i,3)-cLow)*cRange),:);
    text(posnXYZ_graph(i,1)-fovwidth/imzoom/2-4,posnXYZ_graph(i,2)-fovheight/imzoom/2-8,num2str(posns(i)));
	rectangle('Position',[posnXYZ_graph(i,1)-fovwidth/imzoom/2,posnXYZ_graph(i,2)-fovheight/imzoom/2,fovwidth/imzoom,fovheight/imzoom],'FaceColor',color,'EdgeColor',color);
end

% create figure with rectangle to select the groups
oldxlim=xlim(ha);
oldylim=ylim(ha);

axis(ha,'equal','square','manual');

if diff(oldxlim)<fovwidth
    xlim(ha,[mean(oldxlim)-fovwidth, mean(oldxlim)+fovwidth]);
end
if diff(oldylim)<fovheight
    ylim(ha,[mean(oldylim)-fovheight, mean(oldylim)+fovheight]);
end

set(ha,'Xdir','reverse');
box(ha,'on');
title(ha,'Group Imaging Positions');
hc=colorbar;
xlabel(ha,'Relative X position (\mum)','FontWeight','bold');
y=ylabel(ha,'Relative Y position (\mum)','FontWeight','bold');
set(y, 'position', get(y,'position')-[10,0,0]);  % shift the y label to the right

caxis([cLow, cHigh]);
% y=ylabel(ha,'Relative Y position (\mum)','FontWeight','bold');
set(hc,'YTick',[cLow mean([cLow cHigh]) cHigh]);
z=ylabel(hc,'Relative Z position (\mum)','FontWeight','bold');
% set(z, 'position', get(z,'position')-[10,0,0]);  % shift the y label to the right


% ua.fov.originalMotorPositionsXYZ=posnXYZ; %remove when hPos is ready
% ua.fov.uniqueMotorPosns=posns; %remove when hPos is ready
% ua.fov.imzoom=imzoom; 
% ua.fov.posXYZ_graph_offset=graph_offset; %remove when hPos is ready

% display already saved position FOVs
for i=1:size(hPos.fovDS,1)
    hr=rectangle('Position',hPos.fovDS.graphPosition(i,:) - [lowXlim lowYlim 0 0],'EdgeColor','k');
    if isfield(ua.fov.handles,'fovFixed')
        ua.fov.handles.fovFixed(end+1)=hr;
    else
        ua.fov.handles.fovFixed(1)=hr;
    end
end

hPos.posXYZ_graph_offset = graph_offset;
dia.hPos = hPos;

% if isfield(ua.fov,'positions') %remove when hPos is ready
%     for i=1:size(ua.fov.positions,1)
%         if 0~=ua.fov.positions(i,4)
%             hr=rectangle('Position',ua.fov.positions(i,:)-[lowXlim lowYlim 0 0],'EdgeColor','k');
%             if isfield(ua.fov.handles,'fovFixed')
%                 ua.fov.handles.fovFixed(end+1)=hr;
%             else
%                 ua.fov.handles.fovFixed(1)=hr;
%             end
%         end
%     end
% end
end

