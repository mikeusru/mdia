function execute_AF_Callback( command )
%execute_AF_Callback Is the callback function for the autofocus procedure.
%it runs one instance of the autofocus. It can also be called from run_AF
%when UA is running.

global af state gh ua

if nargin<1
    command='test';
end

channel=af.params.channel;

pause on
%% 1. make sure focus is turned on. emulate focus button press.

%% clear previous values
af.focusvalue=[];
af.images=[];
af.position=[];
if isfield(ua,'zoomscale')
    zoomscale=ua.zoomscale;
end
imsize=size(state.acq.acquiredData{2}{af.params.channel});
if strcmp(command,'beforeUA') && ua.zoomedOut % use center of image when image is zoomed out
    rw=imsize(1)/(zoomscale/2);
    rh=imsize(2)/(zoomscale/2);
    afRoi=round([imsize(1)/2-rw/2, imsize(2)/2-rh/2, rw, rh]);
else
    afRoi=[af.closestspine.x1-af.roisize/2,af.closestspine.y1-af.roisize/2,af.roisize,af.roisize];
end
% get current position
[af.position.origin_abs,af.position.origin_rel]=motorGetPosition;
% create list of positions to do autofocus in
af.position.af_list_abs_z=linspace((af.position.origin_abs(3)-(af.params.zrange/2)),(af.position.origin_abs(3)+(af.params.zrange/2)),af.params.scancount);
%% 2. run loop where z is moved from lowest to highest position, recording
% each image
motorOrETLMove([af.position.origin_abs(1) af.position.origin_abs(2) af.position.af_list_abs_z(1)]);

% if strcmp(get(gh.mainControls.focusButton,'String'),'FOCUS')
%     mainControls('focusButton_Callback',gh.mainControls.focusButton);
% end

for i=1:af.params.scancount
    I= updateCurrentImage(channel);

%     pause(1);
%     mainControls('focusButton_Callback',gh.mainControls.focusButton);
    
    
    % now read the image to the struct
%     if state.acq.averagingDisplay
%         af.images(i).image=state.internal.tempImageDisplay{af.params.channel};
%     else
%         af.images(i).image=state.acq.acquiredData{2}{af.params.channel};
%     end
    af.images(i).image=I;
    % %run autofocus on image. change ROI size later, maybe based on image
    % size.
    af.focusvalue(i)=fmeasure(I,af.algorithm.operator,afRoi);
    % move to next position
    if i<af.params.scancount
        motorOrETLMove([af.position.origin_abs(1) af.position.origin_abs(2) af.position.af_list_abs_z(i+1)]);
    end
    % turn on focus
%     if i<af.params.scancount
%         mainControls('focusButton_Callback',gh.mainControls.focusButton);
%     end
end
%% 3. run autofocus on all images. figure out which one is most in focus.
af.bestfocus=find(af.focusvalue==max(af.focusvalue),1);
%% 4. move to that position and verify the coordinates
motorOrETLMove([af.position.origin_abs(1) af.position.origin_abs(2) af.position.af_list_abs_z(af.bestfocus)],'verify');
%% 5. turn on focus
% pause(1);
% mainControls('focusButton_Callback',gh.mainControls.focusButton);
% pause(1);
%turn off focus
% mainControls('focusButton_Callback',gh.mainControls.focusButton);
%display images
displayAFimages(command);
end
