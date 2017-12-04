function r_switch_test
global state

cs = 100;
div = 2;

for i=1:cs
    if mod(i, div) == 0
        fprintf('%d/%d\n', i, cs);
    end
    state.spc.init.ao_flim1.writeAnalogData([5,0], 1, true);
    pause(0.3);
    state.spc.init.ao_flim1.writeAnalogData([0,5], 1, true);
    pause(0.3);
end