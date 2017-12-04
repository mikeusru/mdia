function [ x1, y1 ] = Locate_spines_func( I,x,y )
%% Locate Dendritic Spine of Choice
%   The input is a single image (example: 128x128 uint16), x and y
%   coordinates of location near spine, The script finds the closest
%   dendritic spine center to the given coordinates which are either based
%   on a click or previously nearby dendrite center. 
%   The function outputs the coordinates of the new position for the
%   nearest dendrite

%   I is an image
%   x and y are coordinates on that image
%   x1 and y1 are the output coordinates of the nearest dendritic spine

%   Ultimate purpose: to be used in real time to track spines during
%   imaging.

global af

%% Input Image (now, image is opened before function is called)
%I=imread(tiffname); %Open image

%% Show Image
%figure('Name','Original Image');
%imagesc(I); %Display image scaled to use full intensity colormap=
%colormap(gray); % change colormap of shown image to gray so there's no confusion

%% Establish spine of interest
%[x,y]=ginput(1); %take input from one click to establish point of important dendrite
%x=round(x); %round coordinates to whole numbers
%y=round(y); 

%% Threshold Image
M=max(max(I)); %maximum value in image
m=min(min(I)); %minimum value in an image
thresh=(M-m)*af.params.thresh+m; %values below thresh are background
I2=I;
I2(I2<thresh)=0; %I2 is I with the below-threshold noise removed
%figure('Name','Threshold Image');
%imagesc(I2);
%colormap(gray);

%% Get binary Threshold Image
% level=graythresh(I); %establish image threshold for making it binary
% BW=im2bw(I,level); %make binary image
% L=bwlabel(BW,8);
%STATS=regionprops(L,'all');
%figure('Name','Binary Image');
%imagesc(L);

%% Display regional maximums of images (identify intensity peaks)
%figure('Name','Peaks');
%regmax=imregionalmax(I); %get regional intensity of image
%imagesc(regmax); %display regional intensity image
%colormap(gray);
%figure('Name','Peaks from Threshold Image');
regmax2=imregionalmax(I2); %get regional intensity of image above threshold
%figure(15);
%imagesc(regmax2);
%colormap(gray);
%% Tile the figures
%tilefigs;
%% Find nearest spine to previous position
% regmax2(L==0)=0; %remove points where binary threshold image is blank
[j,i]=ind2sub(size(regmax2),find(regmax2==1)); %coordinates of peaks of threshold image. (i,j) correspond to x and y even though they are reversed here
min_dist = Inf;
n=numel(i);
for p = 1:n %loop to measure distance between clicked point and all peak coordinates
    d = (x-i(p))^2+(y-j(p))^2;
    if d < min_dist
        min_p = p;
        min_dist = d;
    end
end
x1=i(min_p);
y1=j(min_p);
%figure('Name','Closest Points')
%plot(i,j,'b.',x,y,'ro',[x,i(min_p)],[y,j(min_p)],'r') %plot all points and draw line between clicked area and spine center
%px=numel(I(1,:)); %get resolution of initial image
%axis([0 px 0 px]);
%axis ij;

end

