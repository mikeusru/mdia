function setWindowPositions( hInfo )
%setWindowPositions( hInfo ) sets window positions based on input info
%   hInfo is a struct holding the necessary window info
%hInfo has the fields windowNames, windowUnits, and allPositions


for i=1:length(hInfo.windowNames)
        h=findall(0,'Name',hInfo.windowNames{i});
        if ~isempty(h)
            set(h,'Units',hInfo.windowUnits{i});
            set(h,'OuterPosition',hInfo.allPositions{i});
        end
end

end

