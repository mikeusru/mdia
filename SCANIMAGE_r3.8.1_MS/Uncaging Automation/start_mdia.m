function start_mdia
%start_mdia is the master function to start Misha's Dendrite Imaging
%Automation module
global dia af ua
evalin('base','global af ua dia;'); %VI021808A %misha - added af and ua spc and dia
loadInifileAFUA;

fpath=which('cellInfoGuiValues.mat');
if ~isempty(fpath) 
    load(fpath);
    dia.acq.cellInfo=saveInfo;
end

fpath=which('powerMod.mat');
if ~isempty(fpath)
    load(fpath);
    dia.init.powerMod=load(fpath);
end


af.params.scancount=ceil(af.params.zrange/af.params.zstep+1);

dia.hPos = mdiaPositionClass;
dia.hPos.initialize;
dia.hPos.loadTimeline(af.inipath);

mdia;



end

