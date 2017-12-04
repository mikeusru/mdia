function moveWithZ( coordType, newPos, displayMode )
%MoveWithZ decides whether a move should use the motor Z or ETL
%coordinates.
% newPos is a three-coordinate vector
% coordType tells us whether to use relative or absolute coordinates
%  displayMode: <OPTIONAL;DEFAULT='none'> One of {'assume' 'verify' 'none'}.  Determines now newly set position should be displayed in ScanImage:
%                       'assume': The ScanImage relative/absolute X/Y/Z positions (those displayed) are updated to match the specified position at start of move
%                       'verify': Same as 'assume', but motorGetPosition() is called at end of move which updates ScanImage stored/displayed position values to match that read from device.
%                       'none': Do not set the Scanimage stored/displayed relative/absolute X/Y/Z positions and do not explicitly retrieve the final position from the motor controller
global af dia


if nargin<3
    motorInput=[coordType, newPos];
else
    motorInput=[coordType, newPos, displayMode];
end

if isfield(dia,'hOL') && af.params.isEtlOn
    %move with ETL
    if ~isfield(af.params,'motorZlimit') %make sure motor Z limit is set
        error('ETL MOVE ERROR - Motor Z Limit Not Set');
    end
    z0=af.params.motorZlimit;
    motorToETLmove(newPos(3),z0);
    if strcmp(coordType,'relative')
        newPos(3)=state.motor.relZPosition;
    elseif strcmp(coordType,'absolute')
        newPos(3)=state.motor.absZPosition;
    end
    motorInput(2)=newPos; %MAKE SURE THIS WORKS
    motorSetPosition(motorInput); %set motor X and Y but keep state Z variable

else 
    %motor input
    motorSetPosition(motorInput);
end



end

