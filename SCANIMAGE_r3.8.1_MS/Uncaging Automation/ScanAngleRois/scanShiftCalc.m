function [ scanShiftFast, scanShiftSlow, scanRotation, scanAngleMultiplierFast, scanAngleMultiplierSlow, newZoomFactor] = scanShiftCalc( pos, ZoomFactor, sizeImage )
%scanShiftCalc is used to calculate the scan shift parameters for an ROI
% pos is the input position vector [x, y, width, height] of the ROI in a
% field of view
% 
% the output values can be used to find the new ROI position
%
% ZoomFactor is an optional input and indicates the current zoom which
% the position is relative to. By default, ZoomFactor = 1
%
% sizeImage is a two-element vector giving the image size. by default it
% uses [ua.fov.fovwidth  ua.fov.fovheight]

global state ua

if nargin<3 
    sizeImage = [ua.fov.fovwidth  ua.fov.fovheight];
end
if nargin<2
    ZoomFactor = 1;
end

xc = pos(1) + pos(3)/2;
yc = pos(2) + pos(4)/2;

% convert the pixel values to angular coordinates
fsPixels=[xc yc];
scanShift = [0 0];
scanAngleMultiplier = [state.acq.scanAngleMultiplierFast state.acq.scanAngleMultiplierSlow];
scanAngularRangeReference = [state.init.scanAngularRangeReferenceFast state.init.scanAngularRangeReferenceSlow];

scanRotation = state.acq.scanRotation;


m = size(fsPixels,1);
fsAngular = zeros(m,2);

R = [cosd(scanRotation) -sind(scanRotation); sind(scanRotation) cosd(scanRotation)];

for i = 1:m
    %Rotate coordinates clockwise, i.e. moving coordinates ccw back to reference orientation
    fsNormalized = fsPixels(i,:)./sizeImage - 0.5;
    fsAngular(i,:) = scanShift + ((fsNormalized.*scanAngleMultiplier.*scanAngularRangeReference)/ZoomFactor)*R;
end

scanShiftFast = fsAngular(1);
scanShiftSlow = fsAngular(2);

zoomFactorFast = ZoomFactor * (sizeImage(1) / pos(3)) / scanAngleMultiplier(1);
zoomFactorSlow = ZoomFactor * (sizeImage(2) / pos(4)) / scanAngleMultiplier(2);

scanAngleMultiplierFast=scanAngleMultiplier(1);
scanAngleMultiplierSlow=scanAngleMultiplier(2);

newZoomFactor = ceil(10 * min(zoomFactorFast,zoomFactorSlow))/10; %this should be constant eventually, but will be calculated for now to check stuff


end

