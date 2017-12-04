function exclusiveActionNextStep
%exclusiveActionNextStep runs when one step of the exclusive
%imaging/uncaging action is complete
global dia


dia.acq.exclusiveTaskCounter=dia.acq.exclusiveTaskCounter+1;

if dia.acq.exclusiveTaskCounter>length(dia.acq.exclusiveSteps)
    finishExclusiveUAStagger;
    return
end

while ~dia.acq.exclusiveSteps(dia.acq.exclusiveTaskCounter)
    dia.acq.exclusiveTaskCounter=dia.acq.exclusiveTaskCounter+1;
    if dia.acq.exclusiveTaskCounter>length(dia.acq.exclusiveSteps)
        finishExclusiveUAStagger;
        return
    end
end
setExclusiveUAParams;



end

