function [ind, sx, sy, ccShift] = focusUsingReference(imageArray,Iref)
% ind = focusUsingReference(imageArray,Iref) is used for autofocusing where
% a reference image is provided, so each z position is shifted and compared
% to the reference position using a cross-correlational analysis.
% imageArray is a MxNxK array, where M and N are the dimensions and K is
% the Z index of each image
% Iref is an MxN reference image
% ind is Z index with the highest correlation to the reference image
% sx and sy are the shiftx and shifty values for the ind
% ccShift is the array of cross correlation values

% cc = zeros(0,size(imageArray,1),1);
ccShift = zeros(0,size(imageArray,3),1);
shiftx =  zeros(0,size(imageArray,3),1);
shifty =  zeros(0,size(imageArray,3),1);
IrefShift = cell(0,size(imageArray,3));
Ishift = cell(0,size(imageArray,3));
[row,col]=size(Iref);
for i=1:size(imageArray,3)
    I = imageArray(:,:,i);
    [ shiftx(i), shifty(i) ] = computeDrift(Iref,I);
    rowArray = (1:row) - shifty(i);
    rowArray(rowArray<1 | rowArray>row) = [];
    colArray = (1:col) - shiftx(i);
    colArray(colArray<1 | colArray>col) = [];
    Ishift{i} = I(rowArray,:);
    Ishift{i} = Ishift{i}(:,colArray);
    rowArray = (1:row) + shifty(i);
    rowArray(rowArray<1 | rowArray>row) = [];
    colArray = (1:col) + shiftx(i);
    colArray(colArray<1 | colArray>col) = [];
    IrefShift{i} = Iref(rowArray,:);
    IrefShift{i} = IrefShift{i}(:,colArray);
    ccShift(i) = corr2(Ishift{i},IrefShift{i});  %cross correlation of shifted images
%     cc(i) = corr2(I,Iref); %cross correlation of regular images
end

[~,ind] = max(ccShift);
sx=shiftx(ind);
sy=shifty(ind);
% 
% figure
% plot(cc)
% hold on
% plot(ccShift)