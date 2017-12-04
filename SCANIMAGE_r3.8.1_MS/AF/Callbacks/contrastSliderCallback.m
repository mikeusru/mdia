function [ output_args ] = contrastSliderCallback()
%contrastSliderCallback is the callback function to the constrast slider
%used to set the contrast of the dendrite for spine localization

global state af ua

try
    if ua.drift.useMaxProjection
        channel=af.params.channel;
        I = getLastAcqImage( channel,1 );
    elseif ~isempty(state.acq.acquiredData{1}{af.params.channel})
        I=state.acq.acquiredData{1}{af.params.channel};
        af.handles.warningText.String='';
    else
        disp('ERROR RETRIEVING IMAGE FOR THRESHOLD SLIDER BOX');
        return
    end
catch ME
    disp('ERROR RETRIEVING IMAGE FOR THRESHOLD SLIDER BOX');
    disp(ME.message);
    return
end

BW2=findPerim(I);

Iout=I;
Iout(BW2==1)=max(max(Iout))+max(max(Iout))*.1;

%% display image
axes(af.handles.axes1)
imagesc(Iout,'Parent',af.handles.axes1);
colormap(af.handles.axes1,gray);
axis off
% disp(get(af.handles.slider,'Value'));

end

