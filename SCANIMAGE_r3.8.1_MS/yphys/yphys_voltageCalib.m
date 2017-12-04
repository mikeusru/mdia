function yphys_voltageCalib
global gh;
global state;
global ysum;


yphys_setup(1, 0);

startV = -0.016;
stepV = 0.002
pauseT = 0.5;
Nstep = 15;

sOffset = state.yphys.acq.scanoffset;
ysum.intensity1 = []; 
ysum.intensity2 = [];
ysum.Xorg = []; ysum.Yorg = [];
ysum.Xvol = []; ysum.Yvol = [];

state.yphys.acq.phys_counter = 0;

for i=1:Nstep; 
    state.yphys.acq.scanoffset = [sOffset(1) + startV + stepV*i, sOffset(2)]; 
    yphys_uncage;
    pause(pauseT);
    %state.yphys.acq.phys_counter
end

len = state.yphys.acq.phys_counter;
x1 = ysum.intensity1(len-Nstep+1:len);
[val, p1] = max(x1);

state.yphys.acq.scanoffset = [sOffset(1) + startV + stepV*p1, sOffset(2)]; 
sOffset = state.yphys.acq.scanoffset;

for i=1:Nstep; 
    state.yphys.acq.scanoffset = [sOffset(1), sOffset(2) + startV + stepV*i]; 
    yphys_uncage; pause(pauseT);
end

len = state.yphys.acq.phys_counter;
x1 = ysum.intensity1(len-Nstep+1:len);
[val, p1] = max(x1);
state.yphys.acq.scanoffset = [sOffset(1), sOffset(2) + startV + stepV*p1];
disp(state.yphys.acq.scanoffset);

%%% After running this program, you have to change
%%% state.yphys.acq.scanoffset in program yphys_setup to the new value
%%% otherwise MATLAB won't recognize the new values when the program
%%% restarts. IF questions, ask Ryohei only
%%%  written by SJ
