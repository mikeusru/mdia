function a = yphys_mkPulse(rate, nstim, dwell, Dheight, delay, sLength, addP, tag)
global state;
global gh;


if ~nargin
    %Always uncaging when not specified
    param = state.yphys.acq.pulse{3, state.yphys.acq.pulseN};
    rate = param.freq;
    nstim = param.nstim;
    dwell = param.dwell;
    Dheight = param.amp;
    delay = param.delay;
    sLength = state.yphys.acq.sLength(state.yphys.acq.pulseN);
    if isfield(param, 'addP')
        addP = param.addP;
    else
        addP = -1;
    end
    tag = 'auto';
end
minV = 0;
if strcmp(tag, 'uncage')||strcmp(tag, 'auto')
    if Dheight > 100
        Dheight = 100;
    end
end
%%%For theta
%nstimIn = 20;
%thetaFreq = 5;  %Hz go up to 20 burst frequency go down to 50
thetaFreq = 5; 
nstimTheta = 3;
thetaISI = 10;
theta = get(gh.yphys.stimScope.theta, 'Value');
thetaTime = 1000 / thetaFreq;

%%%%

if ~theta
    nSample = round(state.yphys.acq.outputRate*sLength/1000);
else
    nSample = round(state.yphys.acq.outputRate*thetaTime/1000);
end
OneStim = round(state.yphys.acq.outputRate/rate);


a(1:OneStim) = minV;
Pulsephase = round(state.yphys.acq.outputRate*dwell/1000);
a(1:Pulsephase) = Dheight;


%a(Pulsephase+1:2*Pulsephase) = -Dheight;
a = a(:);
if ~theta
    a = repmat(a, nstim, 1);
    blank = minV*ones(state.yphys.acq.outputRate*delay/1000, 1);
else
    a = repmat(a, nstimTheta, 1);
    blank = minV*ones(state.yphys.acq.outputRate*thetaISI/1000, 1);
end
a = [blank; a];

if length(a) < nSample
    a = [a; minV*ones((nSample - length(a)), 1)];
else
    a = a(1:nSample);
end

if theta
    a = repmat(a, [nstim, 1]);
    blank = minV*ones(state.yphys.acq.outputRate*delay/1000, 1);
    a = [blank; a];
    nSample = state.yphys.acq.outputRate*sLength/1000;
    if length(a) < nSample
        a = [a; minV*ones((nSample - length(a)), 1)];
    else
        a = a(1:nSample);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Add another pulse
if ~isempty(addP)
    for k=1:length(addP)
        if addP(k) > 0    
            a2 = [];
            if strcmpi(tag, 'ap')
                param = state.yphys.acq.pulse{1, addP(k)};
            elseif strcmpi(tag, 'stim')
                param = state.yphys.acq.pulse{2, addP(k)};
            elseif strcmpi(tag, 'uncage')
                param = state.yphys.acq.pulse{3, addP(k)};
            elseif strcmpi(tag, 'auto')
                param = state.yphys.acq.pulse{3, addP(k)};
            end
            rate2 = param.freq;
            nstim2 = param.nstim;
            dwell2 = param.dwell;
            ampc2 = param.amp;
            delay2 = param.delay;
            OneStim2 = round(state.yphys.acq.outputRate/rate2);
            a2(1:OneStim2) = 0;
            Pulsephase2 = round(state.yphys.acq.outputRate*dwell2/1000);
            a2(1:Pulsephase2) = ampc2;
            a2 = repmat(a2(:), nstim2, 1);
            blank2 = zeros(state.yphys.acq.outputRate*delay2/1000, 1);
            a2 = [blank2; a2(:)];
            if length(a2) < nSample
                a2 = [a2; zeros((nSample - length(a2)), 1)];
            else
                a2 = a2(1:nSample);
            end
            %figure; plot(a2);
            a = a + a2;
        end
    end
end

if strcmpi(tag, 'uncage') || strcmpi(tag, 'auto')
    a(a == 0) = 1;
else
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


state.yphys.acq.stimPulse = a;
try
    if strcmp(tag, 'ap')
        set(gh.yphys.pulsePlot1, 'XData', (1:length(a))/state.yphys.acq.outputRate*1000, 'YData', a);
    elseif strcmp(tag, 'stim')
        set(gh.yphys.pulsePlot2, 'XData', (1:length(a))/state.yphys.acq.outputRate*1000, 'YData', a);
    elseif strcmp(tag, 'uncage')
        set(gh.yphys.pulsePlot3, 'XData', (1:length(a))/state.yphys.acq.outputRate*1000, 'YData', a);
    else
        %set(gh.yphys.pulsePlot1, 'XData', (1:length(a))/state.yphys.acq.outputRate*1000, 'YData', a);
    end
catch
    %disp('Error in yphys_mkpulse');
end