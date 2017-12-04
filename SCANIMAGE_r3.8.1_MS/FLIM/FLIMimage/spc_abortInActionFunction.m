function abortInActionFunction
% abort GRAB or LOOP from within an action function
spc_stopGrab;
FLIM_StopMeasurement;
closeShutter;

scim_parkLaser;
stopGrab;
closeShutter;
pause(.01);

	
