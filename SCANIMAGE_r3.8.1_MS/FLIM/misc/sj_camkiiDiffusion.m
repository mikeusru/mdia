function sj_camkiiDiffusion (flag);
global state;
global gh;


numberOfFrames = 40;  %Number of frames during stimulation.

preAcqusition = 1;
repeatPeriod = 15; %Seconds %NOT ACTIVE
postAcqusition = 50;
numberOfFrames_Pre = 1; %Number of frames during Pre- and Post acquisition.
nSlices = 1;
% 
% set(gh.mainControls.shutterDelay, 'String', 0);
% genericCallback(gh.mainControls.shutterDelay);
% updateShutterDelay;
% 
% set(gh.spc.FLIMimage.uncageEveryFrame, 'String', num2str(numberOfFrames_Pre));
% state.spc.acq.uncageEveryXFrame = numberOfFrames;
% 
% set(gh.standardModeGUI.numberOfFrames, 'String', num2str(numberOfFrames_Pre));
% genericCallback(gh.standardModeGUI.numberOfFrames);
% state.acq.numberOfFrames=state.standardMode.numberOfFrames;
% updateGuiByGlobal('state.acq.numberOfFrames');
% preAllocateMemory;
% alterDAQ_NewNumberOfFrames;
% 
% tic;
%     
% for i=1:preAcqusition
%     executeGrabOneCallback(gh.mainControls.grabOneButton);
%     toc
%     pause(repeatPeriod - toc);
%     tic;
% end

if flag == 1

    set(gh.mainControls.shutterDelay, 'String', 1);
    genericCallback(gh.mainControls.shutterDelay);
    updateShutterDelay;

    set(gh.spc.FLIMimage.uncageEveryFrame, 'String', num2str(numberOfFrames));
    state.spc.acq.uncageEveryXFrame = numberOfFrames;

    set(gh.standardModeGUI.numberOfFrames, 'String', num2str(numberOfFrames));
    genericCallback(gh.standardModeGUI.numberOfFrames);
    state.acq.numberOfFrames=state.standardMode.numberOfFrames;
    updateGuiByGlobal('state.acq.numberOfFrames');
    preAllocateMemory;
    alterDAQ_NewNumberOfFrames;

    set(gh.standardModeGUI.averageFrames, 'Value', 0);
    genericCallback(gh.standardModeGUI.averageFrames);
    state.acq.averaging=state.standardMode.averaging;
    updateHeaderString('state.acq.averaging');
    preallocateMemory;
    
    set(gh.standardModeGUI.numberOfSlices, 'String', num2str(1));
    genericCallback(gh.standardModeGUI.numberOfSlices);
    state.acq.numberOfZSlices=state.standardMode.numberOfZSlices;
    updateGuiByGlobal('state.acq.numberOfZSlices');
    preallocateMemory;
elseif flag == 0
% 
% toc
% pause(repeatPeriod - toc);
% tic;
% 
% %%%%
% if state.spc.acq.SPCdata.mode == 2
% 	state.spc.acq.SPCdata.trigger = 1;
%     if FLIM_setupScanning(0)
%         return;
%     end
% 	state.internal.whatToDo=2;
%     state.spc.acq.page = 0;
%     hObject = gh.spc.FLIMimage.grab;
%     handles = gh.spc.FLIMimage;
% 	FLIM_Measurement(hObject, handles);
% end
% %%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(gh.mainControls.shutterDelay, 'String', 0);
    genericCallback(gh.mainControls.shutterDelay);
    updateShutterDelay;

    set(gh.standardModeGUI.numberOfFrames, 'String', num2str(numberOfFrames_Pre));
    genericCallback(gh.standardModeGUI.numberOfFrames);
    state.acq.numberOfFrames=state.standardMode.numberOfFrames;
    updateGuiByGlobal('state.acq.numberOfFrames');
    preAllocateMemory;
    alterDAQ_NewNumberOfFrames;
    
    set(gh.standardModeGUI.averageFrames, 'Value', 1);
    genericCallback(gh.standardModeGUI.averageFrames);
    state.acq.averaging=state.standardMode.averaging;
    updateHeaderString('state.acq.averaging');
    preallocateMemory;
    
    set(gh.standardModeGUI.numberOfSlices, 'String', num2str(nSlices));
    genericCallback(gh.standardModeGUI.numberOfSlices);
    state.acq.numberOfZSlices=state.standardMode.numberOfZSlices;
    updateGuiByGlobal('state.acq.numberOfZSlices');
    preallocateMemory;

    set(gh.spc.FLIMimage.uncageEveryFrame, 'String', num2str(numberOfFrames_Pre));
    state.spc.acq.uncageEveryXFrame = numberOfFrames; 
    
elseif flag == 3
    

    %%%%
    if state.spc.acq.SPCdata.mode == 2
        state.spc.acq.SPCdata.trigger = 1;
        if FLIM_setupScanning(0)
            return;
        end
        state.internal.whatToDo=2;
        state.spc.acq.page = 0;
        hObject = gh.spc.FLIMimage.grab;
        handles = gh.spc.FLIMimage;
        FLIM_Measurement(hObject, handles);
    end
end
% pause(repeatPeriod - toc);
% tic;
% 
% for i=1:postAcqusition
%  
%     executeGrabOneCallback(gh.mainControls.grabOneButton);
%     pause(repeatPeriod - toc);
%     tic;
% end


