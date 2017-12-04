function hAbl = controlledAblation( varargin )

hAbl = ControlledAblationModel(varargin{:});
assignin('base','hAbl',hAbl);

hAblCtl = ControlledAblationController(hAbl);

hAbl.initialize();


end

