function changeOrRevertAcquisitionValues( temporary, varargin )
%changeOrRevertAcquisitionValues is used to set temporary or permanent
%values to certain variables in scanimage which require changes in guis,
%etc...
%
% temporary - logical variable indicating whether old values should be
% saved.
%
% Note: for reverting to old value, use [] for value in name-value pair
% name-value pairs:
% 'savePath', string representing savepath
% 'baseName', string representing base filename
% 'fileCounter', int
% 'numberOfZSlices', integer
% 'pixelsPerLine', int
% 'linesPerFrame', int
% 'scanShiftFast', double
% 'scanShiftSlow', double
% 'scanRotation', double
global state gh
persistent savePath baseName numberOfZSlices pixelsPerLine linesPerFrame...
    scanShiftFast scanShiftSlow scanRotation fileCounter

%flags for what to update after setting values
FLAGupdateFullFileName = false;
FLAGsetScanProps = false;
FLAGapplyConfigurationSettings = false;

nVargs = length(varargin);
for k = 1:2:nVargs
    switch varargin{k}
        case 'savePath'
            if temporary
                savePath = state.files.savePath;
            end
            if ~isempty(varargin{k+1})
                val = varargin{k+1};
            else val = savePath;
            end
            state.files.savePath = val;
            FLAGupdateFullFileName = true;
        case 'baseName'
            if temporary
                baseName = state.files.baseName;
            end
            if ~isempty(varargin{k+1})
                val = varargin{k+1};
            else val = baseName;
            end
            state.files.baseName = val;
            FLAGupdateFullFileName = true;
        case 'numberOfZSlices'
            if temporary
                numberOfZSlices = state.acq.numberOfZSlices;
            end
            if ~isempty(varargin{k+1})
                val = varargin{k+1};
            else val = numberOfZSlices;
            end
            state.acq.numberOfZSlices = val;
            set(gh.motorControls.etNumberOfZSlices,'String',num2str(state.acq.numberOfZSlices));
            motorControls('etNumberOfZSlices_Callback',gh.motorControls.etNumberOfZSlices);
        case 'pixelsPerLine'
            if temporary
                pixelsPerLine = state.acq.pixelsPerLine;
            end
            if ~isempty(varargin{k+1})
                val = varargin{k+1};
            else val = pixelsPerLine;
            end
            state.acq.pixelsPerLine = val;
            FLAGapplyConfigurationSettings = true;
        case 'linesPerFrame'
            if temporary
                linesPerFrame = state.acq.linesPerFrame;
            end
            if ~isempty(varargin{k+1})
                val = varargin{k+1};
            else val = linesPerFrame;
            end
            state.acq.linesPerFrame = val;
            FLAGapplyConfigurationSettings = true;
        case 'scanShiftFast'
            if temporary
                scanShiftFast = state.acq.scanShiftFast;
            end
            if ~isempty(varargin{k+1})
                val = varargin{k+1};
            else val = scanShiftFast;
            end
            state.acq.scanShiftFast = val;
            updateGUIByGlobal('state.acq.scanShiftFast');
            FLAGsetScanProps = true;
        case 'scanShiftSlow'
            if temporary
                scanShiftSlow = state.acq.scanShiftSlow;
            end
            if ~isempty(varargin{k+1})
                val = varargin{k+1};
            else val = scanShiftSlow;
            end
            state.acq.scanShiftSlow = val;
            updateGUIByGlobal('state.acq.scanShiftSlow');
            FLAGsetScanProps = true;
        case 'scanRotation'
            if temporary
                scanRotation = state.acq.scanRotation;
            end
            if ~isempty(varargin{k+1})
                val = varargin{k+1};
            else val = scanRotation;
            end
            state.acq.scanRotation = val;
            updateGUIByGlobal('state.acq.scanRotation');
            FLAGsetScanProps = true;
        case 'fileCounter'
            if temporary
                fileCounter = state.files.fileCounter;
            end
            if ~isempty(varargin{k+1})
                val = varargin{k+1};
            else val = fileCounter;
            end
            state.files.fileCounter = val;
            FLAGupdateFullFileName = true;
    end
end

if FLAGupdateFullFileName
    updateFullFileName;
end

if FLAGsetScanProps
    setScanProps;
end

if FLAGapplyConfigurationSettings
    applyConfigurationSettings;
end




