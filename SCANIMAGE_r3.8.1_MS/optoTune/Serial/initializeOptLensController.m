function initializeOptLensController
%initializeOptLensController performs the required tasks to initialize the
%optotune lens controller.

global dia

try
dia.hOL=optLensClass;
dia.hOL.initialize;
dia.hOL.setDCmode;
dia.hOL.setCurrent(0);
catch err
    disp(err.message);
    disp('Optotune Lens Controller Initialization Failed');
    return
end

%start GUI for optotune lens
optLensGui;

end

