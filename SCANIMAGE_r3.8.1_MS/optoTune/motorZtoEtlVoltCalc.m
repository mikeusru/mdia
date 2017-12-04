function volts = motorZtoEtlVoltCalc( newZ )
%motorZtoETL( newZ )
% is used to translate motor Z movements to ETL current.
%
% newZ is the Z value (um) which is to be translated into a voltage.

global dia
try
    switch dia.etl.acq.voltCalcMode
        case 1 %constant
            volts=newZ/dia.etl.acq.voltToUm;
        case 2 %poly
            volts=polyval(dia.etl.acq.umToVoltPoly,newZ);
            if volts<0
                volts=newZ/dia.etl.acq.voltToUm;
                disp('Using Constant for ETL Volt Calculation because polynomial gives a negative value');
            end
    end
catch
    disp('Cannot calculate ETL voltage given current parameters');
end


