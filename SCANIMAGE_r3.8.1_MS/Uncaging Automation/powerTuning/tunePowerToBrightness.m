function [ds,powerMod] = tunePowerToBrightness()
%tunePowerToBrightness() checks various
%power intensities for the image brightness they produce

global state dia gh af

maxPowerTest=dia.init.powerMod.maxPower;
incrementPower=1;
beam=state.init.eom.beamMenu;
setZoomValue(1);
numberOfZSlices=state.acq.numberOfZSlices;
state.acq.numberOfZSlices=1;
h=waitbar(0,'Tuning Pockels FOV Alignment','CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');
setappdata(h,'canceling',0);
originalPower=get(gh.powerControl.maxPowerText,'String');
ds={'Image','Power_Percent','Voltage','ImageChunks';{[]},0,0,{[]}}; %preallocate dataset
ds=cell2dataset(ds);
ds=repmat(ds,maxPowerTest,1);

for i=1:incrementPower:maxPowerTest
    if getappdata(h,'canceling')
        abortAlignment;
        return
    end
    set(gh.powerControl.maxPowerText,'String',num2str(i));
    powerControl('maxPowerText_Callback',gh.powerControl.maxPowerText);
    I = updateCurrentImage(af.params.channel,2,0);
    waitbar(i/maxPowerTest,h);
    ds.Image{i,1}=I;
    ds.Power_Percent(i,1)=i;
    ds.Voltage(i,1)=state.init.eom.lut(beam, state.init.eom.maxPower(beam));
    drawnow();
end

set(gh.powerControl.maxPowerText,'String',originalPower);
powerControl('maxPowerText_Callback',gh.powerControl.maxPowerText);


imgInd=~cellfun(@isempty,ds.Image);

cellSize=size(I)/16;
for i=1:2
    cellSize2{i}=repmat(16,1,cellSize(i));
    cellSize2{i}=repmat(cellSize2(i),length(find(imgInd)),1);
end
ds.ImageChunks=ds.Image; %to make sure alignment will be correct
ds.ImageChunks(imgInd)=cellfun(@mat2cell,ds.Image(imgInd),cellSize2{1},cellSize2{2},'UniformOutput',false);
ds.MeanChunkFluorescence=ds.ImageChunks;
for i = 1 : length(ds)
    if ~isempty(ds.Image{i,1})
        ds.MeanChunkFluorescence{i,1}=cellfun(@mean,cellfun(@mean,ds.ImageChunks{i,1},'UniformOutput',false));
    end
end
MeanChunkFluorescence=permute(ds.MeanChunkFluorescence(imgInd),[2 3 1]);
MeanChunkFluorescence=cell2mat(MeanChunkFluorescence);
interpFluorescence=cell(size(MeanChunkFluorescence,1),size(MeanChunkFluorescence,2));
interpVoltage=interpFluorescence;
fastScanVoltage=linspace(min(state.acq.mirrorDataOutput(:,1)),max(state.acq.mirrorDataOutput(:,1)),cellSize(1));
slowScanVoltage=linspace(min(state.acq.mirrorDataOutput(:,2)),max(state.acq.mirrorDataOutput(:,2)),cellSize(2));

for i=1:size(MeanChunkFluorescence,1)
    for j=1:size(MeanChunkFluorescence,2)
        interpFluorescence{i,j}=interp(squeeze(MeanChunkFluorescence(i,j,:)),5);
        interpVoltage{i,j}=interp(squeeze(ds.Voltage(imgInd)),5);
    end
end
dia.init.powerMod.slowScanVoltage{beam}=slowScanVoltage;
dia.init.powerMod.fastScanVoltage{beam}=fastScanVoltage;
dia.init.powerMod.interpFluorescence{beam}=interpFluorescence;
dia.init.powerMod.interpVoltage{beam}=interpVoltage;
dia.init.powerMod.tuneDate=date;

p=mfilename('fullpath');
[pName,~,~]=fileparts(p);
S=dia.init.powerMod;
save([pName,'\powerMod.mat'],'-struct','S');

state.acq.numberOfZSlices=numberOfZSlices;
delete(h);

    function abortAlignment
        state.acq.numberOfZSlices=numberOfZSlices;
        set(gh.powerControl.maxPowerText,'String',originalPower);
        powerControl('maxPowerText_Callback',gh.powerControl.maxPowerText);
        delete(h);
    end
end

