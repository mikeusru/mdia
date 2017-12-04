function exclusiveActionTimerFun
%exclusiveActionTimerFun completes one grab, triggers autofocus, and moves
%to the new position.
global gh state dia ua af

logActions;

if ~ua.UAmodeON %check if process has been aborted
    return
end

posID=ua.acq.currentPos;

if dia.init.useOnePos && dia.acq.refPosition==posID %set appropriate Z scan parameters if reference position is scanned
    state.acq.numberOfZSlices=af.params.scancount;
    state.acq.zStepSize=af.params.zstep;
    set(gh.motorControls.etNumberOfZSlices,'String',num2str(state.acq.numberOfZSlices));
elseif dia.init.useOnePos && dia.acq.refPosition~=posID %otherwise set regular Z scanning parameters
    state.acq.numberOfZSlices=dia.acq.numberOfZSlices;
    state.acq.zStepSize=dia.acq.zStepSize;
    set(gh.motorControls.etNumberOfZSlices,'String',num2str(state.acq.numberOfZSlices));
end

if strcmp(get(gh.mainControls.grabOneButton,'String'),'GRAB')
    grabAndWait;
    for k=1:length(ua.positions)
        if ua.positions(k).posnID==ua.acq.currentPos
            af.closestspine.x1=ua.positions(k).roiPosition(1);
            af.closestspine.y1=ua.positions(k).roiPosition(2);
            break
        end
    end
    if ~ua.UAmodeON %check if process has been aborted
        return
    end
    runDriftCorrect; %run autofocus and drift correct and append the FOV position struct. 
end

%update position after running autofocus
setScanAngleROI(ua.acq.currentPos,0);

setupAOData; %reset scanning shift
end

