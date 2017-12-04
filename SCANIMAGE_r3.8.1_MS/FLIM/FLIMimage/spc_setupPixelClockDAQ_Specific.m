%function spc_setupPixelClockDAQ_Specific(state_val);
function spc_setupPixelClockDAQ_Specific
global state;


if state.spc.init.spc_on == 1
        %Specific Settings

        %if  state.spc.acq.uncageBox && state.spc.acq.uncageEveryXFrame > 1 && state.init.pockelsOn
        if  state.spc.acq.uncageBox == 1 && state.init.pockelsOn
		    spc_nRepeat = 0;
        else
            spc_nRepeat = state.acq.numberOfFrames-1;
        end
        
        if state.spc.acq.spc_average == 0
                spc_nRepeat = 0;
        end
        
        sampleSize = state.acq.numberOfFrames*state.acq.msPerLine*state.acq.linesPerFrame*state.acq.outputRate;
        sampleSizeF = state.acq.msPerLine*state.acq.linesPerFrame*state.acq.outputRate;
        
        set(state.spc.init.spc_ao, 'RepeatOutput', spc_nRepeat);
        set(state.spc.init.spc_ao, 'SamplesOutputFcnCount', sampleSize*(spc_nRepeat+1));
        set(state.spc.init.spc_ao, 'SampleRate', state.acq.outputRate);
        
        set(state.spc.init.pockels_ao, 'RepeatOutput', spc_nRepeat);
        set(state.spc.init.pockels_ao, 'SampleRate', state.acq.outputRate);

        %
        set(state.spc.init.spc_aoF, 'RepeatOutput', (state.internal.numberOfFocusFrames-1)); 
        set(state.spc.init.spc_aoF, 'SampleRate', state.acq.outputRate);

        set(state.spc.init.spc_ao, 'SamplesOutputFcnCount', sampleSize*(spc_nRepeat+1));
%         if state.spc.acq.spc_image        
            set(state.spc.init.spc_ao, 'SamplesOutputFcn', '');
            set(state.spc.init.spc_ao, 'StopFcn', '');
%         else
%             set(state.spc.init.spc_ao, 'StopFcn', 'endAcquisition');  %Ryohei, RY092909
%         end
    
        if state.spc.acq.SPCModInfo.module_type == 140 || state.spc.acq.SPCModInfo.module_type == 150
            if state.spc.acq.SPCdata.mode == 2
                set(state.spc.init.spc_aoF, 'RepeatOutput', 0);
                set(state.spc.init.spc_aoF, 'SamplesOutputFcnCount', sampleSizeF);
                set(state.init.ao2F, 'RepeatOutput', 0);
                set(state.spc.init.spc_aoF, 'SamplesOutputFcn', 'spc_endAcquisitionF');
            end
        end
%%%%DIO control%%%%%%%%\
        %%%[1,0] for FLIM
        %%%[0,1] for image
        if state.spc.acq.spc_takeFLIM
            putvalue(state.spc.init.spc_dio, state.spc.init.dio_flim);
        else
            putvalue(state.spc.init.spc_dio, state.spc.init.dio_image);
        end
        %%%%%%%%%%%%%%%%%%%%%%%
end