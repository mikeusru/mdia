classdef ControlledAblationModel < most.Model
    %CONTROLLEDABLATIONMODEL Module for controlling ScanImage 3.x Beam for delivery of photoablation energy that self-arrests when plasma luminescence is detected
    %   Detailed explanation goes here
    
    
    %TODO: Support 'pulses' mode and/or 'ramped pulses' mode
    %TODO: Handle Pockels linearization
    %TODO: Handle finite inputSampsToCheck - need to use readAnalogData explicitly, by turning off autoRead property
    
    %% VISIBLE PROPERTIES    
    properties (SetObservable)
        mode = 'ramp'; %One of {'ramp' 'pulses'} 
        
        targetROI; %Numeric value indicating ROI to target. Typically a point ROI. Only shift parameters are used here.
        targetROIZoom = inf; %Numeric indicating zoom value of area to scan centered on shift coordinates of specified targetROI. Value of Inf implies a point ROI, i.e. no scanning.
        targetROINumLines = inf; %Numeric indicating number of lines to scan in area (if targetROIZoom is finite). Determines length of time for each area scan. Value of Inf implies current ScanImage configuration value is used.
        
        startPower = 10; %Percent power to use at start of ablation delivery
        endPower = 10; %Percent power to use at start of ablation delivery
        
        duration = 1; %Time, in seconds, of delivered ablation
        pulseDuration = 10e-6; %Time, in seconds, of each pulse ('pulses' mode only)
        pulseInterval = 20e-6; %Time, in seconds, between start of each pulse ('pulses' mode only)
        
        ablationDoneThreshold = inf; %Input channel value which must be exceeded in order to auto-arrest ablation. Value of Inf implies auto-arrest option is disabled.        
        
        inputCheckRate = 50; %Rate, in Hz, at which input channel is checked to see if ablation is done        
        inputSampleRate = 10e3; %Rate, in Hz, at which input channel data is stored/processed. Constrained to an integer submultiple of the true input sample rate       
        inputSampsToCheck = inf; % (NOT YET IMPLEMENTED - Use Inf for now) Specifies number of samples to decimate and process for each period specified by 1/inputCheckRate. Value of Inf specifies to process all sample within inputCheckRate period.
    
        inputDataStore = true; %Logical. If true, input data acquired during ablation will be stored
        inputDataShow = false; %Logical. If true, and inputDataStore is also true, then input data acquired during ablation will be automatically shown at end of ablation.
        
        inputPreAblationTime = 0;
        inputPostAblationTime = 0;

    end
    
    properties (Hidden,SetObservable)
        ablationActive = false; %Logical indicating if ablation is currently ongoing
    end
    
    %Read-only
    properties (Dependent, SetAccess=protected)
       numPulses;
       durationSamples; %duration converted into samples
       startVoltage; %startPower converted into voltage, using ScanImage beam calibration lookup table
       endVoltage; %endPower converted into voltage, using ScanImage beam calibration lookup table            
       
    end

    %Constructor-set
    properties (SetAccess=protected)
       ablationBeamIdx; %Identify ScanImage beam # used for photoablation
       inputChanIdx; %Identify ScanImage channel # (1-based) used for detecting photablation completion
    end
    
    %% HIDDEN PROPERTIES    
    properties (Hidden, SetAccess=protected)       
        beamBuffer; %Column vector with output voltage data for ablation beam control
        
        hSIListeners; %Structure of SI listeners maintained by this class
        %hInputCheckTimer; %Timer object used to periodically poll the AI object to see if ablation should be self-arrested
        
        hInputDataFig; %Fig handle for graph showing just-collected input data
        hInputDataAx; %Axes handle for graph showing just-collected input data

        inputDataBuf; %Runnign buffer of input data collected during last/ongoing ablation
        inputTimeVec; %Running buffer of time points at which input data was collected
        inputAllDataBuf;% cell array with ALL data
        inputDataBufIdx; %Index into inputDataBuf, which increments during ablation 
        
        aiPropCache = struct(); %Struct of cached AI Task properties to restore following ablation
        
        siModeToRestore; %Specifies SI mode to restore on completing ablation, e.g. Focus or Grab
        
        startTime;
        inputTimes;
    end       

    properties (Hidden,Dependent)
        inputDataTimebase;
        
        inputEveryNSamples; %EveryNSamples value to use for overridden AI Task        
    end
    
    properties (Hidden,Constant)
       MSPERLINE = 1; 
    end
    
    %% EVENTS
    events
        ablationDone;
    end       

        
    
    %% CONSTRUCTOR ETC
    methods
        
        function obj = ControlledAblationModel(varargin)
            %Prop-value pairs
            %  ablationBeamIdx: SI3 beam index of beam to control for ablation
            
            global state
            
            assert(floor(scim_isRunning) == 3,'ScanImage 3.x must be running!');
            
            pvArgs = most.util.filterPVArgs(varargin,{'ablationBeamIdx' 'inputChanIdx'},{'ablationBeamIdx'});
            pvStruct = most.util.cellPV2structPV(pvArgs);
            
            obj.ablationBeamIdx = pvStruct.ablationBeamIdx;
            if isfield(pvStruct,'inputChanIdx')
                obj.inputChanIdx = pvStruct.inputChanIdx;
            end
            
            if ~isempty(obj.inputChanIdx)
                obj.hInputDataFig = figure('Name','Controlled Ablation Input Signal','IntegerHandle','off','NumberTitle','off','Visible','off','CloseRequestFcn',@(src,evnt)set(src,'Visible','off'));
                obj.hInputDataAx = axes('Parent',obj.hInputDataFig);
            end

            %SI Event Listerners
            obj.hSIListeners.appClose = addlistener(state.hSI,'appClose',@obj.zcbkSIListener);
        end
        
        function delete(obj)
           delete(obj.hInputDataFig);            
        end
    end
    
    %% PROPERTY ACCESS 
    
    methods
        function set.ablationDoneThreshold(obj,val)
            obj.validatePropArg('ablationDoneThreshold',val);
            if isempty(obj.inputChanIdx) %#ok<MCSUP>
                assert(isinf(val), 'No input channel has been specified for ablation completion detection, so ablation self-arrest feature disabled.\n');
            end
            obj.ablationDoneThreshold = val;
        end
        
        
        function val = get.beamBuffer(obj)            
            global state
            
            switch obj.mode
                case 'ramp'                                                              
                    val = linspace(obj.startVoltage,obj.endVoltage,obj.durationSamples)';

                    minLevel = state.init.eom.lut(state.init.eom.min(obj.ablationBeamIdx));

                    if obj.inputDataStore
                        preSamples = round(obj.inputPreAblationTime * state.acq.outputRate);
                        postSamples = round(obj.inputPostAblationTime * state.acq.outputRate);
                        
                        if preSamples > 0
                            val = [repmat(minLevel,preSamples,1); val];                                                
                        end
                    
                        if postSamples > 0
                            val = [val; repmat(minLevel,postSamples,1)];                                                
                        end
                    end            
                       
                    %Ensure we end at the minLevel 
                    if ~obj.inputDataStore || postSamples == 0
                        val(end+1) = minLevel;
                    end                   
                    
                                        
                case 'pulses'
                    %TODO
                    
                otherwise
                    assert(false);
            end
            
        end
        
        function set.duration(obj,val)
            obj.validatePropArg('duration',val);
            obj.duration = val;
        end
                        
        function val = get.durationSamples(obj)
            global state
           
            val = round(state.acq.outputRate * obj.duration);
        end
        
        function val = get.endVoltage(obj)
            global state
            val = state.init.eom.lut(obj.ablationBeamIdx,obj.endPower);
        end
        
        function set.endVoltage(obj,val)
            obj.validatePropArg('endVoltage',val);
            obj.endVoltage = val;
        end
        
        function val = get.inputCheckRate(obj)
            decimationFactor = round(obj.inputSampleRate / obj.inputCheckRate);
            val = obj.inputSampleRate / decimationFactor;
        end
        
        function set.inputCheckRate(obj,val)
            obj.validatePropArg('inputCheckRate',val);
            assert(obj.inputCheckRate <= obj.inputSampleRate,'Value of inputCheckRate must be smaller than inputSampleRate');
            obj.inputCheckRate = val;            
        end
          
        
        function set.inputDataShow(obj,val)
            obj.validatePropArg('inputDataShow',val);
            assert(~val || ~isempty(obj.inputChanIdx),'Cannot enable inputDataShow because no input channel was defined on initiation');
            obj.inputDataShow = val;
        end
        
        
        function set.inputDataStore(obj,val)
            obj.validatePropArg('inputDataStore',val);
            assert(~val || ~isempty(obj.inputChanIdx),'Cannot enable inputDataStore because no input channel was defined on initiation');
            obj.inputDataStore = val;
        end
        
        function val = get.inputEveryNSamples(obj)
            global state
            
          val = state.acq.inputRate / obj.inputCheckRate; 
        end
        
        %         function val = get.inputDataTimebase(obj)
        %             val = (-1 + (1:length(obj.inputDataBuf))) * (1/obj.ablationDoneCheckRate);
        %         end
        
        
        function set.inputPostAblationTime(obj,val)
            obj.validatePropArg('inputPostAblationTime',val);
            obj.inputPostAblationTime = val;
        end
        
        function set.inputPreAblationTime(obj,val)
            obj.validatePropArg('inputPreAblationTime',val);
            obj.inputPreAblationTime = val;
        end
        
        function set.inputSampleRate(obj,val)
            obj.validatePropArg('inputSampleRate',val);
            
            %Constrain to integer submultiple of AI rate
            global state
            assert(val <= state.acq.inputRate,'Specified ''inputSampleRate'' must be less or equal to AI channel input rate, set in ScanImage');
            decimation = round(state.acq.inputRate/val);
            
            obj.inputSampleRate = state.acq.inputRate / decimation;                  
         
        end
        
        function val = get.numPulses(obj)
            val = floor(obj.duration/obj.pulseInterval);            
            
            %Add one final pulse, if it does not cause duration to be exceeded
            if (val * obj.pulseInterval + obj.pulseDuration) <= obj.duration
                val = val + 1;
            end
        end
        
        function set.pulseDuration(obj,val)
            obj.validatePropArg('pulseDuration',val);
            obj.pulseDuration = val;
        end
        
        function set.pulseInterval(obj,val)
            obj.validatePropArg('pulseInterval',val);
            obj.pulseInterval = val;
        end
        

        function val = get.startVoltage(obj)
           global state           
           val = state.init.eom.lut(obj.ablationBeamIdx,obj.startPower);
        end
        
        function set.startVoltage(obj,val)
            obj.validatePropArg('startVoltage',val);
            obj.startVoltage = val;
        end

        
        function set.targetROI(obj,val)
            obj.validatePropArg('targetROI',val);
            obj.targetROI = val; 
        end
        
        
    end
    
    %% PUBLIC METHODS
    
    methods
        
        function saveInputData(obj)
            assert(~isempty(obj.inputDataBuf),'There is no input data to show!!');
            
            obj.zprvCleanupInputBuffer(); %Remove trailing-nans from input buffer
            procBuf = obj.zprvProcessInputBuffer();

            s = struct();
            s.t = obj.inputTimes(:);
            s.I = procBuf(:);

            [f,p] = uiputfile('*.mat','Save ablation photometry file',sprintf('%s.mat',datestr(now,30)));
            
            save(fullfile(p,f),'-struct','s');            
        end
        
        function showInputData(obj)
            assert(~isempty(obj.inputDataBuf),'There is no input data to show!!');
            
            obj.zprvCleanupInputBuffer(); %Remove trailing-nans from input buffer    
            procBuf = obj.zprvProcessInputBuffer();
            
            set(obj.hInputDataFig,'Visible','on');
            plot(obj.hInputDataAx,obj.inputTimes,procBuf);            
        end
        
        function start(obj)
            %Delivers ablation according to specified parameters for specified duration, at specified ROI
            %If ScanImage was acquiring at time of call, acquisition is stopped during ablation and resumed following its completion
            
            global state
            
            obj.siModeToRestore = '';
            abortedMode = abortCurrent(false);
            if strcmpi(abortedMode,'loop')
                error('Starting ablation in midst of ongoing LOOP acquisition not supported. Acquisition/abalation aborted.');
            end
            obj.siModeToRestore = abortedMode;
            
            %Goto specified ROI
            roiExists = state.hSI.roiDataStructure.isKey(obj.targetROI);
            if ~roiExists
                obj.targetROI = [];
                error('ROI number specified does not exist in ScanImage');
            end                       
            strct = state.hSI.roiDataStructure(obj.targetROI);
            
            assert(strcmpi(strct.type,'point'),'At this time, specified ROI must be a point-type ROI');            
  
            %Prepare Beam output buffers
            state.init.eom.hAO.control('DAQmx_Val_Task_Unreserve');
            
            numBeams = state.init.eom.numberOfBeams;
            beamBuffer_ = zeros(numel(obj.beamBuffer),numBeams);
            beamBuffer_(:,obj.ablationBeamIdx) = obj.beamBuffer;
            for i=1:numBeams
                if i ~= obj.ablationBeamIdx
                    beamBuffer_(:,i) = state.init.eom.lut(i,state.init.eom.min(i));
                end
            end
     
            state.init.eom.hAO.cfgOutputBuffer(size(beamBuffer_,1));
            state.init.eom.hAO.cfgSampClkTiming(state.acq.outputRate, 'DAQmx_Val_FiniteSamps',state.init.eom.hAO.get('bufOutputBufSize'));            
            state.init.eom.hAO.writeAnalogData(beamBuffer_);

            %Prepare input acquisition
            doInputAcq = ~isinf(obj.ablationDoneThreshold) || obj.inputDataStore;
            if doInputAcq
                
                obj.aiPropCache.everyNSamples = state.init.hAI.everyNSamples;
                obj.aiPropCache.readChansToRead = get(state.init.hAI,'readChannelsToRead');
                obj.aiPropCache.bufSize = get(state.init.hAI,'bufInputBufSize');                                                                       
                
                state.init.hAI.set('readChannelsToRead',state.init.hAI.channels(obj.inputChanIdx).chanName);
                
                state.init.hAI.everyNSamples = [];
                bufSize = state.init.hAI.computeBufSizeForEveryNSamples(state.acq.inputRate,0.5,obj.inputEveryNSamples);
                state.init.hAI.cfgInputBufferVerify(bufSize,2);                                                                
                                
                state.init.hAI.registerEveryNSamplesEvent(@obj.zcbkCheckAblationDone,obj.inputEveryNSamples);
                      
                if obj.inputDataStore
                    obj.inputDataBuf = nan(ceil((obj.duration + obj.inputPreAblationTime + obj.inputPostAblationTime) * obj.inputSampleRate),1);
                else
                    obj.inputDataBuf = [];
                end
            else
                obj.aiPropCache = struct();
                obj.inputDataBuf = [];
            end
            obj.inputDataBufIdx = 1; %Reset idx value to 1
            obj.inputTimes = obj.inputDataBuf;
            obj.inputAllDataBuf = {};
            
            ME = [];
            try 

                %Determine & adjust scanner output buffer
                roiCenters = [strct.RSPs.scanShiftFast strct.RSPs.scanShiftSlow];
            
                if isinf(obj.targetROIZoom) %Point scan
                    scanBuffer = repmat(roiCenters,size(obj.beamBuffer,1),1);
                else
                    scanBuffer = obj.zprvComputeAreaScanBuffer(roiCenters);
                end
                
                %Adjust scanner output buffer
                if ~state.acq.fastScanningX
                    scanBuffer = fliplr(scanBuffer);
                end
                
                scanBuffer = scanBuffer + repmat([state.init.scanOffsetAngleX state.init.scanOffsetAngleY],size(scanBuffer,1),1);
                scanBuffer(end+1,:) = zlclDetermineParkAngle();  %Ensure scanner is parked at end
                
                state.init.hAO.control('DAQmx_Val_Task_Unreserve');
                state.init.hAO.cfgOutputBuffer(size(scanBuffer,1));
                state.init.hAO.cfgSampClkTiming(state.acq.outputRate, 'DAQmx_Val_FiniteSamps',state.init.hAO.get('bufOutputBufSize'));
                state.init.hAO.writeAnalogData(scanBuffer * state.init.voltsPerOpticalDegree); %Convert to voltage                
                
                %Start ablation
                %state.init.eom.hAO.registerEveryNSamplesEvent(@(src,evnt)obj.zprvAblationDone(src,evnt),state.init.hAO.get('bufOutputBufSize')/2);
                state.init.eom.hAO.registerDoneEvent(@(src,evnt)obj.zprvAblationDone(src,evnt));
                
                armTriggers([state.init.hAO state.init.eom.hAO],[],true,false,false); %Configure output Tasks for internal triggering
                start(state.init.hAO);
                start(state.init.eom.hAO);
                
                if doInputAcq
                    start(state.init.hAI);
                end
                
                obj.ablationActive = true;
                
                openShutter(true);
                dioTrigger();
                
                %                 if ~isempty(obj.hInputCheckTimer)
                %                     obj.inputTimes = [];
                %                     obj.startTime = tic;
                %                     start(obj.hInputCheckTimer);
                %                 end
                %
                
                
            catch MEtemp
                ME = MEtemp;
            end
            
            if ~isempty(ME)
                if doInputAcq
                    obj.zprvRestoreAITask();
                end
                ME.rethrow();
            end
                
            
        end
        
        
    end
    
    %% HIDDEN METHODS
    methods (Hidden)
        
        function zcbkCheckAblationDone(obj,src,evnt)
           global state                    
               
           %            if ~obj.ablationActive
           %                fprintf('Ignoring EveryN callback!\n');
           %                return;
           %            end
           
           if state.init.eom.hAO.isTaskDone()
               disp('Stopping from EveryNSample callback!');
               obj.zprvAblationDone(src,evnt,false);
               %return;
           end
           
           %disp(fprintf('%s\n',state.init.hAI.sampQuantSampMode));
           
           %inputData = state.init.hAI.readAnalogData(min(obj.inputSampsToCheck, obj.inputEveryNSamples),'native');
           inputData = evnt.data;
           
           %fprintf('Nums samps acquired: %d\n',state.init.hAI.get('readTotalSampPerChanAcquired'));
           if any(inputData > obj.ablationDoneThreshold)
               disp('Ablation self-arrest');
               obj.zprvAblationDone(src,evnt,true);
           elseif rand(1) < 0.02
               fprintf('Continuing with ablation. Num Samples read: %d. Max/min value in inputData of size %s and class %s: %g %g\n',state.init.hAI.get('readTotalSampPerChanAcquired'),mat2str(size(inputData)),class(inputData), max(inputData(:)),min(inputData(:)));

           end

           if obj.inputDataStore
               %decimationFactor = obj.inputSampleRate / obj.inputCheckRate;               
               decimationFactor = state.acq.inputRate / obj.inputSampleRate;
               sampsToStore = size(inputData,1)/decimationFactor;
               
               idx = obj.inputDataBufIdx;
               endIdx = idx + sampsToStore - 1;
               obj.inputDataBufIdx = endIdx + 1;
               
               idxs = idx:endIdx;
               inputTimes_ = (idxs - 1) / obj.inputSampleRate;
               
               obj.inputDataBuf(idxs) = inputData(1:decimationFactor:end);
               obj.inputTimes(idxs) = inputTimes_;
           end
           
           %            if obj.inputDataStore
           %                idx = get(src,'TasksExecuted');
           %                obj.inputDataBuf(idx) = mean(inputData);
           %
           %                if idx == 1
           %                    obj.inputTimeVec(idx) = 0;
           %                else
           %                    obj.inputTimeVec(idx) = obj.inputTimeVec(idx-1) + get(src,'InstantPeriod');
           %                end
           %            end
           
           %            if stopAblation
           %                obj.zprvAblationDone();
           %            end

        end
            
            
        
        function zprvAblationDone(obj,~,~,cancelAblate)
            global state            
           
            if ~obj.ablationActive
                return;
            end
            
            %See if this is a cancelled (uncompleted) ablation
            if nargin < 4
                cancelAblate = false;
            end
            
            if ~cancelAblate && ~state.init.eom.hAO.isTaskDone()
                return;
            end
            
            %Signal ablation is done
            obj.ablationActive = false;
            
 
                        
            %Stop AO Tasks
            if cancelAblate
                state.init.hAO.abort();
                state.init.eom.hAO.abort();
            else
                state.init.hAO.waitUntilTaskDone(.5); %Should be done at the same time
                
                state.init.hAO.stop();
                state.init.eom.hAO.stop();
            end

 

            
            %Flush output buffers  & park    
            state.init.eom.hAO.control('DAQmx_Val_Task_Unreserve');            
            state.init.hAO.control('DAQmx_Val_Task_Unreserve');
            
            state.init.eom.hAO.registerDoneEvent(); %Unregister event
            %state.init.eom.hAO.registerEveryNSamplesEvent(); %Unregister event
            
            %Stop AI Task
            didInputAcq = ~isempty(fieldnames(obj.aiPropCache));
            if didInputAcq
                %stop(obj.hInputCheckTimer);
                state.init.hAI.stop();
            end
            
            scim_parkLaser();
            
            flushAOData();
            
            if didInputAcq
                obj.zprvRestoreAITask();
            end
            
            %Show input data, if applicable
            if obj.inputDataStore && obj.inputDataShow
                obj.showInputData();
            end
           
            %Restart acquisition following prior ablation, if applicable
            if ismember(lower(obj.siModeToRestore),{'focus' 'grab'})
                
            end                       
            
            if ~cancelAblate
                obj.notify('ablationDone');
            end
            
            fprintf('Ablation done!\n');
            
            
        end
       
        function zcbkSIListener(obj,~,evnt)
            
           %global state
           
           eventName = evnt.EventName;
           
           switch eventName
               case 'appClose'
                   delete(obj);
                   
               otherwise 
                   assert(false);
               
           end
            
        end
        
        function zprvRestoreAITask(obj)
           global state          
                     
           assert(~isempty(obj.inputChanIdx));           
                                
           %            state.init.hAI.reset('readOverWrite');
           %            state.init.hAI.reset('readRelativeTo');
           %            state.init.hAI.reset('readOffset');
           
           state.init.hAI.readChannelsToRead = obj.aiPropCache.readChansToRead;                                             
           
           state.init.hAI.everyNSamples = [];
           state.init.hAI.cfgInputBufferVerify(obj.aiPropCache.bufSize,2*obj.aiPropCache.everyNSamples);
           state.init.hAI.everyNSamples = obj.aiPropCache.everyNSamples;
           
           obj.aiPropCache = struct();
        end
        
        function zprvCleanupInputBuffer(obj)
            %Remove trailing nans
            len = length(obj.inputDataBuf);
            nanIdxs = isnan(obj.inputDataBuf);
            removeIdxs = [];
            if ismember(len,nanIdxs)
                for i=len:-1:0
                    if ismember(i,nanIdxs)
                        removeIdxs(end+1) = i;
                    else
                        break;
                    end
                end
            end
            obj.inputDataBuf(removeIdxs) = [];
            obj.inputTimes(removeIdxs) = [];
        end
                
        function procBuf = zprvProcessInputBuffer(obj)
            
            global state            
            
            procBuf = obj.inputDataBuf - state.acq.(sprintf('pmtOffsetChannel%d',obj.inputChanIdx));
            if state.acq.(sprintf('inputVoltageInvert%d',obj.inputChanIdx))
                procBuf = -procBuf;
            end
            
        end
        
        function scanBuffer = zprvComputeAreaScanBuffer(obj,roiCenters)
            
            global state

            numLines = ceil(obj.duration/(obj.MSPERLINE * 1e-3));
            if mod(numLines,2) == 1
                numLines = numLines + 1;
            end
            areaAngularRange = state.init.scanAngularRangeReferenceFast / obj.targetROIZoom;
            
            %Fast scanner pattern
            sampsPerLine = round(state.acq.outputRate * obj.MSPERLINE * 1e-3);
            
            scanBufferFast = linspace(  roiCenters(1) - areaAngularRange/2,...
                roiCenters(1) + areaAngularRange/2,sampsPerLine)';
            scanBufferFast = [scanBufferFast;flipud(scanBufferFast)];
            scanBufferFast = repmat(scanBufferFast,numLines/2,1);
            
            %Slow scanner pattern
            if isinf(obj.targetROINumLines)
                numLinesSlow = state.acq.linesPerFrame;
            else
                numLinesSlow = obj.targetROINumLines;
            end
            
            scanBufferSlow = linspace(  roiCenters(2) - areaAngularRange/2,...
                roiCenters(2) + areaAngularRange/2,...
                numLinesSlow * sampsPerLine)';
            
            scanBufferSlow = repmat(scanBufferSlow,ceil(numLines/numLinesSlow),1);
            
            scanBuffer = [scanBufferFast scanBufferSlow(1:numel(scanBufferFast))];
            
            %Truncate size to match beamBuffer
            if size(scanBuffer,1) > numel(obj.beamBuffer)
                scanBuffer(numel(obj.beamBuffer)+1:end,:) = [];
            end
        end
            
    end
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.Model)
    properties (Hidden,SetAccess=protected)
       mdlPropAttributes = zlclInitPropMetadata();
       
       mdlHeaderExcludeProps;        
    end
    
end


%% LOCAL FUNCTIONS

function xy = zlclDetermineParkAngle()

global state
xy = [state.init.parkAngleX state.init.parkAngleY];
if state.init.parkAngleAllowInvert %Specifies that angle value is an absolute value, which can be inverted if advantageous
    if state.acq.fastScanningX
        signMultiplier = [-sign(state.acq.scanAngleMultiplierFast * state.init.scanAngularRangeReferenceFast), -sign(state.acq.scanAngleMultiplierSlow * state.init.scanAngularRangeReferenceSlow)];
    else
        signMultiplier = [-sign(state.acq.scanAngleMultiplierSlow * state.init.scanAngularRangeReferenceSlow), -sign(state.acq.scanAngleMultiplierFast * state.init.scanAngularRangeReferenceFast)];
    end
    
    signMultiplier(signMultiplier==0) = 1;
    xy = abs(xy) .* signMultiplier;
end
end


function s = zlclInitPropMetadata()

s = struct();

s.mode = struct('Options',{{'ramp' 'pulses'}});
s.startPower = struct('Attributes',{{'integer' 'positive' '<=' 100}});
s.endPower = struct('Attributes',{{'integer' 'positive' '<=' 100}});
s.duration = struct('Attributes',{{'finite' 'positive' 'scalar'}});
s.pulseDuration = struct('Attributes',{{'finite' 'positive' 'scalar'}});
s.pulseInterval = struct('Attributes',{{'finite' 'positive' 'scalar'}});

s.ablationDoneThreshold = struct('Attributes',{{'positive' 'scalar'}});
s.ablationDoneCheckRate = struct('Attributes',{{'positive' 'scalar' 'finite'}});

s.inputSampleRate = struct('Attributes',{{'positive' 'scalar' 'finite'}});
s.inputCheckRate = struct('Attributes',{{'positive' 'scalar' 'finite'}});
s.inputSampsToCheck = struct('Attributes',{{'positive' 'scalar' }});
s.inputPreAblationTime = struct('Attributes',{{'nonnegative' 'scalar' 'finite'}});
s.inputPostAblationTime = struct('Attributes',{{'nonnegative' 'scalar' 'finite'}});

s.inputDataShow = struct('Classes','binaryflex');
s.inputDataStore = struct('Classes','binaryflex');

s.targetROI = struct('Attributes',{{'finite' 'scalar' 'positive'}},'AllowEmpty',1);
s.targetROIZoom = struct('Attributes',{{'scalar' 'positive'}},'AllowEmpty',1);
s.targetROINumLines = struct('Attributes',{{'scalar' 'positive'}},'AllowEmpty',1);

end

