function [  ] = UA_Drift_AddImage(  )
%UA_Drift_AddImage adds an image to the drift correction reference table

%This function does some reduntant stuff for now to avoid bugs... fix it
%later to save space
global ua state gh dia

%% figure out current position
if ~ua.params.fovModeOn
    xyzPos = dia.hPos.getMotorAndEtlPosition();
    posID=state.hSI.zprvPosn2PositionID(xyPos); %compare current coordinates to find closest position.
    if posID==0 %if position does not exist, display error
        disp('Error - Current Coordinates do not match any saved positions');
        return
    end
else
    posID=ua.drift.selectedPosID;
end

%add ref image to image struct
dia.hRef.addRefImg(posID);
% addRefImg( posnID );

I=dia.hPos.allPositionsDS.refImg{hPos.allPositionsDS.posID==posID};

% ua.drift.T.Img{ua.drift.T.PosID==posnID}=I;

%% set 1st image to axes
axes(ua.drift.handles.axes1);
colormap(gray);
imagesc(I);
axis off

%% set ROIs to axes
UA_Drift_RoiDisp(posID);

%% zoom out and save zoomed out image
if ua.drift.zoomOutDrift
    
    I2=dia.hPos.allPositionsDS.refImgZoomOut{hPos.allPositionsDS.posID==posID};
%     ua.drift.T.Img_zoomout{ua.drift.T.PosID==posnID}=I2;
        
    %% set 2nd image to axes
    axes(ua.drift.handles.axes2);
    colormap(gray);
    imagesc(I2);
    axis off
end

%% update GUI
updateUAgui;


end

