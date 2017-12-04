function [true_nsyncA, channelA, specialA, dtimeA, eventsA] = PQ_read(a)

%% Read HydraHarp/TimeHarp260 T3
    OverflowCorrection = 0;
    T3WRAPAROUND = 1024;
    Version = 3;

    nsyncA = bitand(a, 1023);
    dtimeA = bitand(bitshift(a, -10), 32767);
    channelA = bitand(bitshift(a, -25), 63);
    specialA = bitand(bitshift(a, -31), 1);
    
    eventsA = (channelA <= 15 & channelA >= 1 & specialA ~= 0);
    overflowA = (channelA == 63 & specialA ~= 0);
    overflowCrrA = cumsum(double(nsyncA).*double(overflowA)*T3WRAPAROUND);
    true_nsyncA = double(nsyncA) + overflowCrrA;
    
% for i = 1:length(a)
%         T3Record = a(i);
%         %   +-------------------------------+  +-------------------------------+ 
%         %   |x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|  |x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|
%         %   +-------------------------------+  +-------------------------------+  
%         nsync = bitand(T3Record,1023);       % the lowest 10 bits:
%         %   +-------------------------------+  +-------------------------------+ 
%         %   | | | | | | | | | | | | | | | | |  | | | | | | |x|x|x|x|x|x|x|x|x|x|
%         %   +-------------------------------+  +-------------------------------+  
%         dtime = bitand(bitshift(T3Record,-10),32767);   % the next 15 bits:
%         %   the dtime unit depends on "Resolution" that can be obtained from header
%         %   +-------------------------------+  +-------------------------------+ 
%         %   | | | | | | | |x|x|x|x|x|x|x|x|x|  |x|x|x|x|x|x| | | | | | | | | | |
%         %   +-------------------------------+  +-------------------------------+
%         channel = bitand(bitshift(T3Record,-25),63);   % the next 6 bits:
%         %   +-------------------------------+  +-------------------------------+ 
%         %   | |x|x|x|x|x|x| | | | | | | | | |  | | | | | | | | | | | | | | | | |
%         %   +-------------------------------+  +-------------------------------+
%         special = bitand(bitshift(T3Record,-31),1);   % the last bit:
%         %   +-------------------------------+  +-------------------------------+ 
%         %   |x| | | | | | | | | | | | | | | |  | | | | | | | | | | | | | | | | |
%         %   +-------------------------------+  +-------------------------------+ 
%         if special == 0   % this means a regular input channel
%            true_nSync = OverflowCorrection + nsync;
%            %  one nsync time unit equals to "syncperiod" which can be
%            %  calculated from "SyncRate"
%            fprintf('%ld, CHN %d, %d\n', true_nSync, channel, dtime);
%            fprintf('%ld, CHN %d, %d\n', true_nsyncA(i), channelA(i), dtimeA(i));
%         else    % this means we have a special record
%             if channel == 63  % overflow of nsync occured
%               if (nsync == 0) || (Version == 1) % if nsync is zero it is an old style single oferflow or old Version
%                 OverflowCorrection = OverflowCorrection + T3WRAPAROUND;
%                 %GotOverflow(1);
%               else         % otherwise nsync indicates the number of overflows - THIS IS NEW IN FORMAT V2.0
%                 OverflowCorrection = OverflowCorrection + T3WRAPAROUND * nsync;
%                 %GotOverflow(nsync);
%               end;    
%             end;
%             if (channel >= 1) && (channel <= 15)  % these are markers
%               true_nSync = OverflowCorrection + nsync;
%               %GotMarker(true_nSync, channel);
%               fprintf('MARK %ld\n', true_nSync);
%             end;    
%         end;
% end

