function newZ = etlVoltToMotorZCalc( volts )
%etlVolttoMotorZCalc
% is used to translate etl voltage to a Z value.
%
% volts is the voltage. the output is newZ, the Z value which the voltage
% will result in.

global dia

if nargin<1
    volts=dia.etl.acq.voltageMin;
end

newZ=zeros(size(volts));

try
    for i=1:length(volts)
        switch dia.etl.acq.voltCalcMode
            case 1 %constant
                newZ(i)=volts(i)*dia.etl.acq.voltToUm;
            case 2 %poly
                if volts(i)<motorZtoEtlVoltCalc(0) %if lower than value at motorZ=0
                    newZ(i)=0;
                else
                    y=volts(i);
                    x0=0;
                    pX=dia.etl.acq.umToVoltPoly;
                    f=@(x)polyval(pX,x)-y;
                    x=fzero(f,x0);
                    newZ(i)=x;
                    if isnan(newZ(i))
                        disp('Warning: ETL Polynomial does not accomodate these voltage ranges. Using Constant.');
                        newZ(i)=volts(i)*dia.etl.acq.voltToUm;
                    end
                end
        end
    end
catch
    disp('ERROR: Cannot calculate ETL voltage given current parameters');
end

end

