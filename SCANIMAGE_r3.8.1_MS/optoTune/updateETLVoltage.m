 function updateETLVoltage(volts) %updates ETL value
        global dia
        dia.etl.acq.voltageMin=volts;
        set(dia.handles.etl3Dgui.baseVoltSlider,'Value',volts);
        set(dia.handles.etl3Dgui.minVoltageEdit,'String',num2str(volts));
        preview3Dimage;
        setScanProps(dia.handles.etl3Dgui.minVoltageEdit);
        try
            if dia.etl.acq.doMirrorTransform
                setupAOData;
            end
        end
                
    end