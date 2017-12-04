%% This is unnecessary with hPos, especially since there's only one position per ROI

function  posns = getUniqueUApositions
%This is a replacement for the redundant ua.fov.uniqueMotorPosns. I wish i
%knew object oriented programming when starting this... would have been way
%easier.
global ua

ps=zeros(1,length(ua.positions));

for i=1:length(ua.positions) % get all positions
    ps(i)=ua.positions(i).posnID;
end
posns=unique(ps,'stable'); %identify unique positions

end

