function [ I ] = getETLprojectionImage( channel )
global af gh


nFrames=128;
zStep=0.1016;

%turn on focus if it's off
if strcmp(get(gh.mainControls.focusButton,'String'),'FOCUS')
    mainControls('focusButton_Callback',gh.mainControls.focusButton);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
af.oneFrameAcq=getSingleImgAFUA;
af.oneFrameAcq.channel=channel;
af.oneFrameAcq.nFrames=nFrames;
af.oneFrameAcq.s1=-0.0029; %current = -0.0029*x*x + 2.4937*x;
af.oneFrameAcq.s2=2.4937;
af.oneFrameAcq.zStep=zStep;


af.oneFrameAcq.getMultipleETLframes;

try
    waitfor(gh.mainControls.focusButton,'String','FOCUS');
catch ME
    disp('Warning - frame may not have been acquired correctly since mainControls focus button cannot be read');
    disp(ME.message);
end

I=af.oneFrameAcq.I2;
end
%
% figure;
% imagesc(af.oneFrameAcq.I2);
% colormap gray
