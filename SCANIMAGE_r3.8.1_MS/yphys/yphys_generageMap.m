function [c, int1, int2] = yphys_generateMap;
global yphys;

signalWindow = [2, 12];

backgroundstart = 1*yphys.data.outputRate/1000;
backgroundend = (yphys.data.delay - 2)*yphys.data.outputRate/1000;
signalstart = (yphys.data.delay+yphys.data.dwell+signalWindow(1))*yphys.data.outputRate/1000;
signalend = (yphys.data.delay+yphys.data.dwell+signalWindow(2))*yphys.data.outputRate/1000;
filenum = str2num(yphys.filename([end-6:end-4]));

loopstart = filenum - (yphys.data.loopCounter-1); %%%BUG ?

coords = yphys.data.xyCoords+0.5;
for i=1:length(coords); 
    yphys_loadYphys(loopstart+i); 
    b(coords(i,1), coords(i,2))=-mean(yphys.data.data(signalstart:signalend,2))+mean(yphys.data.data(backgroundstart:backgroundend,2)); 
    intensity1(coords(i,1), coords(i, 2)) = yphys.data.intensity1;
    intensity2(coords(i,1), coords(i,2))=yphys.data.intensity2;
end

smoothFactor = 128 / sqrt(length(coords)); 
c=imresize(b, smoothFactor, 'bicubic');
int1 = imresize(intensity1, smoothFactor, 'bicubic');
int2 = imresize(intensity2, smoothFactor, 'bicubic');
figure;
imagesc(c);
colorbar;
% figure; 
% subplot(1,3,1);
% imagesc(c);
% subplot(1,3,2);
% imagesc(int1);
% subplot(1,3,3);
% imagesc(int2);
% colorbar;

        
