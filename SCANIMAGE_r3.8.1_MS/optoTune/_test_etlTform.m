
% H=open('Hfit3.mat');
% dia.etl.acq.Htransform=H.Hfit3;
dia.etl.acq.Htransform=Hfit3;
dia.etl.acq.doMirrorTransform=1;

dia.etl.acq.Htransform(3,1,:)=0;
dia.etl.acq.Htransform(3,2,:)=0;