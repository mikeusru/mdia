function setAFforcycling()
% setAFforcycling makes sure everything is ready for autofocusing with
% cycle mode and initializes the necessary values
%   
global state af

% transfer clicked position coordinates from position structure to cycle
% structure. this step is necessary because not all positions may be loaded
% into the cycle table
if af.params.isAFon
    af.cycle=struct; % clear af cycle struct
    for i=1:length(state.cycle.cycleTableStruct)
        af.cycle(i).closestspine=af.positions{str2double(state.cycle.cycleTableStruct(i).motorActionID)}.closestspine;
    end
end
end

