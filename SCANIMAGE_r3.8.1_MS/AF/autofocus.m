function autofocus
%autofocus starts the autofocus GUI and stuff

global af

%set default values % Most of these are now taken from the Ini file
%load ini file
loadInifileAFUA;
% af.active=0;
% af.params.zrange=4;
% af.params.zstep=1;
% af.params.frequency=5;
% af.params.isAFon=0;
% af.params.useAcqForAF=0;
% af.params.channel=1;
% af.algorithm.value=2;
% af.algorithm.operator='ACMO';
% af.troubleshooting{1,1}='autofocus.m opened';
% af.statusGUI='-';
% af.params.displaytoggle=0;
% af.h=NaN;
% af.drift.on=0;
% af.roisize=30; %size of cone around click which to use for autofocus routine
% af.drift.scale=1;
% af.drift.tuneshift=3;
% af.params.thresh=0;
af.params.scancount=ceil(af.params.zrange/af.params.zstep+1);

afGUI;

end

