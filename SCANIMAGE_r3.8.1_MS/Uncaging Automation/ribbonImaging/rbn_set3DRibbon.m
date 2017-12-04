function  rbn_set3DRibbon(ax,ribbonPoly,Zlist)
%rbn_set3DRibbon Summary of this function goes here
%   Detailed explanation goes here
global af dia state ua


% [x, y]=getline(ax);
% [xpt, ypt] = getPointsFromAxes(ax, 'Cursor', 'crosshair', 'nomovegui', 1); %VI071310A
if nargin<3
    acqnum=state.files.fileCounter;
    I = updateCurrentImage( af.params.channel, 2 ,1 );
    Zlist=af.position.af_list_abs_z;
    h=figure('Name','Draw Ribbon','menubar','none','toolbar','none');
    a=get(h,'position');
    set(h,'position',[a(1),a(2),a(4),a(4)]); %make height and width equal
    ax=axes('Parent',h,'position',[0 0 1 1]);
    imagesc(I,'Parent',ax);
    axis(ax,'image','off','tight');
    
    xsiz = get(ax,'XLim');
    ysiz = get(ax,'YLim');
    sizeImage = [ysiz(2) xsiz(2)];
    [~,xpt,ypt] = roipoly;
    close(h);
    dia.acq.ribbon.Zlist=Zlist;
    dia.acq.ribbon.RelativeRibbonPoly=[xpt/diff(xsiz),ypt/diff(ysiz)];
    
    I3=af.images;
    I3=I3(1:state.acq.numberOfZSlices);
    imsiz=size(I3{1});
    I3=cell2mat(I3);
    I3=reshape(I3,imsiz(1),imsiz(2),[]);
%     dia.acq.ribbon.I3=I3;
    [I3MaxZ,pixelFocusIndZ]=max(I3,[],3);   
    BW=poly2mask(xpt,ypt,imsiz(1),imsiz(2));
    I3MaxZ(~BW)=min(min(I3MaxZ)); %remove values outside of ribbon
    [I3MaxZX,pixelFocusIndZX]=max(I3MaxZ,[],2);
    zInd=sub2ind(imsiz,1:imsiz(1),pixelFocusIndZX');
    focusSliceValues=pixelFocusIndZ(zInd);
    %remove values with lower intensity and fill them in with interpolated data
    keepIndices=I3MaxZX > (min(I3MaxZX) + (max(I3MaxZX) - min(I3MaxZX)) * 0.1); %interpolate anything below theshold value
    focusSliceValues=interp1(find(keepIndices),focusSliceValues(keepIndices),1:length(focusSliceValues),'linear');
    %fill in start and end values
    focusSliceValues(1:find(~isnan(focusSliceValues),1,'first'))=focusSliceValues(find(~isnan(focusSliceValues),1,'first'));
    focusSliceValues(find(~isnan(focusSliceValues),1,'last'):end)=focusSliceValues(find(~isnan(focusSliceValues),1,'last'));
    focusSliceValues=round(focusSliceValues);
    focusSliceValues=movingmean(focusSliceValues,7,2);
    pixelFocusInd=repmat(focusSliceValues',[1,imsiz(2)]);
    dia.acq.ribbon.pixelFocusInd=pixelFocusInd;

else
    xsiz = get(ax,'XLim');
    ysiz = get(ax,'YLim');
    xpt=ribbonPoly(:,1)*diff(xsiz);
    ypt=ribbonPoly(:,2)*diff(ysiz);
    sizeImage = [ysiz(2) xsiz(2)];
    pixelFocusInd=dia.acq.ribbon.pixelFocusInd;
    imsiz=[floor(ysiz(2)),floor(xsiz(2))];
    pixelFocusInd=imresize(pixelFocusInd,[imsiz(1),imsiz(2)]);
end

xpt=round(xpt);
ypt=round(ypt);
af.position.af_list_abs_z = [];
rbn_setRibbonXY(xpt,ypt,sizeImage);

mirrorData=dia.acq.ribbon.mirrorDataOutput(dia.acq.ribbon.inSmall,:);
pixelData(:,1) = sizeImage(2)*(mirrorData(:,1)/state.init.voltsPerOpticalDegree-state.acq.scanShiftFast)/((state.init.scanAngularRangeReferenceFast * state.acq.scanAngleMultiplierFast)/state.acq.zoomFactor) + sizeImage(2)/2; 
pixelData(:,2) = sizeImage(1)*(mirrorData(:,2)/state.init.voltsPerOpticalDegree-state.acq.scanShiftSlow)/((state.init.scanAngularRangeReferenceSlow * state.acq.scanAngleMultiplierSlow)/state.acq.zoomFactor) + sizeImage(1)/2;
pixelData=round(pixelData);
[~,ia,ic]=unique(pixelData,'rows','first');
ind=sub2ind(imsiz,pixelData(ia,2),pixelData(ia,1));
pixelFocusData=pixelFocusInd(ind);
pixelFocusDataFull=pixelFocusData(ic);
% newPixelFocusData is the relative slice index for each value. 
pixelFocusDataSmooth=round(movingmean(pixelFocusDataFull,5)); %not sure if this is necessary but I guess it gets rid of some of the noise
currentPosition=motorGetPosition;
% motorOrETLMove([currentPosition(1),currentPosition(2),Zlist(end)+5]);
EtlZlistUm=abs(Zlist-currentPosition(3));
EtlZlist=motorZtoEtlVoltCalc(EtlZlistUm);
for i=1:length(Zlist)
    pixelFocusDataSmooth(pixelFocusDataSmooth==i)=EtlZlist(i);
end

% etlCurrentMap=zeros(size(dia.acq.ribbon.inSmall));
% etlCurrentMap(dia.acq.ribbon.inSmall)=pixelFocusDataSmooth;

% create current map for the ETL and interpolate between values
xi=find(dia.acq.ribbon.inSmall);
etlCurrentMap=interp1(xi,pixelFocusDataSmooth,1:length(dia.acq.ribbon.inSmall),'linear');
etlCurrentMap([1 : find(~isnan(etlCurrentMap),1,'first'),find(~isnan(etlCurrentMap),1,'last'):end])=etlCurrentMap(find(~isnan(etlCurrentMap),1,'first')); %fill in NaN values

%shift signal to account for response delay
etlResponseDelay=15; %delay, in ms, of ETL response
if etlResponseDelay > state.yphys.acq.delay
    disp('Note: if you plan on uncaging with page controls,');
    disp(['it is reccommended you set your uncaging delay to >= ', num2str(etlResponseDelay),'ms']);
end
dia.acq.ribbon.etlMirrorToCurrentMap = etlCurrentMap;

etlCurrentMap=circshift(etlCurrentMap,-etlResponseDelay*state.acq.outputRate*1e-3);

if dia.acq.ribbon.sineWave
    ts = linspace(0, 1/state.init.hAO.sampClkRate * length(etlCurrentMap), length(etlCurrentMap));
    As = range(etlCurrentMap);
    b = range(etlCurrentMap)/2 + min(etlCurrentMap);
    fs = dia.acq.ribbon.sineWaveHz;
    ys = As*sin(2*pi*fs*ts);
    etlCurrentMap = ys + b;
end


dia.acq.ribbon.etlCurrentMap=etlCurrentMap;
% dia.acq.ribbon.I3=I3;
% dia.acq.test.pixelData=pixelData;
% dia.acq.test.pixelFocusDataSmooth=pixelFocusDataSmooth;
% display 3D ribbon image preview
if nargin<3
    xyz=unique([pixelData(:,1),pixelData(:,2),pixelFocusDataSmooth],'rows','stable');
    xyz(:,3)=etlVoltToMotorZCalc(xyz(:,3));
    xum=(xyz(:,1)/floor(xsiz(2))-.5)*ua.fov.fovwidth/state.acq.zoomFactor;
    yum=(xyz(:,2)/floor(ysiz(2))-.5)*ua.fov.fovheight/state.acq.zoomFactor;
    disp3D={I3,xum,yum,xyz(:,3),EtlZlistUm,state.acq.zoomFactor};
    dia.acq.ribbon.disp3D=disp3D;
    save([state.files.baseName,'_',num2str(acqnum),'disp3D.mat'],'disp3D');
    rbn_show3DribbonImage(I3,xum,yum,xyz(:,3),EtlZlistUm);
end
    function rbn_show3DribbonImage(I3,x,y,z,zListUm)
       figure;
       h=vol3d('CData',I3,'Xdata',[-ua.fov.fovwidth/2/state.acq.zoomFactor,ua.fov.fovwidth/2/state.acq.zoomFactor],...
           'YData', [-ua.fov.fovheight/2/state.acq.zoomFactor,ua.fov.fovheight/2/state.acq.zoomFactor], 'ZData',[min(zListUm),max(zListUm)]);
       axis(h.parent,'equal','tight');
       hold(h.parent,'on');
       set(h.parent,'Ydir','reverse');
       xlabel(h.parent,'X');
       ylabel(h.parent,'Y');
       zlabel(h.parent,'Z');
       plot3(x,y,z,'r');
    end

return
%%%
figure;
plot(mirrorData(:,1),mirrorData(:,2));
plot(pixelData(:,1),pixelData(:,2),'ro');
scatter(mirrorData(:,1),mirrorData(:,2),5,pixelFocusDataFull);
scatter(mirrorData(:,1),mirrorData(:,2),5,pixelFocusDataSmooth);
plot3(mirrorData(:,1),mirrorData(:,2),pixelFocusDataSmooth);

axis equal
end

