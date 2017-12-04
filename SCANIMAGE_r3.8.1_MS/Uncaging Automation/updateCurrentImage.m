function [ I ] = updateCurrentImage( channel,acqMode,saveGrab )
%[ I ] = updateCurrentImage( channel,acqMode ) turns the focus on for 1 second to
%update the current image display and outputs the image it collected. The
%input is the channel which to collect the image from.
%
%acqMode is an optional parameter signifying whether the image should be takes
%as one frame (1), or as a max projection from a grab (2)
%
% saveGrab (optional) is a boolean indicating whether the grab (acqMode==2)
% should be saved. if it off by default.

global gh state af spc

logActions;

if nargin<3
    saveGrab=false;
end

if nargin<2
    acqMode=1;
    saveGrab=false;
end

if acqMode==1
    %turn off FLIM if it's on
    if state.spc.acq.spc_takeFLIM
        flimOn=1;
        set(gh.spc.FLIMimage.flimcheck,'Value',0);
        FLIMimage('flimcheck_Callback',gh.spc.FLIMimage.flimcheck);
    else
        flimOn=0;
    end
    if channel==af.params.flimChannelIndex
        disp('Warning: Channel set to FLIM. Single Frame Aquisition does not work with FLIM imaging. Setting channel to #1');
        channel=1;
    end
    %turn on focus if it's off
    if strcmp(get(gh.mainControls.focusButton,'String'),'FOCUS')
        mainControls('focusButton_Callback',gh.mainControls.focusButton);
    end
    
    % aquire a single frame from
    
    af.oneFrameAcq=getSingleImgAFUA;
    af.oneFrameAcq.channel=channel;
    af.oneFrameAcq.getSingleFrame;
    
    % resume function when focus is turned off.
    try
        waitfor(gh.mainControls.focusButton,'String','FOCUS');
    catch ME
        disp('Warning - frame may not have been acquired correctly since mainControls focus button cannot be read');
        disp(ME.message);
    end
    
    I=af.oneFrameAcq.latestFrame;
    
    if flimOn %turn FLIM back on if necessary
        set(gh.spc.FLIMimage.flimcheck,'Value',1);
        FLIMimage('flimcheck_Callback',gh.spc.FLIMimage.flimcheck);
    end
    
elseif acqMode==2
    %turn off focus if it's on
    if strcmp(get(gh.mainControls.focusButton,'String'),'ABORT')
        mainControls('focusButton_Callback',gh.mainControls.focusButton);
    end
    oldSaveMode=state.files.autoSave;
    if saveGrab
        state.files.autoSave=1;
    else
        state.files.autoSave=0;
    end
    if strcmp(get(gh.mainControls.grabOneButton,'String'),'GRAB')
        grabAndWait;
    end
    I = getLastAcqImage( channel, 1 );
    state.files.autoSave=oldSaveMode;
end

end

