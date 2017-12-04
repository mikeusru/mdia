function [  ] = UA_done_uncaging(  )
%UA_done_uncaging is activated when a round of uncaging is complete

global ua state gh

disp(['Uncaging at position ' num2str(ua.acq.currentPos) ' done']);

%% Time to start loop mode.

if ~isfield(ua.params,'pageacq') || ~ua.params.pageacq
    %if page acquisition mode is not on
    % start loop imaging
    UA_startloop;
end
end

