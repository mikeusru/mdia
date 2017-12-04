function spc_putDataFocus (recalc)
global state;

%     focusData = spc_makeDataOutput(1);
%     putdata(state.spc.init.spc_aoF, focusData(:, 1:3));
%     putdata(state.init.ao2F, makeMirrorDataOutput);
 
if ~nargin
    recalc = 1;
end
% if state.spc.init.spc_on == 1;
%     if state.spc.acq.SPCdata.mode == 2
%         if recalc
%             state.spc.acq.mirrorOutputData = makeMirrorDataOutput;
%         end
%         putdata(state.init.ao2F, state.spc.acq.mirrorOutputData);
%         if recalc
%             state.spc.internal.spc_outData = spc_makeDataOutput(1, 1, 0);
%         end
%         putdata(state.spc.init.spc_aoF, double(state.spc.internal.spc_outData(:, 1:3)));
%     else
%         putdata(state.init.ao2F, double(state.spc.acq.mirrorOutputData));
%     end
% end

    if recalc
        state.spc.acq.mirrorOutputData = makeMirrorDataOutput;
        state.spc.internal.spc_outData = spc_makeDataOutput(1, 1, 0);
    end
    putdata(state.spc.init.spc_aoF, state.spc.internal.spc_outData(:, 1:3));
    putdata(state.init.ao2F, state.spc.acq.mirrorOutputData);