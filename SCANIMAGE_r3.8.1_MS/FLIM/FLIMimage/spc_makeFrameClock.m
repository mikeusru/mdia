function [lineOutput, frameOutput]  = spc_makeFrameClock

global state


%Do some simple checking of the variables.
if state.acq.pockelsCellFillFraction > 1
    state.acq.pockelsCellFillFraction = 1;
elseif state.acq.pockelsCellFillFraction < 0
    state.acq.pockelsCellFillFraction = 0;
end

if state.acq.pockelsCellLineDelay > 1000 * state.acq.msPerLine
    %Allow it to rotate all the way around.
    state.acq.pockelsCellLineDelay = mod(.001 * state.acq.pockelsCellLineDelay, state.acq.msPerLine);
elseif state.acq.pockelsCellLineDelay < 0
    state.acq.pockelsCellLineDelay = 0;
end

pockelsOn = true(state.internal.lengthOfXData, 1);

%Start from the phase shift value.
startGoodPockelsData = floor(state.internal.lengthOfXData * .001 * state.acq.pockelsCellLineDelay / state.acq.msPerLine) + 1;
 
%End at X% of the total waveform.
endGoodPockelsData = startGoodPockelsData + ceil(state.internal.lengthOfXData * state.acq.pockelsCellFillFraction);

%Watch out for rounding errors causing overruns.
if endGoodPockelsData > state.internal.lengthOfXData
    if startGoodPockelsData <= state.internal.lengthOfXData
        pockelsOn(startGoodPockelsData:state.internal.lengthOfXData) = false;
    end
else
    pockelsOn(startGoodPockelsData:endGoodPockelsData) = false;   
end   

%Final Pockels Data for one frame
lineOutput = repmat(pockelsOn, [state.acq.linesPerFrame 1]);

frameOutput(length(lineOutput)) = false;
frameOutput(1:startGoodPockelsData-1) = true;
%frameOutput(endGoodPockelsData+1:end) = true;