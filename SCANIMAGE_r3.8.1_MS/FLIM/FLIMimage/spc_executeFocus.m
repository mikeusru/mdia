function spc_executeFocus

global state gh

h = gh.mainControls.focusButton;
val=get(h, 'String');
        
if strcmp(val, 'FOCUS')
    spc_stopFocus;
    spc_setupPixelClockDAQ_Specific;
    spc_parkLaser;
    spc_putDataFocus(1);
    
    if strcmp(get(gh.basicConfigurationGUI.figure1, 'Visible'), 'on')
        beep;
        setStatusString('Close ConfigurationGUI');
        return
    end
    state.internal.forceFirst=1;
    
    setStatusString('Focusing...');
    set(h, 'String', 'ABORT');
    
    set(gh.mainControls.grabOneButton, 'Visible', 'Off');
    set(gh.mainControls.startLoopButton, 'Visible', 'Off');
    turnOffMenusFocus;
    MP285Clear;
    resetCounters;    
    state.internal.abortActionFunctions=0;
    spc_startFocus;
    FLIM_StartMeasurement;
    updateCurrentROI;   %TPMOD 6/18/03
    spc_openShutter;
    state.internal.forceFirst=1;
    spc_dioTrigger(0);
    
%*****************************************************
%  Uncomment for benchmarking.....
%     state.time=[];
%     state.testtime=clock;
%*******************************************************
    
elseif strcmp(val, 'ABORT')
    state.internal.abortActionFunctions=1;
    setStatusString('Aborting Focus...');
    spc_closeShutter;
    set(h, 'Enable', 'off');
   
    spc_stopFocus;
    flushAOData;
    scim_parkLaser('soft');
    MP285Clear;
    
    set(h, 'String', 'FOCUS');
    set(h, 'Enable', 'on');
    set(gh.mainControls.startLoopButton, 'Visible', 'On');
%     if ~state.internal.looping
        set(gh.mainControls.grabOneButton, 'Visible', 'On');
        turnOnMenusFocus;
%     else
%         mp285Flush;
%         turnOffMenusFocus;
%         
%         resetCounters;
%         state.internal.abortActionFunctions=0;
%         setStatusString('Resuming cycle...');
%         
%         stopFocus;
%         spc_stopFocus;
%         
%         updateGUIByGlobal('state.internal.frameCounter');
%         updateGUIByGlobal('state.internal.zSliceCounter');
%         
%         state.internal.abort=0;
%         state.internal.currentMode=3;
%         
%         mainLoop;
%     end
    setStatusString('');
    flushAOData;
end

