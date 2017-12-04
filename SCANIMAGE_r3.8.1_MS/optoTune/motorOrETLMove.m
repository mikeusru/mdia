function motorOrETLMove( newXYZ,resetZlimit,zStack )
%motorOrETLMove is called when the ETL may be used in order to move in Z.
%If the new position is within the ETL limits, the ETL is used, otherwise
%the Z motor is updated
%
%resetZlimit (optional) is a boolean value indicating whether the ETL Z
%limit should be reset if the move is out of the ETL's range. it is true by
%default.
%
% grabMode indicates whether this move is to a single position (false) or
% part of a Z stack (true)

global dia state ua


if ~dia.etl.acq.etlOn %if ETL is not on
    motorSetPositionAbsolute(newXYZ,'verify');
    return
end

if ~isfield(dia.handles,'etl3Dgui') || ~ishandle(dia.handles.etl3Dgui.figure1) || ~ishandle(dia.handles.etl3Dgui.minVoltageEdit)
    etl3Dgui;
end

if nargin<2
    resetZlimit=true;
    zStack=false;
end

if nargin<3
    zStack=false;
end

% if zStack && ~(ua.UAmodeON || dia.acq.grabAndTimeOn) % zStack is just a grab and not an automated step
%     initialEtlOffset=dia.etl.acq.initialEtlOffset;
%     disp('zstack');
% else
%     disp('nozstack');
% end
minOffset=8;

if dia.etl.acq.etlOn && dia.etl.acq.stackOnlyMode && ~zStack %if ETL mode is on but this isn't a Z-stack related move
    if state.acq.stackCentered
        stackOffset=floor((state.acq.numberOfZSlices*state.acq.zStepSize)/2.0)+minOffset-1;
    else
        stackOffset=minOffset;
    end
    motorSetPositionAbsolute([newXYZ(1),newXYZ(2),newXYZ(3)-stackOffset],'verify'); %move motor to position below that which is indicated
    updateZlimit(state.motor.absZPosition);
    if dia.etl.acq.voltageMin~=stackOffset
        zBase=motorZtoEtlVoltCalc(stackOffset);
        updateETLVoltage(zBase);
    end
    return
end

if dia.etl.acq.absZlimit~=state.motor.lastPositionRead(3) %this is redundant... maybe need to completely get rid of the Z limit and just use the last motor position read.
    updateZlimit(state.motor.lastPositionRead(3))
end

etlZrange=[dia.etl.acq.absZlimit, dia.etl.acq.absZlimit+dia.etl.acq.autoRange];

xyzChange=state.motor.lastPositionRead-newXYZ;

xyChange=xyzChange(1:2);
% zChange=xyzChange(3);
% if state.motor.lastPositionRead(3)~=dia.etl.acq.absZlimit
%     dia.etl.acq.absZlimit=state.motor.lastPositionRead(3);
% end

%if Z needs to be moved
% if zChange~=0
newMotorZ=newXYZ(3);
moveZmotor=false;
if newXYZ(3)>=etlZrange(1) && newXYZ(3)<=etlZrange(2) %if ETL value is within the range
    zBase=motorZtoEtlVoltCalc(newXYZ(3)-dia.etl.acq.absZlimit);
    updateETLVoltage(zBase);
    state.motor.absZPosition=newXYZ(3); %is this required? is it a good idea? not sure...
    %         newMotorZ=state.motor.lastPositionRead(3);
%     disp(1);
    %         disp(newXYZ(3));
    %         disp(initialEtlOffset);
elseif newXYZ(3)<etlZrange(1) %if ETL value is below range
    zBase=motorZtoEtlVoltCalc(minOffset); %set min value of etl to minOffset to avoid poor lower range control
    updateETLVoltage(zBase);
    newMotorZ=newXYZ(3)-minOffset;
    updateZlimit(newMotorZ);
%     disp(2);
    moveZmotor=true;
elseif newXYZ(3)>etlZrange(2) %if ETL value is above range
    zBase=motorZtoEtlVoltCalc(dia.etl.acq.autoRange); %set ETL to max value
    newMotorZ=newXYZ(3)-dia.etl.acq.autoRange;
    if zBase-dia.etl.acq.voltageMin~=0 %update ETL if it changed
        updateETLVoltage(zBase);
    end
    updateZlimit(newMotorZ);
%     disp(3);
    moveZmotor=true;
end
% else
%     disp(4);
if ~moveZmotor
    newMotorZ=state.motor.lastPositionRead(3);
end
% end

if abs(xyChange(1))>.2 || abs(xyChange(2))>.2 || moveZmotor %if X, Y, or Z motor needs to be moved
    motorSetPositionAbsolute([newXYZ(1:2),newMotorZ],'verify');
    state.motor.absZPosition=state.motor.absZPosition+etlVoltToMotorZCalc(zBase); % Is this necessary? I think so....
end

% disp(motorZtoEtlVoltCalc(dia.etl.acq.voltageMin));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateZlimit(newMotorZ)
        if resetZlimit
            
%             disp('updateZlimit');
            %             if zStack
            %                 dia.etl.acq.initialEtlOffset=dia.etl.acq.initialEtlOffset-(dia.etl.acq.absZlimit-newMotorZ);
            %                 if dia.etl.acq.initialEtlOffset<0
            %                     dia.etl.acq.initialEtlOffset=0;
            %                 end
            %             end
            dia.etl.acq.absZlimit=newMotorZ; %Z limit is below new motor Z
            set(dia.handles.mdia.etlZLimitEdit,'String',num2str(newMotorZ));
            
        end
    end

end
