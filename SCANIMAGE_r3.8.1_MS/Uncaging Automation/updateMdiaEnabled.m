function updateMdiaEnabled
%updateMdiaEnabled updates which GUI parameters are enabled/disabled based
global af ua dia

acqaf=af.params.useAcqForAF;
singleMode=strcmp(af.params.mode,'singleMode');
afon=af.params.isAFon;

%enable/disable autofocus parameters
if afon
    set(findall(dia.handles.mdia.afParamsPanel,'-property','enable'),'Enable','on');
    set(findall(dia.handles.mdia.afActionsPanel,'-property','enable'),'Enable','on');
    if acqaf && singleMode
        set(dia.handles.mdia.runFrequencyEdit,'Enable','off');
        set(dia.handles.mdia.zrangeEdit,'Enable','off');
        set(dia.handles.mdia.zstepEdit,'Enable','off');
    elseif acqaf && ~singleMode
        set(dia.handles.mdia.runFrequencyEdit,'Enable','off');
        set(dia.handles.mdia.zrangeEdit,'Enable','on');
        set(dia.handles.mdia.zstepEdit,'Enable','on');
        set(dia.handles.mdia.setSpinePushbutton,'Enable','off');
        set(dia.handles.mdia.acquiredForAutofocusCheckbox,'Enable','off');
    elseif ~acqaf && ~singleMode % force use of acquired for autofocus when multiple positions are selected
        set(dia.handles.mdia.setSpinePushbutton,'Enable','off');
        set(dia.handles.mdia.acquiredForAutofocusCheckbox,'Value',1);
        af.params.useAcqForAF=true;
        set(dia.handles.mdia.acquiredForAutofocusCheckbox,'Enable','off');
    else
        set(dia.handles.mdia.runFrequencyEdit,'Enable','on');
        set(dia.handles.mdia.zrangeEdit,'Enable','on');
        set(dia.handles.mdia.zstepEdit,'Enable','on');
    end
else
    set(findall(dia.handles.mdia.afParamsPanel,'-property','enable'),'Enable','off');
    set(findall(dia.handles.mdia.afActionsPanel,'-property','enable'),'Enable','off');
end
end

