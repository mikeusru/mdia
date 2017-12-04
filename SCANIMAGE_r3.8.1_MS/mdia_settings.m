function mdia_settings
%% Change the variable values in this function to match your system parameters;
global ua dia

%% GUI properties
dia.guiStuff.arrangeFigs=1; %tile all figures after initially loading scanimage

%% FOV properties
%these shouldn't change as long as you're using the same objective
ua.fov.fovwidth = 245; %Width, in microns, of entire Field of View (zoom=1)
ua.fov.fovheight = 285; %Height, in microns, of entire Field of View (zoom=1).

%% ETL properties
dia.init.etl.etlOn=0; %is there an ETL in the system?
    dia.init.etl.boardIndex='Dev2'; %name of output DAQ board. Must be same as pockels cell board.
    dia.init.etl.channel=7; %output channel on DAQ board
    dia.init.etl.voltageRange=5; %voltage range is negative this value to this value
    
%% MP285 Hard Rest Signal Properties
dia.init.mp285reset.resetOn=0; %is there a reset hookup in the system?
    dia.init.mp285reset.boardIndex='Dev2'; %name of output DAQ board
    dia.init.mp285reset.channel=4; %output channel on DAQ board
    dia.init.mp285reset.voltageRange=10; %voltage range is negative this value to this value

%% Alpha Testing Settings (these should be set to 0)
dia.acq.doRibbonTransform = 0;
dia.acq.do3DRibbonTransform = 0;
dia.etl.acq.doMirrorTransform = 0;
