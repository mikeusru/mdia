function yphys_nowincell;

global state;

nowincell = state.spc.yphys;
if ~exist([state.files.savePath, '\spc'], 'dir')
    %cd (state.files.savePath);
    mkdir([state.files.savePath, '\spc']);
end
cd ([state.files.savePath, '\spc']);
save('nowincell', 'nowincell');
    