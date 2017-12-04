function motorToETLmove( motorZ, z0)
% motorToETLmove sends a signal for the ETL to move to a new location based
% on certain motor coordinates. motorZ is the target motor Z coordinate and
% z0 is the z value for when the current is 0.
global dia
etlFun60x=[0.0029 -2.4937]; %measured function values for 60x objective

current=motorZtoETL(etlFun60x, z0, motorZ);

if dia.hOL.currentMode~=1 %make sure DC mode is set
    dia.hOL.setDCmode;
end

dia.hOL.setCurrent(current);

end

