classdef ControlledAblationController < most.Controller
    %CONTROLLEDABLATIONCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = ControlledAblationController(hModel)
           obj = obj@most.Controller(hModel,{'controlledAblationGUI'});
            
           obj.ziniMainGUI();
        end    
        
        function ziniMainGUI(obj)
            set(obj.hGUIData.controlledAblationGUI.figure1,'Name','Controlled Ablation');            
            set(obj.hGUIData.controlledAblationGUI.pbAblate,'FontWeight','bold','FontSize',10,'BackgroundColor',[0 .8 0]);            
        end
        
    end
    
    %% HIDDEN METHODS
    methods (Hidden)
        function changedAblationActive(obj,~,~)
            hBtn = obj.hGUIData.controlledAblationGUI.pbAblate;
            if obj.hModel.ablationActive
                set(hBtn,'Enable','off','BackgroundColor',[.8 .8 .8]);
            else
                set(hBtn,'Enable','on','BackgroundColor',[0 .8 0]);
            end     
        end
        
    end
        
    
    
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.Controller)
    properties (SetAccess=protected)
        propBindings = zlclInitPropBindings();
    end
    
end

%% LOCAL FUNCTIONS

function s = zlclInitPropBindings()

s = struct();

s.mode = struct('GuiIDs',{{'controlledAblationGUI' 'pmAblationMode'}});

s.startPower = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.endPower = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.duration = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.pulseDuration = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.pulseInterval = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.ablationDoneThreshold = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.inputDataShow = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','logical'));
s.inputDataStore = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','logical'));

s.ablationActive = struct('Callback','changedAblationActive');

s.ablationDoneThreshold = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));

s.inputSampleRate = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.inputCheckRate = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.inputSampsToCheck = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.inputPreAblationTime = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));
s.inputPostAblationTime = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));



%s.ablationDoneCheckRate = struct('GuiIDs',{{'controlledAblationGUI','pcAblationProps'}},'PropControlData',struct('format','numeric'));

s.targetROI = struct('GuiIDs',{{'controlledAblationGUI' 'etROINumber'}});
s.targetROIZoom = struct('GuiIDs',{{'controlledAblationGUI' 'etROIZoom'}});
s.targetROINumLines = struct('GuiIDs',{{'controlledAblationGUI' 'etROINumLines'}});


end

