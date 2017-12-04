function shiftAllPosns(posnID,axes)
            %shiftAllPosns(posnID,axes) is edited from the roiShiftPosition object in
            %the SI3 object class so the position GUI is not necessary for
            %position selection. posnID is a number signifying the current
            %position, and axes can be 'xy' or 'xyz'
            
            global state ua;
            
            if ~state.motor.motorOn
                return;
            end
            
            if nargin < 2 || isempty(axes)
                error('Specify the axes.');
            end
            
                      
            selectedPositionStruct = state.hSI.positionDataStructure(posnID);
            
            % update current motor position, and then compute the delta against the selected position
            motorGetPosition();
            
            dx = state.motor.absXPosition - selectedPositionStruct.motorX;
            dy = state.motor.absYPosition - selectedPositionStruct.motorY;
            if strcmpi(axes,'xyz')
                dz = state.motor.absZPosition - selectedPositionStruct.motorZ;
                if state.motor.dimensionsXYZZ && ~state.hSI.posnIgnoreSecZ
                    dzz = state.motor.absZZPosition - selectedPositionStruct.motorZZ;
                else
                    dzz = 0;
                end
            else
                dz = 0;
                dzz = 0;
            end
            
            % iterate through all Position entries, adding the offset
            positionIDs = state.hSI.positionDataStructure.keys();
            for i = 1:length(positionIDs)
                positionStruct = state.hSI.positionDataStructure(positionIDs{i});
                positionStruct.motorX = positionStruct.motorX + dx;
                positionStruct.motorY = positionStruct.motorY + dy;
                if strcmpi(axes,'xyz')
                    positionStruct.motorZ = positionStruct.motorZ + dz;
                    if state.motor.motorZEnable
                        positionStruct.motorZZ = positionStruct.motorZZ + dzz;
                    end
                end
                state.hSI.positionDataStructure(positionIDs{i}) = positionStruct;
            end
            state.hSI.roiUpdatePositionTable();
        end