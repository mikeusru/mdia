function mini = yphys_mini_statFolder;

lowRise = 0.5; %ms 
highRise = 4; %ms
lowDecay = 2; %ms
highDecay = 8; %ms 
thAmp = 8; %pA Threshold for Peak Amp.
thSse = 3.5; %Threshold for PeakAmp / SSE. Should be 3 - 4.
thsse_b = 4; %PeakAmp / sse_baseline; Baseline fluctuation.

deltat = 0.2;
template = yphys_mini_makeTemplate(1,20,0, deltat);
npt = length(template);
nptb = sum(template == 0);


fnames = dir('yphys*_mini.mat');
mini_count = 0;

mini.peak_pos_all= [];
mini.base_amp_all = [];
mini.peak_amp_all = [];
mini.rise_time_all = [];
mini.decay_time_all = [];
mini.shift_all = [];
mini.sse_all = [];
mini.sse_b = [];
mini.time = 0;

if length(fnames) > 0
    for i=1:length(fnames)

      %%%%%%%%%READING%%%%%%%%%%%%  
        vnameMini = fnames(i).name;
        load(fnames(i).name);%%%%%%%%%%%%%%%%
        vname = vnameMini(1:8);
        vname = [vname, '.mat'];
        load(vname);
        vname = vname(1:8);
        vnameMini = [vname, '_mini'];
        evalc (['a = ', vname]);
        evalc (['b = ', vnameMini]);
        data1 = a.data(:,2);
        if a.inputRate == 10000
            data1 = mean(reshape(data1, 2, length(data1)/2), 1);
        end
    %%%%%%%%%%%%%%%%%%%%%%%%
        base_amp = [];
        peak_amp = [];
        rise_time = [];
        decay_time = [];
        shift1 = [];
        peak_pos = [];
        sse2 = [];
    %%%%%%Fitting%%%%%%%%%%%%

        for k=1:length(b.peak_pos)
            mini_count = mini_count + 1;
            pos1 = b.peak_pos(k);
            offset1 = b.base_amp(i);
            %offset1 = mean(data1(pos1:pos1+nptb-1));
            scale1 = b.peak_amp(k);
            data2 = data1(pos1:pos1+npt-1);
            beta0 = [1, 8, scale1, offset1, -1];
            xdata1 = 1:npt;
            data2 = data2(:)';
            betahat = nlinfit(xdata1, data2, @yphys_mini_fitting, beta0);
            fitted_temp2 = yphys_mini_fitting(betahat, xdata1);
            tau1 = abs(betahat(1));
            tau2 = abs(betahat(2));
            if tau1 > tau2
                tau2 = abs(betahat(1));
                tau1 = abs(betahat(2));
            end
            base_amp(k) = betahat(4);
            peak_amp(k) = betahat(3);
            rise_time(k) = tau1;
            decay_time(k) = tau2;
            shift1(k) = betahat(5);

            sse1 = (data2 - fitted_temp2).^2;
            sse1 = sum(sse1(:));
            sse1 = sqrt(sse1 / (npt-1));
            sse2(k) = betahat(3)/sse1;
            
            template2 = yphys_mini_makeTemplate(tau1, tau2, shift1(k), deltat);
            l1 = sum(template2 == 0);
            sseb = (data2(1:l1) - fitted_temp2(1:l1)).^2;
            sseb = sum(sseb(:));
            sseb = sqrt(sseb / (l1-1));
            sse_b(k) = betahat(3) / sseb;
        end
         %%%%%%%%%%%%%%%%%%%%%%%%%%%
         %selection

         be = rise_time > lowRise & rise_time < highRise & decay_time < highDecay & decay_time > lowDecay ...
             & peak_amp > thAmp & sse2 > thSse & sse_b > thsse_b;
         peak_pos = b.peak_pos(be);
         base_amp = base_amp(be);
         peak_amp = peak_amp(be);
         rise_time = rise_time(be);
         decay_time = decay_time(be);
         shift1 = shift1(be);
         sse2 = sse2(be);
         sse_b = sse_b(be);

         mini.peak_pos_all= [mini.peak_pos_all, peak_pos];
         mini.base_amp_all = [mini.base_amp_all, base_amp];
         mini.peak_amp_all = [mini.peak_amp_all, peak_amp];
         mini.rise_time_all = [mini.rise_time_all, rise_time];
         mini.decay_time_all = [mini.decay_time_all, decay_time];
         mini.shift_all = [mini.shift_all, shift1];
         mini.sse_all = [mini.sse_all, sse2];
         mini.sse_b = [mini.sse_b, sse_b];

         mini.time = length(data1)*deltat/1000 + mini.time;
         
    disp('%%%mEPSC result (each file)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp(vname);
    disp(['Mean mEPSC (pA): ', num2str(mean(peak_amp))]);
    disp(['Frequency (Hz): ', num2str(length(peak_amp)/(length(data1)*deltat/1000)), ' (', num2str(length(peak_amp)),' events/ ', num2str(length(data1)*deltat/1000), ' s)']);

     %%%%%Figure%%%%%%%%%%%%%%%%%%%%%%%%
        h = figure;
        set(h, 'name', [pwd, '\', vname]); 
        set(h, 'position', [360   146   733   776]);
        xdata1 = 1:npt;

        %%%
        subplot(2,1,1);
        hold on;
        xdata = deltat * ([1:length(data1)])/1000;
        plot(xdata, data1);
         for k=1:length(peak_pos)
            data2 = data1(peak_pos(k):peak_pos(k)+npt-1);
            xdataP = ([peak_pos(k):peak_pos(k)+npt-1])*deltat/1000;
            betahat = [rise_time(k), decay_time(k), peak_amp(k), base_amp(k), shift1(k)];
            fitted_temp2 = yphys_mini_fitting(betahat, xdata1);
            %plot(xdata*deltat, data2);
            plot(xdataP, fitted_temp2, '-r', 'linewidth', 2);
         end
         xlabel('Time (s)');
         ylabel('Current (pA)');
        %%%
        subplot(2,1,2);   
        hold on;
        for k=1:length(peak_pos)
            data2 = data1(peak_pos(k):peak_pos(k)+npt-1);
            xdata = (k-1)*npt+ xdata1;
            betahat = [rise_time(k), decay_time(k), peak_amp(k), base_amp(k), shift1(k)];
            fitted_temp2 = yphys_mini_fitting(betahat, xdata1);
            plot(xdata*deltat, data2);
            plot(xdata*deltat, fitted_temp2, '-r', 'linewidth', 2);
        end
        xlabel('Time (ms)');
        ylabel('Current (pA)');
    end %Loop files in the folder
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if mini.time > 0
        mini.nEvents = length(mini.peak_pos_all);
        mini.frequency = length(mini.peak_pos_all) / mini.time;
        mini.mean_pA = mean(mini.peak_amp_all);
        mini.fractuation_pA = std(mini.base_amp_all);
    else
        mini.nEvents = NaN;
        mini.frequency = NaN;
        mini.mean_pA = NaN;
        mini.fractuation_pA = NaN;
    end
    mini.folder = pwd;
    disp('%%%mEPSC result (whole folder) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp(pwd);
    disp(['Mean mEPSC (pA): ', num2str(mini.mean_pA)]);
    disp(['Frequency (Hz): ', num2str(mini.frequency), ' (', num2str(mini.nEvents),' events/ ', num2str(mini.time), ' s)']);
    disp(['Baseline Fractuation (pA): ', num2str(mini.fractuation_pA)]);
    save('mini', 'mini');
    
end %If file exist