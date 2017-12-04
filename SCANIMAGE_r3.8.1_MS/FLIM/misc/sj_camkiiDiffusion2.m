function sj_camkiiDiffusion2;
global state;
global gh;

repeatPeriod = 15;
sj_camkiiDiffusion(0);

executeGrabOneCallback(gh.mainControls.grabOneButton);
tic;
for i=1:2
    toc
    pause(repeatPeriod - toc);
    tic;
    executeGrabOneCallback(gh.mainControls.grabOneButton);
end

pause(2);
sj_camkiiDiffusion(1);
toc
pause(repeatPeriod - toc);
sj_camkiiDiffusion(3);

sj_camkiiDiffusion(0);

tic
pause(repeatPeriod - toc);
for i=1:2
    executeGrabOneCallback(gh.mainControls.grabOneButton);
    toc
    pause(repeatPeriod - toc);
    tic;
end
