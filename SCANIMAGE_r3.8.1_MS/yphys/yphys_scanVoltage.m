function    [XYvol, error] = yphys_scanVoltage(roiN, rotateAndScale)
global gh;
global state;
global ua;
error = 0;
Correction_factor = 0.04;

if nargin <= 1
    rotateAndScale = 1;
end

%Scanoffset = [-0.004, -0.002];
%Scanoffset = [-0.004, -0.005];

%Scanoffset = state.yphys.acq.scanoffset;
%roiN = 1;
if length(gh.yphys.figure.yphys_roi) >= roiN
	if ~isempty(gh.yphys.figure.yphys_roi(roiN)) && ishandle(gh.yphys.figure.yphys_roi(roiN))
        
         %im_size = size(get(state.internal.imagehandle(2), 'CData'))
         %try
             im_size = [state.acq.pixelsPerLine, state.acq.linesPerFrame];
             roi_pos = get(gh.yphys.figure.yphys_roi(roiN), 'Position');
             roi_pos([1, 3]) = roi_pos([1, 3]) / im_size(1);
             roi_pos([2, 4]) = roi_pos([2, 4]) / im_size(2);
             XYvol(1) = roi_pos(1) + 0.5*roi_pos(3);
             XYvol(2) = roi_pos(2) + 0.5*roi_pos(4);
             
             if XYvol(1) > 1 || XYvol(1) < 0 || XYvol(2) > 1 || XYvol(2) < 0
                 error = 2;
             end
             %XYvol(1) = (state.init.eom.powerBoxNormCoords(uncageP, 1)+0.5*state.init.eom.powerBoxNormCoords(uncageP, 3));
             %XYvol(2) = (state.init.eom.powerBoxNormCoords(uncageP, 2)+0.5*state.init.eom.powerBoxNormCoords(uncageP, 4));

             state.yphys.acq.XYorg = XYvol;

             %If Zoom > 30;
             XYvol(1) = XYvol(1) + Correction_factor;
             %XYvol(1) = (state.acq.fillFraction)*XYvol(1) + state.acq.lineDelay*1.3;
             XYvol(1) = 2*(XYvol(1)-0.5)* state.internal.scanAmplitudeFast;%For now X is fast axes...
             XYvol(2) = 2*(XYvol(2)-0.5)* state.internal.scanAmplitudeSlow;
             %XYvol = (1/state.acq.zoomFactor*XYvol);
         %catch
%              error = 1;
%              XYvol  = [0,0];
%          end
              
    else%
         %beep;
%          if ~(isfield(ua,'UAmodeON') && ua.UAmodeON)
         disp('Error: choose ROI !');
%          end
         error = 1;
         XYvol = [0,0];
	end
	%XYvol = rotateAndShiftMirrorData(XYvol)+Scanoffset;
    if rotateAndScale
        XYvol = yphys_linTransformMirrorData(XYvol);
    end
    XYvol = XYvol + state.yphys.acq.scanoffset;

else
    XYvol = [0, 0];
    error = 1;
end

   