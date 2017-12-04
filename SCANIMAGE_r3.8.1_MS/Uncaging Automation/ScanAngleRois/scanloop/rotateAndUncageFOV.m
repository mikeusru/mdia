function rotateAndUncageFOV( fovNum )
%rotateAndUncageFOV begins the uncaging process for FOV mode. It is called
%by FOVuaPreuncageDone and also when uncaging is finished and it's time to
%move to the next position. It initiates FOVuaPostUncage when uncaging is
%totally complete.

global af dia ua state gh
persistent ds poscount

if ~ua.fov.acq.Uncage || ~ua.UAmodeON %check if process has been aborted
    return
end

ua.fov.acq.uncageCounter=ua.fov.acq.uncageCounter+1;

if ua.fov.acq.uncageCounter==1 %if this is the first uncaging call
    ds=ua.fov.FOVposStruct(fovNum).scanInfoDataset;
    poscount=length(ds);
end

if ua.fov.acq.uncageCounter>poscount
    ua.fov.acq.Uncage=false;
    FOVuaPostUncage;
    return
end

posID=ds.oldMotorPosition(ua.fov.acq.uncageCounter);
ua.acq.currentPos=posID;
ua.fov.acq.currentPos=posID;
setScanAngleROI( posID, 1 );
setupAOData; %needed to reset scanning shift
showUncagingRois(ua.acq.currentPos,true); %bring up appropriate uncaging ROIs
zdiff=abs(ds.zRoofOffset(ua.fov.acq.uncageCounter));
% zdiff=abs(ua.params.zRoof-state.motor.absZPosition);
setUncagingDwell(zdiff);  %set dwell time
yphys_stimScope('start_Callback',gh.yphys.stimScope.start); %Run uncaging cycle



end

