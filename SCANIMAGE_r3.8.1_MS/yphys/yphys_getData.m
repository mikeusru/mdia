function yphys_getData(~, evnt)
global state;
global gh;
global ysum;

%disp('yphys_getData')
debug = 1;
closeShutter;
if state.internal.usePage && state.acq.numberOfPages > 1
    yphys_stopAll;
    return;
else
    try
        data1 = state.yphys.init.phys_input.readAnalogData();
        %data1 = evnt.data;
    catch
        error('Error during readAnalogData()');
    end
end
disp('Reading data');
try
    if state.yphys.acq.uncage
    %     if state.acq.numberOfPages > 1 & state.internal.pageCounter < state.acq.numberOfPages ...
    %             & state.internal.pageCounter > 0
    %     else
            closeShutter;
        %end
    end

    set(gh.yphys.stimScope.start, 'Enable', 'Off');

    if ~isempty(data1);
        %data1 = getdata(state.yphys.init.phys_input);

    %figure(200);
        if state.yphys.acq.cclamp
            gain = state.yphys.acq.gainC;
        else
            gain = state.yphys.acq.gainV;
        end
        rate = state.yphys.acq.inputRate;

        yphys_header = ['yphys_', state.files.baseName];
        if ~isfield (state.yphys.acq, 'phys_counter')
            state.yphys.acq.phys_counter = 0;
        end
        if state.yphys.acq.phys_counter == 0;
            filenames=dir(fullfile(state.files.savePath, '\spc\yphys*.mat'));
            if prod(size(filenames)) ~= 0
                b=struct2cell(filenames);
                [sorted, whichfile] = sort(datenum(b(2, :)));
                newest = whichfile(end);
                filename = filenames(newest).name;
                pos1 = strfind(filename, '.');
                state.yphys.acq.phys_counter = str2num(filename(pos1-3:pos1-1))+1;
            else
                state.yphys.acq.phys_counter = 1;
            end
        else
            state.yphys.acq.phys_counter =  state.yphys.acq.phys_counter + 1;
        end

        t = 1:length(data1);
        state.yphys.acq.data = [t(:)/rate*1000, data1(:, 1)/gain];

        try
            data2 = state.yphys.init.acq_ai.readAnalogData;
            uncage = 1;
            state.yphys.acq.intensity1 = mean(data2(state.yphys.acq.data_On(1):state.yphys.acq.data_On(2), 1));
            state.yphys.acq.intensity2 = mean(data2(state.yphys.acq.data_On(1):state.yphys.acq.data_On(2), 2));

        catch
            data2 = [];
            uncage = 0;
        end
 

        if isfield(state, 'files')
            filen = sprintf('yphys%03d', state.yphys.acq.phys_counter);
            evalc([filen, '= state.yphys.acq']);
            filedir = [state.files.savePath, '\spc\'];

            if uncage
                if state.yphys.acq.phys_counter == 1
                    ysum = [];
                end
                %state.yphys.acq.phys_counter
                ysum.intensity1(state.yphys.acq.phys_counter) = state.yphys.acq.intensity1;
                ysum.intensity2(state.yphys.acq.phys_counter) = state.yphys.acq.intensity2 ;
                ysum.Xorg(state.yphys.acq.phys_counter) = state.yphys.acq.XYorg(1);
                ysum.Yorg(state.yphys.acq.phys_counter) = state.yphys.acq.XYorg(2);
                ysum.Xvol(state.yphys.acq.phys_counter) = state.yphys.acq.XYvol{1}(1);
                ysum.Yvol(state.yphys.acq.phys_counter) = state.yphys.acq.XYvol{1}(2);
                %%%%%%%%%%%%
                %Temporal
                if debug
                    if isempty(findobj('tag', 'yphys_int_graph'))
                        gh.yphys.intensity_graph = figure('tag', 'yphys_int_graph', 'name', 'yphys intensity graph');
                    end
                    figure(gh.yphys.intensity_graph);
                    subplot(1,3,1);
                    plot(ysum.Xvol, ysum.Yvol, '-o');
                    subplot(1,3,2);
                    plot(ysum.Xvol, ysum.intensity1, '-o');
                    subplot(1,3,3);
                    int1 = data2(:, 1);
                    int2 = data2(:, 2);
                    windowsize = state.acq.inputRate/10000;
                    int1F = filter (ones(windowsize, 1)/windowsize, 1, int1);
                    int2F = filter (ones(windowsize, 1)/windowsize, 1, int2);
                    t = (1:length(int1))/ state.acq.inputRate*1000;
                    plot(t, int1F, '-', 'color', 'green');
                    hold on;
                    plot(t, int2F, '-', 'color', 'red');
                    hold off;
               end
            end



           if get(gh.yphys.stimScope.saveCheck, 'Value')
                if exist(filedir, 'dir')
                    cd(filedir);
                    save(filen, filen);
                else
                    try
                        cd ([filedir, '\..\']);
                        if ~exist('spc', 'dir')
                            mkdir('spc');
                        end
                        cd(filedir);
                        save(filen, filen);
                    catch
                        %disp('Set save path!!');
                    end
                end
                %pause(0.3);
                if exist([filedir, filen, '.mat'], 'file')
                    %disp('loading average ....');
                    yphys_loadYphys([filedir, filen, '.mat']);
                    yphys_averageData;
                end
           end
        end
    end
    %toc;
catch ME
   disp('Error in yphys_getData');
   for i=1:length(ME.stack)
       disp(ME.stack(i).file);
       disp(ME.stack(i).name);
       disp(ME.stack(i).line);
   end
   fprintf(2,'ERROR in callback function (%s): \t%s\n',mfilename,ME.message);
end
yphys_stopAll;
state.yphys.internal.waiting = 0;
set(gh.yphys.stimScope.start, 'Enable', 'On');
