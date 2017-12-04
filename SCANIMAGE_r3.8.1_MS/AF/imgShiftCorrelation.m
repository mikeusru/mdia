function [correlation,shiftx,shifty]=imgShiftCorrelation(Iref,I)
% [correlation,shiftx,shifty]=imgShiftCorrelation(Iref,I) takes an input
% from two images, calculates their shift, and computes the correlation
% between the shifted images. The images have to be the same size.
%
% Iref is the reference image I is the image which is being compared
%
% correlation, which is a number between 0 and 1, signifies how good the
% shifted images match up
%
% shiftx and shifty are the pixel values of the shift. these may be useful
% in order to exclude any images which have too high a shift, therefore
% potentially resulting in too small an image being compared.

[row,col]=size(Iref);
rows=1:row;
cols=1:col;
% Positive X shift is to the left on the image, Positive Y shift is up on
% the image

[shiftx, shifty] = computeDrift( Iref, I);
if shiftx>0
    Icols=cols(1:end-shiftx);
    Refcols=cols(abs(shiftx)+1:end);
elseif shiftx<0
    Icols=cols(abs(shiftx)+1:end);
    Refcols=cols(1:end-abs(shiftx));
end
if shifty>0
    Irows=rows(1:end-shifty);
    Refrows=rows(abs(shifty)+1:end);
elseif shifty<0
    Irows=rows(abs(shifty)+1:end);
    Refrows=rows(1:end-abs(shifty));
end
newIRef=Iref(Refrows,Refcols);
newI=I(Irows,Icols);

correlation=imgCorrelation(newIRef,newI);
