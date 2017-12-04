function [ x_shift,y_shift ] = driftCorrect( status,x,y,x1,y1 )
%driftCorrect is used when changing the XY position to put the spine in the
%center of the image. the inputs are status, indicating where the command
%came from, and the coordinates to use. x and y are the old spine
%coordinates and x1 and y1 are new. all coordinates are in pixels.
%status can be 'click','cycle',
global gh af state
pause on
if strcmp(status,'click')%if function was called by clicking in the AF GUI
    if length(state.hSI.positionDataStructure)==1 %if there is only one position
        [af.position.origin_abs,af.position.origin_rel]=motorGetPosition;
        % turn on focus
        if strcmp(get(gh.mainControls.focusButton,'String'),'FOCUS')
            mainControls('focusButton_Callback',gh.mainControls.focusButton);
        end
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
        [ x1, y1 ] = Locate_spines_func(I ,x, y );
        %         disp([af.position.origin_rel(1)+(x-x1)/af.drift.scale af.position.origin_rel(2)+(y-y1)/af.drift.scale af.position.origin_rel(3)]);
        motorSetPositionRelative([af.position.origin_rel(1)+(x-x1)/af.drift.scale af.position.origin_rel(2)+(y-y1)/af.drift.scale af.position.origin_rel(3)]);
        pause on
        pause(1)
        
        % turn off focus
        mainControls('focusButton_Callback',gh.mainControls.focusButton);
    elseif length(state.hSI.positionDataStructure)>1 %if there are multiple positions
        keys=cell2mat(state.hSI.positionDataStructure.keys());
        for i=keys
            if i>0 %make sure position is not at 0
                motorPositionGoto(i); %move to position
                % make sure focus is turned on. emulate focus button press.
                if strcmp(get(gh.mainControls.focusButton,'String'),'FOCUS')
                    mainControls('focusButton_Callback',gh.mainControls.focusButton);
                end
                figure(state.internal.GraphFigure(af.params.channel)); %bring figure to front
                % calculate new position and move to it
                x=af.positions{i}.closestspine.x;
                y=af.positions{i}.closestspine.y;
                pause(1); %pause to capture image
                if state.acq.averagingDisplay %check if can use average display
                    I=state.internal.tempImageDisplay{af.params.channel};
                else
                    I=state.acq.acquiredData{2}{af.params.channel};
                end
                % find nearest spine
                [ x1, y1 ] = Locate_spines_func( I,x,y );
                positionStruct=state.hSI.positionDataStructure(i);
                positionStruct.motorX=positionStruct.motorX+(x-x1)/af.drift.scale;
                positionStruct.motorY=positionStruct.motorY+(y-y1)/af.drift.scale;
                state.hSI.positionDataStructure(i)=positionStruct;    %update position table
                state.hSI.roiUpdatePositionTable();
                afStatus({'Pos ' num2str(i) ' x,y shifted [' num2str((x-x1)/af.drift.scale) ',' num2str((y-y1)/af.drift.scale) '] um'});
            end
            if i==keys(end) % return to first position and turn off focus drift correction is done
                motorPositionGoto(keys(2));
                pause(.2);
                mainControls('focusButton_Callback',gh.mainControls.focusButton);
            end
        end
        afStatus(' ');
    end
elseif strcmp(status,'cycle') || strcmp(status,'loop')
    % calculate shift in position based on difference in coordinates
    x_shift=(x-x1)/af.drift.scale;
    y_shift=(y-y1)/af.drift.scale;
end
    
end

