function [ x_shift,y_shift ] = centerSpines( status,x,y,x1,y1 )
%centerSpines is used when changing the XY position to put the spine in the
%center of the image. the inputs are status, indicating where the command
%came from, and the coordinates to use. x and y are the old spine
%coordinates and x1 and y1 are new. all coordinates are in pixels.
%status can be 'click','cycle',
global gh af state

if strcmp(status,'click') %if function was called by clicking in the AF GUI
    [af.position.origin_abs,af.position.origin_rel]=motorGetPosition;
    % turn on focus
    if strcmp(get(gh.mainControls.focusButton,'String'),'FOCUS')
        mainControls('focusButton_Callback',gh.mainControls.focusButton);
    end
    pause on
    pause(1);
    if state.acq.averagingDisplay %check if can use average display
        I=state.internal.tempImageDisplay{af.params.channel};
    else
        I=state.acq.acquiredData{2}{af.params.channel};
    end
    % select figure
    figure(state.internal.GraphFigure(af.params.channel));
    % calculate new position and move to it
    x=af.closestspine.x1;
    y=af.closestspine.y1;
    [ x1, y1 ] = Locate_spines_func(I ,af.closestspine.x1, af.closestspine.y1 );
    disp([af.position.origin_rel(1)+(x-x1)/af.drift.scale af.position.origin_rel(2)+(y-y1)/af.drift.scale af.position.origin_rel(3)]);
    motorSetPositionRelative([af.position.origin_rel(1)+(x-x1)/af.drift.scale af.position.origin_rel(2)+(y-y1)/af.drift.scale af.position.origin_rel(3)]);
    pause on
    pause(1)
    
    % turn off focus
    mainControls('focusButton_Callback',gh.mainControls.focusButton);
elseif strcmp(status,'cycle') || strcmp(status,'loop')
    % calculate shift in position based on difference in coordinates
    x_shift=(x-x1)/af.drift.scale;
    y_shift=(y-y1)/af.drift.scale;
end
    
end

