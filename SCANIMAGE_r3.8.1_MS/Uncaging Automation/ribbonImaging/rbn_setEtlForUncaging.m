function rbn_setEtlForUncaging
%rbn_setEtlForUncaging sets the ETL to the appropriate voltage for uncaging
%if 3D ribbon imaging is on

global state dia

if dia.acq.do3DRibbonTransform
    roiN=1;
    XY = [0, 0];
    [XY, err] = yphys_scanVoltage(roiN, 1);
    if roiN == 1 && err == 1
        disp('no ROI#1 available for ETL voltage');
    else
        mirrorDataOutput=state.acq.mirrorDataOutput;
        [~,ind]=min(abs(mirrorDataOutput(:,2)-XY(2)));
        etlVoltage=dia.acq.ribbon.etlMirrorToCurrentMap(ind);
        updateETLVoltage(etlVoltage);
%         disp(['ETL Volage Set To ',num2str(etlVoltage)]);
    end
    
end

end

