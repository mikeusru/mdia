function volts = motorZtoETL( etlFunc, targetMotorZ, z0 )
%motorZtoETL( etlFunc, z0, targetMotorZ, inverted )
% is used to translate motor Z movements to ETL current. 
%
% etlFunc is a vector representing values from a  polynomial
% function converting microns to volts
%
% z0 is the motor Z value at which the current = 0
%
% targetMotorZ is the Z value (um) which is to be translated into a current (mA).
%
% inverted is an optional boolean indicating whether the Z value and
% current are inversely proportional or whatever... as in when Z decreases,
% current increases. it's false by default.

% find y intercept (current at which z=0). at y=0, c=-ax^2-bx. remember
% algebra?

if nargin<4
    inverted=false;
end

if inverted
    etlFunc=-etlFunc;
end

c=-etlFunc(1)*z0*z0 - eltFunc(2)*z0;

volts = eltFunc(1)*targetMotorZ*targetMotorZ + eltFunc(2)*targetMotorZ + c;



end

