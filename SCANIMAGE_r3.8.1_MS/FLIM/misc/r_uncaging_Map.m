function data1 = r_uncaging_Map;
global state;
global gh;

zoomF = state.acq.zoomhundreds*100+state.acq.zoomtens*10+state.acq.zoomones;
uStep = 4.5*zoomF/35; %zoom 35 == 10um/128pixel. 0.5 um = 6.4 pixles
nStep = 5;
nRepeat = 4;
roiR = get(gh.yphys.figure.yphys_roi(1), 'Position');
count1 = 0;

h = figure;
for j=1:nRepeat    
    for i=1:nStep;
        set(gh.yphys.figure.yphys_roi(1), 'position', roiR+[0, (i-1)*uStep, 0,0]);
        set(gh.yphys.figure.yphys_roi2(1), 'position', roiR+[0, (i-1)*uStep, 0,0]);
        pause(0.1);
        yphys_uncage;
        pause(1.5);
        count1 = count1+1;
        data1{count1} = state.yphys.acq.data;
        if count1 == 1
            aveMap = zeros(nStep, length(state.yphys.acq.data));
        end
        aveMap(i, :) = aveMap(i, :) + state.yphys.acq.data(:,2)';
        time1 = state.yphys.acq.data(:,1)';
        figure(h);
        plot(time1, aveMap);
    end
end
set(gh.yphys.figure.yphys_roi(1), 'position', roiR);
set(gh.yphys.figure.yphys_roi2(1), 'position', roiR);

        
aveMap = aveMap / nRepeat;
uncageMap.zoomF = zoomF;
uncageMap.rawData = data1;
uncageMap.nStep = nStep;
uncageMap.uStep = uStep;
uncageMap.roiR = roiR;
uncageMap.aveMap = aveMap;
uncageMap.time = time1;
save([state.files.savePath, 'spc\', state.files.baseName, '_uncageMap.mat'], 'uncageMap');