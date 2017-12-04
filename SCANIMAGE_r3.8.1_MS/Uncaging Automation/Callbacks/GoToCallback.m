function [  ] = GoToCallback( varargin )
%GoToCallback is the callback function for when the user presses the GoTo
%button. it moves the stage to the selected or corresponding position and
%shows the spine of interest. The input can also be the position to move
%to, otherwise the default ua.SelectedPosition is used.
global ua state gh dia

if nargin==1
    posID=varargin{1};
else
    if isfield(ua,'SelectedPosition')
        posID=ua.SelectedPosition;
    else
        disp('Error: no position selected');
        return
    end
end

% move either motor or scan shift
if ua.params.fovModeOn
    dia.hPos.moveToNewScanAngle(posID, 0)
%     setScanAngleROI(posID,0);
    setScanProps(dia.handles.mdia.goToPushbutton);
else
    dia.hPos.moveToNewMotorPosition(posID)
    %check if already at position
%     motorGetPosition();
%     if dia.etl.acq.etlOn
%         state.motor.absZPosition=state.motor.absZPosition+etlVoltToMotorZCalc;
%     end
%     currentposition = [state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition];
%     currentposID=state.hSI.zprvPosn2PositionID(currentposition);
    
    %if not, move to position
%     if currentposID==0 || currentposID~=posID
%         absPos=[state.hSI.positionDataStructure(posID).motorX,state.hSI.positionDataStructure(posID).motorY,state.hSI.positionDataStructure(posID).motorZ];
%         motorOrETLMove(absPos);
%         motorPositionGoto(position);
%     end
end

%show appropriate ROIs
showUncagingRois( posID )
%%
updateUAgui;

end

