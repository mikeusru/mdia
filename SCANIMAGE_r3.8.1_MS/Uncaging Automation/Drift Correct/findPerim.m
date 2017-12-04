function BW2=findPerim(I)
%FINDPERIM(I) finds the perimeter of an input image
global state af

M=max(max(I)); %maximum value in image
m=min(min(I)); %minimum value in an image
thresh=(M-m)*af.params.thresh+m; %values below thresh are background
I2=I;
I2(I2<thresh)=0; 
%% Find Perimeter
% H = fspecial('gaussian',[8 8], 3);
SE=strel('disk',3,0);
Io=imopen(I2,SE);
% Ig= imfilter(I2,H);
BW=zeros(size(Io));
BW(Io>0)=1;
se=strel('disk',round(af.params.roiDist*100));
BW=imdilate(BW,se);
% BW=bwmorph(BW,'thicken',round(af.params.roiDist*100));
BW2=bwperim(BW);

end

