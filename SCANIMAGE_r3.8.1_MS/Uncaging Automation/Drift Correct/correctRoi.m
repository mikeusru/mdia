function roiPosNew = correctRoi( roiPos,saveImage,I)
%roiPosNew = correctRoi( roiPos,I,saveImage ) moves a ROI to the
% appropriate place in the image perimeter
% saveImage indicates the image should be saved to the current folder
% roiPos indicates the position (x,y) of the ROI
% I (optional) is the input image
% saveImage (optional) indicates whether the composite image should be
% saved to the current folder. it is off by default.
global dia af state ua

if nargin<3
    channel=af.params.channel;
    if ua.drift.useMaxProjection
        I=updateCurrentImage(channel,2);
    else
        I=updateCurrentImage(channel,1);
    end
end

if nargin<2
    saveImage=0;
end

BW2=findPerim(I);

%coordinates of perimeter
[row,col]=find(BW2);
if isempty(row)
    roiPosNew  = roiPos;
    disp('Warning - ROI could not be updated because cell perimeter not found. Check "Threshold Cell Perimeter"');
    return
end

%distance to each perimeter point from ROI position
roiPos(1:2)=roiPos(1:2)+round(roiPos(3:4)/2); %change roi position to actual roi center


D=pdist2(roiPos(1:2),[col,row]);
ind=find(D==min(D),1);

roiPosNew=roiPos;
roiPosNew(1)=col(ind);
roiPosNew(2)=row(ind);


f=figure('Name','Corrected Roi Position','Menubar','none','NumberTitle','off');
fax=axes('Parent',f,'Position',[0 0 1 1],'units','normalized');
imagesc(I,'Parent',fax); colormap(fax,'gray');
hold on
scatter(fax,col,row,'b.');
viscircles(roiPosNew(1:2),3);
axis(fax,'square','off');

roiPosNew(1:2)=roiPosNew(1:2)-round(roiPosNew(3:4)/2); %change roi center to actual roi position

if saveImage
    fName=[state.files.savePath,'\roiCorrected.tif'];
    print(f, '-dtiff', fName);
end
end

