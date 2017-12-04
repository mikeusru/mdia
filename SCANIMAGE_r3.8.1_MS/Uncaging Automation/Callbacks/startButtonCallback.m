function [  ] = startButtonCallback(  )
%startButtonCallback is the callback function the start button press in
%UA.fig (the uncaging automation window).

global ua state gh dia af

if ~isfield(ua.params,'zRoof') || isempty(ua.params.zRoof)
    msgbox('ERROR: select a Z roof value first (for dwell calculation)');
    return
end

if ~ua.params.fovModeOn
    disp('warning - FOV mode is required, since regular automated mode is outdated');
%     choice=questdlg('Are you sure you want to start in non-FOV mode? The software has not been optimized for this action','Confirm Non-FOV mode','OK','Cancel','Cancel');
%     if strcmp(choice,'Cancel')
        return
%     end
end

dia.acq.allowTimerStart=true;
    
%save specimen Info
saveSpecimenInfo;

%make sure positions are sorted by Z
% sortUApositionsByZ;

%change button to 'Abort'
set(dia.handles.mdia.startPushbutton, 'String', 'ABORT', 'FontWeight', 'bold', 'ForegroundColor', 'red');

ua.UAmodeON=true;
% ua.startclock=clock; %record initial time


if (ua.drift.driftON || af.drift.on)
    if isempty(find(dia.hPos.allPositionsDS.hasRef,1))
        disp('Error - Need Reference Images for All Positions');
        UA_Abort;
        return
    end
end

posns=dia.hPos.allPositionsDS.posID;
% nposns=length(posns); %identify number of positions

%prepare timers
dia.hPos.setWorkingPositions(1);
dia.hPos.makeImagingTimers;

dia.originalSavePath = state.files.savePath;
dia.hPos.createFolders(); %create folders

%save ref images
refPath=[state.files.savePath, '\refImage'];
for i = posns'
    refImg = dia.hPos.allPositionsDS.refImg{dia.hPos.allPositionsDS.posID==i,1};
    fname=[refPath,'_Pos',num2str(i),'.tif'];
    imwrite(uint16(refImg),fname,'tif','WriteMode','overwrite');
    refImgZoomOut = dia.hPos.allPositionsDS.refImgZoomOut{dia.hPos.allPositionsDS.posID==i,1};
    fname=[refPath,'ZoomOut_Pos',num2str(i),'.tif'];
    imwrite(uint16(refImgZoomOut),fname,'tif','WriteMode','overwrite');
end
% ua.uniquePosns=posns;


% set current position and position index to first position
ua.acq.currentPos=posns(1);
ua.acq.currentPosInd=1;

%back up original save path
ua.originalSavepath=state.files.savePath;
% set savepath for first position
% state.files.savePath=ua.filestruct(1).savepath;
% updateFullFileName;
ua.zoomedOut=false;

% send command to begin uncaging and imaging cycle
if ua.params.fovModeOn
    dia.hPos.workingFOV=min(dia.hPos.allPositionsDS.FOVnum);
    ua.fov.acq.preUncage=false;
    ua.fov.acq.initialImaging=false;
    ua.fov.acq.Uncage=false;
    ua.fov.acq.postUncage=false;
    startFOVua;
else
    disp('warning - FOV mode is required, since regular automated mode is outdated');
    return
%     startUA;
end

end

