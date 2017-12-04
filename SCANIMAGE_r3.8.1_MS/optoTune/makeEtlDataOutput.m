function etlDataOutput = makeEtlDataOutput(dataLength)
% etlDataOutput = makeEtlDataOutput creates the analog output data for the
% ETL

global dia state
%%ETL data output reflects the motion of the ETL for each line during data
%%collection, and should have the same wavelength as either the fast or
%%slow scanning mirror. Since the ETL is probably not meant to go super
%%fast (max seems to be 1000Hz), it should move at the same speed as the
%%slow-scanning mirror, for now.

%note: for 60x objective, measured dZ = -77 * dV

%zBase and zRange should be predetermined. the signal will start at zBase
%and go up by zRange.
if ~isfield(dia,'etl') || ~isfield(dia.etl, 'acq') || ~isfield(dia.etl.acq,'voltageMin')
dia.etl.acq.voltageMin=0;
dia.etl.acq.voltageRange=0;
dia.etl.acq.voltToUm=-77;
dia.etl.acq.fovSizeUm=240;
dia.etl.acq.voltCalcMode=1;

loadInifileAFUA;
end 

if nargin<1
    dataLength=size(state.acq.mirrorDataOutput,1);
end

zBase=dia.etl.acq.voltageMin;
zRange=dia.etl.acq.voltageRange;
 %% need to calculate percent decrease for slow scan shift mirror... need to know FOV size for this.
fovSizeum=dia.etl.acq.fovSizeUm;
 zRangeUm=abs(etlVoltToMotorZCalc(zRange+zBase)-etlVoltToMotorZCalc(zBase));
 %% z^2 + y0^2 = y^2, so y0=sqrt(y^2-z^2)
 z=zRangeUm;
 y=fovSizeum/state.acq.zoomFactor;
 if z>=y
     y0=0;
 else
     y0=sqrt(y^2-z^2);
 end
 shiftScale=y0/y;
 dia.etl.acq.mirrorSlowShiftScale=shiftScale;


% baseLine=state.acq.mirrorDataOutput(:,2);
% baseLine=dia.tempHolder(:,1);
% baseLine=baseLine-min(baseLine);
% baseLine=baseLine/max(baseLine)*zRange;
% baseLine=baseLine+zBase;
% baseLine=circshift(baseLine,-2056);
% dataLength=size(state.acq.mirrorDataOutput,1);
etlDataOutput=linspace(zBase,zBase+zRange,dataLength)';


% etlDataOutput=circshift(etlDataOutput,-round(dataLength/10));
% etlDataOutput=baseLine;



end