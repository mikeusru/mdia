function I = getLastAcqImage( channel,takeMax )
%getLastAcqImage pulls the latest image from memory
%   channel (optional) is af.params.channel by default
% takeMax(optional) indicates whether the max projection should be taken
% (default=0)



global af spc state

if nargin<1
    channel=af.params.channel;
end

if nargin<2
    takeMax=0;
end

try
if channel==af.params.flimChannelIndex %check if image should be FLIM image
    if takeMax
        I=spc.project;
    else
        I=reshape(sum(spc.imageMod, 1), spc.SPCdata.scan_size_y, spc.SPCdata.scan_size_x);
    end
else
    if takeMax
        I=state.acq.maxData{channel};
    else
        I=state.internal.tempImageSave{channel}(1:state.internal.storedLinesPerFrame,:);
    end
end
catch ME
    disp(ME.message);
    throw(ME);
end

end

