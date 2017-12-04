function [finalMirrorDataOutput] = rotateAndShiftMirrorData(finalMirrorDataOutput)
%% function [finalMirrorDataOutput] = rotateAndShiftMirrorData(finalMirrorDataOutput)
% This function takes a N x 2 array, typically the X and Y mirror data outputs where N depends on the D-to-A rate,
% and applies row wise rotation functions to it.  Additionally, it applies the scanOffset and scanShift parameters (following the rotation).
%
%% CHANGES
%   VI022308A Vijay Iyer 2/23/08 - No longer declare lengthofframedata as a global -- not seemingly used anywhere else
%   VI091208A: Add scanOffsetX/Y in addition to the scaleX/YShift
%
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% November 29, 2000
%% ********************************************

global state % lengthofframedata (VI022308A)

rotatedImage = finalMirrorDataOutput;

lengthofframedata = size(finalMirrorDataOutput);
lengthofframedata = lengthofframedata(1,1);

c = cos(state.acq.scanRotation*pi/180);
s = sin(state.acq.scanRotation*pi/180);

a = 1:lengthofframedata;
finalMirrorDataOutput(a,1)=finalMirrorDataOutput(a,1);
finalMirrorDataOutput(a,2)=finalMirrorDataOutput(a,2);
rotatedImage(a,1) = c*finalMirrorDataOutput(a,1) + s*finalMirrorDataOutput(a,2)+ (state.acq.scanShiftFast * state.init.voltsPerOpticalDegree); %VI091208A
rotatedImage(a,2) = c*finalMirrorDataOutput(a,2) - s*finalMirrorDataOutput(a,1)+ (state.acq.scanShiftSlow * state.init.voltsPerOpticalDegree); %VI091208A

if ~state.acq.fastScanningX
    rotatedImage = fliplr(rotatedImage); %Input order is [fast slow], output order is [x y]
end

rotatedImage(:,1) = rotatedImage(:,1) + state.init.scanOffsetAngleX * state.init.voltsPerOpticalDegree;
rotatedImage(:,2) = rotatedImage(:,2) + state.init.scanOffsetAngleY * state.init.voltsPerOpticalDegree;

finalMirrorDataOutput = rotatedImage;
