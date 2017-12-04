function buildPockelsModulationMatrix(uncaging)
%buildPockelsModulationMatrix(beam) builds the matrix based on pockels
%alignment data used to modulate pockel cell power over the scanning range
% uncaging indicates whether these values are being created for an uncaging
% pulse
global dia state

try
    if ~isfield(dia.init,'powerMod')
        return
    end
catch
    return
end

if nargin<1
    uncaging=false;
end

if uncaging
    onBeams=state.yphys.init.eom.uncageP;
else
    beamList = delimitedList(state.init.eom.focusLaserList, ','); %convert to cell array
    beamOnMask = ismember(state.init.eom.pockelsCellNames, beamList);
    onBeams = find(beamOnMask);
end


for beam = onBeams(1:length(onBeams))
    if uncaging
        param = state.yphys.acq.pulse{3,state.yphys.acq.pulseN};
        targetVoltage=state.init.eom.lut(beam, param.amp);
    else
        targetVoltage=state.init.eom.lut(beam, state.init.eom.maxPower(beam));
    end
    siz=size(dia.init.powerMod.interpVoltage{beam});
    cInd=round(siz/2);
    [~,idx]=min(abs(dia.init.powerMod.interpVoltage{beam}{cInd(1),cInd(2)} - targetVoltage));
    targetFluorescence=dia.init.powerMod.interpFluorescence{beam}{cInd(1),cInd(2)}(idx);
    beamModMatrix=zeros(siz);
    
    for i=1:siz(1)
        for j=1:siz(2)
            [~,idx]=min(abs(dia.init.powerMod.interpFluorescence{beam}{i,j} - targetFluorescence));
            beamModMatrix(i,j)=dia.init.powerMod.interpVoltage{beam}{i,j}(idx);
        end
    end
    
    interpBeamModMatrix=interp2(beamModMatrix,2);
    [X,Y]=meshgrid(dia.init.powerMod.fastScanVoltage{beam},dia.init.powerMod.slowScanVoltage{beam});
    X=interp2(X,2);
    Y=interp2(Y,2);
    dia.init.powerMod.XY_interpBeamModMatrix={X,Y,interpBeamModMatrix};
    if uncaging
        mirrorDataOutput=state.yphys.acq.scanOutput;
    else
        mirrorDataOutput=state.acq.mirrorDataOutput;
    end
    %locate points and values closest to the mirror data voltages
    dt=DelaunayTri(X(:),Y(:));
    PI=nearestNeighbor(dt,mirrorDataOutput(:,1),mirrorDataOutput(:,2));
    V=interpBeamModMatrix(PI);
    if uncaging
        dia.init.powerMod.PockelsModulationUncaging=V;
    else
        dia.init.powerMod.PockelsModulationMatrix{beam}=V;
    end
    [~,ind]=min(abs(state.init.eom.lut(beam,:)-max(V)));
    disp(['Beam ', num2str(beam), ' pockel max is ' num2str(ind),'%']);
    if uncaging
        break
    end
end

end

