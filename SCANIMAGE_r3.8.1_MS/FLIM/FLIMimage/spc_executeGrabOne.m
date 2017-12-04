function spc_executeGrabOne
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function is not used in version 2 anymore.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	global state gh
    
    h = gh.mainControls.grabOneButton;
    state.internal.looping=0;
    
	val=get(h, 'String');
		
	    if strcmp(val, 'GRAB')
            
            spc_stopGrab;
            spc_stopFocus;
            spc_flushAO;
            spc_parkLaser;
            spc_setupPixelClockDAQ_Specific;
            spc_putData(1);
            
%             %Synch to Physiology software if applicable...
% 			if state.init.syncToPhysiology
%                 if isfield(state,'physiology') & isfield(state.physiology,'mainPhysControls') & isfield(state.physiology.mainPhysControls,'acqNumber')
%                     maxVal=max(state.physiology.mainPhysControls.acqNumber,...
%                         state.files.fileCounter);
%                     state.physiology.mainPhysControls.acqNumber=maxVal;
%                     state.files.fileCounter=maxVal;
%                     updateGUIByGlobal('state.physiology.mainPhysControls.acqNumber');
%                     updateGUIByGlobal('state.files.fileCounter');
%                 end
%             end

			if strcmp(get(gh.basicConfigurationGUI.figure1, 'Visible'), 'on') == 1
				beep;
				setStatusString('Close Configuration GUI');
				return
			end
			
            ok=savingInfoIsOK;
			if ok==0				
                return
			end
% 			
% 			if state.internal.updatedZoomOrRot | state.init.eom.changed(state.init.eom.scanLaserBeam) % need to reput the data with the approprite rotation and zoom.
% 				state.acq.mirrorDataOutput = rotateMirrorData(1/state.acq.zoomFactor*state.acq.mirrorDataOutputOrg);
% 				%flushAOData;
% 				state.internal.updatedZoomOrRot=0;
% 			end
				
			% Check if file exisits
			overwrite = checkFileBeforeSave([state.files.fullFileName '.tif']);
			if isempty(overwrite)
				return;
			end
			
% 			startZoom;
			if state.init.autoReadPMTOffsets
				startPMTOffsets;
            end
            
            %%%%Motor preparations%%%%%%%%%%%%%%%%
            if state.motor.motorOn && state.acq.numberOfZSlices > 1                
                MP285Clear; %VI050608A, VI100608A
                pause(.5); %VI050608A
                
                if MP285RobustAction(@updateMotorPosition,'record position at start of stack', mfilename) %VI101508A
                    abortCurrent;
                    return;
                end                       
                state.internal.initialMotorPosition = state.motor.lastPositionRead;
     
                               
                if MP285RobustAction(@()MP285SetVelocity(state.motor.velocitySlow,1), 'set motor velocity at start of stack', mfilename) %VI101508A
                    abortCurrent;
                    return;
                end                
            else
                state.internal.initialMotorPosition = [];
            end 
            %%%%%%%%%%%
            

			setStatusString('Acquiring Grab...');
			set(h, 'String', 'ABORT');
			set([gh.mainControls.focusButton gh.mainControls.startLoopButton], 'Visible', 'Off');
			turnOffMenus;
			
			if state.acq.numberOfZSlices > 1	
                state.internal.initialMotorPosition=updateMotorPosition;
			else
				state.internal.initialMotorPosition=[];
			end		

			resetCounters;
			state.internal.abortActionFunctions=0;
			
			updateGUIByGlobal('state.internal.frameCounter');
			updateGUIByGlobal('state.internal.zSliceCounter');
			
            updateCurrentROI;   %TPMOD 6/18/03
            
            %yphys_sendStimulation(50, 50, 2);
            if state.shutter.shutterDelay==0
			    spc_openShutter;
            else
                state.shutter.shutterOpen=0;
            end

			spc_startGrab;
            FLIM_StartMeasurement;

            state.internal.pageCounter = 0;
            updateGUIByGlobal('state.internal.pageCounter');
            if isfield(state, 'yphys')
                if isfield(state.yphys, 'acq')
                    try
                        if isfield(state.yphys.acq, 'pulseN')
                            if state.files.fileCounter == 1
                                state.yphys.matchfile.pulseNs =  state.yphys.acq.pulseN;
                                state.yphys.matchfile.pulseNs = str2num(get(gh.yphys.stimScope.pulseN, 'String'));
                                state.yphys.acq.pulseN = state.yphys.matchfile.pulseNs;
                                display(['pulseN : ' num2str(state.yphys.acq.pulseN)]);
                                state.yphys.matchfile.yphysFiles = state.yphys.acq.phys_counter;
                            else
                                state.yphys.matchfile.pulseNs(state.files.fileCounter) =  str2num(get(gh.yphys.stimScope.pulseN, 'String'));
                                state.yphys.acq.pulseN = state.yphys.matchfile.pulseNs(end);
                                display(['pulseN : ' num2str(state.yphys.acq.pulseN)]);
                                state.yphys.matchfile.yphysFiles(state.files.fileCounter) = state.yphys.acq.phys_counter;
                            end
                        end
                    end
                end
            end
            [armedB, measureB, waitB, timeroutB] = FLIM_decode_test_state (0);
            a = get(state.spc.init.spc_ao);
            if length(a.EventLog) == 2
                disp('Image maybe already triggered');
            end
            
            
			spc_diotrigger(0);

            [armed, measure, wait, timerout] = FLIM_decode_test_state (0);
            status = FLIM_get_scan_clk_state;

            if armed && status && waitB
                %disp('Imaging triggered.');
            else
                disp('Imaging Not Triggered.');
                if ~status
                    disp('Pixel clock is not running');
                end
            end
            coltime=0;
            [out coltime]=calllib(state.spc.init.dllname,'SPC_get_actual_coltime',state.spc.acq.module,coltime);
            %disp(['Collection time = ', num2str(coltime), 's']);
            
		elseif strcmp(val, 'ABORT')

            state.spc.abortActionFunctions = 1;
            %beep;
            %disp('Now aborting');


            %TPMOD 7/7/03....
            if state.internal.roiCycleExecuting
                abortROICycle;
                return
            end
            
			state.internal.abortActionFunctions=1;
            state.spc.internal.ifstart = 0;

			spc_closeShutter;
			%stopGrab;
            
			setStatusString('Aborting...');
			set(h, 'Enable', 'off');
			
			%parkLaser;
            %stopGrab;
			spc_stopGrab;
            spc_parkLaser;
            %spc_putdata;            
            
            stopAllChannels(state.acq.dm);
            
            MP285Clear;
            scim_parkLaser('soft');
            flushAOData;
            
			%flushAOData;
			executeGoHome;
			pause(.05);

            turnOnMenus;
            if ~state.internal.looping
                set(h, 'String', 'GRAB');
                set(h, 'Enable', 'on');
                set([gh.mainControls.focusButton gh.mainControls.startLoopButton], 'Visible', 'On');
            end
			setStatusString('');
		else
			disp('executeGrabOneCallback: Grab One button is in unknown state'); 	% BSMOD - error checking
        end

         

