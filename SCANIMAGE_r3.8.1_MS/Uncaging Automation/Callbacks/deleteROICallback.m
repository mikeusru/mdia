function [ ] = deleteROICallback( )
%deleteROICallback runs when the 'delete ROI' button is hit.
global ua fov dia

posID=ua.SelectedPosition;
dia.hPos.deletePosition(posID);
% 
% i=1;
% while i<=length(ua.positions)
%     if posID==ua.positions(i).posnID
%         ua.positions(i)=[];
%     else i=i+1;
%     end
% end
% 
% %delete from FOV struct
% if isfield(ua,'fov') && isfield(ua.fov,'FOVposStruct')
%     for i=1:length(ua.fov.FOVposStruct)
%         ind=ua.fov.FOVposStruct(i).scanInfoDataset.oldMotorPosition==posID;
%         ua.fov.FOVposStruct(i).scanInfoDataset(ind,:)=[];
%         ind=ua.fov.FOVposStruct(i).includedMotorPosns==posID;
%         ua.fov.FOVposStruct(i).includedMotorPosns(ind)=[];
% 
%         ua.fov.FOVposStruct(i).motorZ_list(ind)=[];
%     end
% end

updateUAgui;

end
