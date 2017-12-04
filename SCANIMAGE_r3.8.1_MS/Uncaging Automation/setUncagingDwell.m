function setUncagingDwell( zdiff )
%setUncagingDwell sets the dwell time for uncaging based on the zdiff value
%which indicates the difference between the top of the slice and the actual
%z position
global  state gh

zdiff = abs(zdiff);

if zdiff<10
    dwell=4;
elseif zdiff>=10 && zdiff<=20
    dwell=6;
elseif zdiff>20
    dwell=8;
end
disp(['Dwell time set to ' num2str(dwell) 'ms']);
state.yphys.acq.dwell=dwell;
set(gh.yphys.stimScope.dwell, 'String', num2str(state.yphys.acq.dwell));

end

