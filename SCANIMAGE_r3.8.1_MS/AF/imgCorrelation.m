function [ correlation ] = imgCorrelation( img1,img2 )
%imgCorrelation( img1,img2 ) runs a normalized 2D cross-correlation on two
%images and returns the peak correlation value between 0 and 1, 1 being a
%perfect correlation.
%
% img1 is used as the template
%
% img2 is the comparison image
%
% this order probably doesn't matter but it's always good to keep things
% consistent

a=normxcorr2(img1,img2);
correlation=max(a(:));


end

