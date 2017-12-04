function karpova_triggeredMotorMove(eventName,eventData,arg1)
%ScanImage 3.8 user function to move to specified motor Position upon
%trigger starting image acquisition trial. Motor can optionally be returned
%to pre-trigger position when trial is completed or aborted.
%
%Function can be used, for example, to advance/retract objective lens focus
%at start/end of image acquisition Trial, e.g. to limit time where
%objective lens is in proximity to specimen.
%
%Event bindings/arguments
% 'acquisitionStarting': arg1=returnHome; logical indicating whether to return to star position on acquisition finish/abort
% 'acquisitionStarted': arg1=targetPosnID; scalar integer indicating ScanImage position ID to move to following trigger starting acquisition

persistent returnHome homePosn

global state

switch eventName
    
    case 'acquisitionStarting'
        if nargin < 3
            returnHome = true;
        else
            returnHome = arg1;
        end
               
        
        if returnHome
            homePosn = motorGetPosition();
        end
    
    case 'acquisitionStarted'        
        
        assert(nargin >= 3,'Additional argument (trialPosnID) required for user function %s on ''acquisitionStarted'' event',mfilename);
        trialPosnID = arg1;
      
        %Identify target position
        assert(state.hSI.positionDataStructure.isKey(trialPosnID),'Argument to user function %s on ''acquisitionStarted'' event specifies an invalid trialPosnID:%d',mfilename,trialPosnID);
        s = state.hSI.positionDataStructure(trialPosnID);
       
        targetPosn = [s.motorX s.motorY s.motorZ];
        
        if state.motor.dimensionsXYZZ && ~state.hSI.posnIgnoreSecZ
            targetPosn = [targetPosn s.motorZZ];
        end        
        
        %Initiate asynchronous move operation
        state.motor.hMotor.moveStartAbsolute(targetPosn);
        
        
      
    case {'acquisitionDone' 'abortAcquisitionEnd'}
        
        if isequal(eventName,'abortAcquisitionEnd')
            state.motor.hMotor.moveInterrupt();
        end
        
        if isempty(returnHome) %shouldn't happen though
            returnHome = true;
        end
        
        if returnHome
            state.motor.hMotor.moveWaitForFinish();
            
            if isempty(homePosn)
                warning('Home position has not been correctly captured. Leaving objective in final position');
            else
                state.motor.hMotor.moveCompleteAbsolute(homePosn);
            end                        
        end
            
            

end




