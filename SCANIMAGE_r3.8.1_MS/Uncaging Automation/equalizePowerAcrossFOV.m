function results = equalizePowerAcrossFOV

global state dia
dia.init.doBeamPowerTransform =0;
%set zoom to 1

disp('setting Zoom and #Slices to 1');
setZoomValue(1);
state.acq.numberOfZSlices=1;
disp('getting image');
I = updateCurrentImage(1,2,1);
siz=size(I);
% zoomSiz=round(siz/30);
% M=mod(siz,zoomSiz);

% Icell=mat2cell(I,[zoomSiz(1),M(1)],[zoomSiz(2),M(2)]);
h=figure;
imagesc(I);
% Im=movingmean(I,5,1);
% Im=movingmean(Im,5,2);
% axis equal square image;
% % xMax=max(Im,[],1);
% % yMax=max(Im,[],2);
% xMean=mean(Im,1);
% yMean=mean(Im,2);
% h(end+1)=figure('Name','yMean');
% plot(yMean);
% h(end+1)=figure('Name','xMean');
% plot(xMean);
I=double(I);
[y, x, z] = find(I);

y=-y+max(y)+1; %inverse y values


mirrorDataOutput=state.acq.mirrorDataOutput;
slowScanRange=[min(mirrorDataOutput(:,2)),max(mirrorDataOutput(:,2))];
fastScanRange=[min(mirrorDataOutput(:,1)),max(mirrorDataOutput(:,1))];

x=x/siz(2)*diff(fastScanRange)+fastScanRange(1);
y=y/siz(1)*diff(slowScanRange)+slowScanRange(1);

[zgrid,xgrid,ygrid] = gridfit(x,y,z,30,30,'smoothness',2);
% ygrid=flipdim(ygrid,1); %y is flipped relative to scan

zMax=max(max(zgrid));
zgrid=zgrid-zMax; %z values are represented as differences from the max

[row,col]=find(zgrid==0); %find center value
px=polyfit(xgrid(1,:),zgrid(row,:),2);
py=polyfit(ygrid(:,1),zgrid(:,col),2);
zpx=polyval(px,xgrid(1,:));
zpy=polyval(py,ygrid(:,1));

zgrid_corrected=zgrid;
zgrid_corrected=zgrid_corrected-repmat(zpx,size(zgrid_corrected,1),1);
zgrid_corrected=zgrid_corrected-repmat(zpy,1,size(zgrid_corrected,2));

h(end+1)=figure;
surf(xgrid,ygrid,zgrid);
xlabel('X');
ylabel('Y');
hold on

plot3(xgrid(1,:),ygrid(row,:),zpx,'LineWidth',3);
plot3(xgrid(:,col),ygrid(:,1),zpy,'LineWidth',3);
hold off
zlim=get(gca,'zlim');

h(end+1)=figure;
surf(xgrid,ygrid,zgrid_corrected);
xlabel('X');
ylabel('Y');
set(gca,'zlim',zlim);

results.px=px;
results.py=py;

dia.init.PowerCalibZpx=px;
dia.init.PowerCalibZpy=py;

[~,dia.init.powerMod]=tunePowerToBrightness();

dia.init.doBeamPowerTransform =1;
