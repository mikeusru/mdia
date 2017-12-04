function xyCoords = yphys_makeMapCoordinate(mapDim);

xyCoords = zeros(mapDim ^ 2, 2);

L = mapDim^2;
% rAx = rand(L, 1);
% [a, rAx] = sort(rAx);
rAx = randperm(L);
NN = reshape(rAx, mapDim, mapDim);

for x=1:mapDim
    for y = 1:mapDim
        xyCoords(NN(x, y), 1) = x;
        xyCoords(NN(x, y), 2) = y;
    end
end


%figure; imagesc(NN);

% k = 1;
% n = mapDim / 2;
% for i = 1 : n
%     for j = 1 : n
%         %This order is important to give some time in the beginning
%         %to collect a baseline, and time at the end, to allow for the final
%         %decay to occur.
%         xyCoords(k, 1) = i + n;
%         xyCoords(k, 2) = j + n;
%         
%         xyCoords(k + 1, 1) = i;
%         xyCoords(k + 1, 2) = j;
%         
%         xyCoords(k + 2, 1) = i;
%         xyCoords(k + 2, 2) = j + n;
%         
%         xyCoords(k + 3, 1) = i + n;
%         xyCoords(k + 3, 2) = j;
%         
%         k = k + 4;
%     end
% end
% xyCoords = xyCoords;


% 
