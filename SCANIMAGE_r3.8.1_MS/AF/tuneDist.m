function tuneDist()
%tuneDist allows the user to visually tune the micron vs pixel scale so a
%drift correction can later be used.


global state af gh dia

% get current position
[af.position.origin_abs,af.position.origin_rel]=motorGetPosition;

for i=1:5
    % make sure focus is turned on. emulate focus button press.
    if strcmp(get(gh.mainControls.focusButton,'String'),'FOCUS')
        mainControls('focusButton_Callback',gh.mainControls.focusButton);
    end
    figure(state.internal.GraphFigure(af.params.channel));
    [x(i) y(i)]=ginput(1); %get clicked input from user
    afStatus('Moving motor...');
    if i==1
        motorSetPositionRelative([af.position.origin_rel(1)+af.drift.tuneshift af.position.origin_rel(2) af.position.origin_rel(3)]);
    elseif i==2
        avg_dist(1)=abs(x(1)-x(2));
        motorSetPositionRelative([af.position.origin_rel(1) af.position.origin_rel(2)+af.drift.tuneshift af.position.origin_rel(3)]);
    elseif i==3
        avg_dist(2)=abs(y(1)-y(3));
        motorSetPositionRelative([af.position.origin_rel(1)-af.drift.tuneshift af.position.origin_rel(2) af.position.origin_rel(3)]);
    elseif i==4
        avg_dist(3)=abs(x(1)-x(4));
        motorSetPositionRelative([af.position.origin_rel(1) af.position.origin_rel(2)-af.drift.tuneshift af.position.origin_rel(3)]);
    elseif i==5
        avg_dist(4)=abs(y(1)-y(5));
    end
    if i<5
        afStatus('Click on Shifted Position');
    end
    
end
%display status with measured distances
afStatus({'Measured Distances=' num2str(avg_dist)});

%record and display scale
af.drift.scale=mean(avg_dist)/af.drift.tuneshift;
set(dia.handles.mdia.tuneDistEdit,'String',af.drift.scale);

%turn off focus
mainControls('focusButton_Callback',gh.mainControls.focusButton);
end

