function yphys_roiDelete;
global spc
global gh ua

roiN = str2num(get(gco, 'Tag'));
pa = findobj('Tag', num2str(roiN));
if size(pa) > 0
	for j = 1:size(pa)
        delete(pa(j));
    end
end
% 
% if isfield(ua,'positions') % MISHA - 030515 - delete ROI in UA positions list
%     for i=1:length(ua.positions)
%         if ua.positions(i).roiNum==roiN
%             ua.positions(i)=[];
%         end
%     end
% end

% gh.yphys.figure.yphys_roi(roiN) = [];
% gh.yphys.figure.yphys_roiText(roiN) = [];