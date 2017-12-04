function addToAF()
%addToAF is called in order to add the current image
%to the AF structure

global state af ua spc

if state.internal.usePage %do not run during page acq
   return;
end

if af.params.isAFon && af.params.useAcqForAF
    I = getLastAcqImage;
%     if state.spc.acq.spc_takeFLIM %z slice counter is off with flim
%         zSliceCounter=state.internal.zSliceCounter;
%     else
%         zSliceCounter=state.internal.zSliceCounter+1;
%     end
%     disp(['addToAF', num2str(zSliceCounter)]);
    af.images{state.internal.zSliceCounter}=I;
%     af.position.af_list_rel_z(state.internal.zSliceCounter)=af.frameRelZPosition;
%     af.position.af_list_abs_z(state.internal.zSliceCounter)=af.frameAbsZPosition;
end

end

