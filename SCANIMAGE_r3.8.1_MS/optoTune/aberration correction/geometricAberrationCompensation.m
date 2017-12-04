function mirrorDataOutput2 = geometricAberrationCompensation(mirrorDataOutput,H)
%mirrorDataOutput2 = geometricAberrationCompensation(mirrorDataOutput,H)
%corrects the XY scanning mirrors to compensate for ETL aberration
%

siz=1024;

X=mirrorDataOutput(:,1);
Y=mirrorDataOutput(:,2);

yRange=max(Y)-min(Y);
xRange=max(X)-min(X);

% XminRatio=min(X)/xRange;
% YminRatio=min(Y)/yRange;

XmaxRatio=max(X)/min(X);
YmaxRatio=max(Y)/min(Y);

% X=X-min(X);
% Y=Y-min(Y);

xCenterOffset=(max(X)-xRange/2);
yCenterOffset=(max(Y)-yRange/2);

X=X-xCenterOffset;
Y=Y-yCenterOffset;

Y=Y*(siz/yRange);
X=X*(siz/xRange);

XY=[X,Y];
mo2=tforminv(maketform('affine',H),XY);

X2=mo2(:,1);
Y2=mo2(:,2);
Y2=Y2/(siz/yRange);
X2=X2/(siz/xRange);

y2Range=max(Y2)-min(Y2);
x2Range=max(X2)-min(X2);

% Y2=Y2-YminRatio*y2Range;
% X2=X2-XminRatio*x2Range;

Y2=Y2+yCenterOffset;
X2=X2+xCenterOffset;

mirrorDataOutput2=[X2,Y2];
