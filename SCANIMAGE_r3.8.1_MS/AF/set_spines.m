function set_spines( positions )
%set_spines is the callback function to the AF GUI's Set Spine and
%Set Spine for All Saved Positions function

%   the 'positions' input is a boolean. it is true for multiple positions.

% set positions to false if no input
if nargin < 1 || isempty(positions)
    positions = false;
end

global state gh af

af.clicked=[];

if ~positions
    
    figure(state.internal.GraphFigure(af.params.channel));
    [af.clicked.x,af.clicked.y]=ginput(1); %take input from one click to establish point of important dendrite
    af.clicked.x=round(af.clicked.x); %round coordinates to whole numbers
    af.clicked.y=round(af.clicked.y);
    % establish the image of interest
    %I=state.internal.tempImageDisplay{1};
    if state.acq.averagingDisplay %check if can use average display
        I=state.internal.tempImageDisplay{af.params.channel};
    else
        I=state.acq.acquiredData{2}{af.params.channel};
    end
    % if that doesn't work, look into
    % get(state.internal.imagehandle(channelCounter), 'CData')
    %% run Locate_spines_func to get nearest spine to clicked coordinate
    [ af.closestspine.x1, af.closestspine.y1 ] = Locate_spines_func( I,af.clicked.x,af.clicked.y );
    
else % if doing multiple positions
    keys=cell2mat(state.hSI.positionDataStructure.keys());
    for i=keys
        if i>0 %make sure position is not at 0
            motorPositionGoto(i); %move to position
            % make sure focus is turned on. emulate focus button press.
            if strcmp(get(gh.mainControls.focusButton,'String'),'FOCUS')
                mainControls('focusButton_Callback',gh.mainControls.focusButton);
            end
            figure(state.internal.GraphFigure(af.params.channel)); %bring figure to front
            [af.positions{i}.clicked]=ginput(1);
            if state.acq.averagingDisplay %check if can use average display
                I=state.internal.tempImageDisplay{af.params.channel};
            else
                I=state.acq.acquiredData{2}{af.params.channel};
            end
            %% run Locate_spines_func to get nearest spine to clicked coordinate
            [ af.positions{i}.closestspine.x, af.positions{i}.closestspine.y ] = Locate_spines_func( I,af.positions{i}.clicked(1),af.positions{i}.clicked(2) );
        end
        if i==keys(end) % return to first position and turn off focus when setting spines is done
            motorPositionGoto(keys(2));
            pause on
            pause(.2);
            mainControls('focusButton_Callback',gh.mainControls.focusButton);
        end
    end
end

