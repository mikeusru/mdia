function mvz(dz)


global state gh

updateMotorPosition;
state.motor.relZPosition = state.motor.relZPosition + dz;
state.motor.absXPosition = state.motor.relXPosition + state.motor.offsetX; % Calculate absoluteX Position
state.motor.absYPosition = state.motor.relYPosition + state.motor.offsetY; % Calculate absoluteX Position
state.motor.absZPosition = state.motor.relZPosition + state.motor.offsetZ; % Calculate absoluteX Position
MP285SetVelocity(state.motor.velocityFast);
setMotorPosition;	% Sets X Motor Position to state.motor.absXPosition
MP285SetVelocity(state.motor.velocitySlow);
updateMotorPosition;