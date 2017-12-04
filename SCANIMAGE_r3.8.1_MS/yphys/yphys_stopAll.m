function yphys_stopAll
global state



stopGrab;
state.init.hAI.control('DAQmx_Val_Task_Unreserve');

if isfield(state, 'yphys')
    if isfield(state.yphys, 'init')
        try
            state.yphys.init.phys_input.control('DAQmx_Val_Task_Unreserve');
        end
        try
            state.yphys.init.phys_inputPatch.control('DAQmx_Val_Task_Unreserve');
        end
        try
            state.yphys.init.phys_patch.control('DAQmx_Val_Task_Unreserve');
        end
        try
            state.yphys.init.acq_ai.control('DAQmx_Val_Task_Unreserve');
        end
        try
            state.yphys.init.phys_both.control('DAQmx_Val_Task_Unreserve');
        end
        try
            state.yphys.init.pockels_ao.control('DAQmx_Val_Task_Unreserve');
        end
        try
            state.yphys.init.scan_ao.control('DAQmx_Val_Task_Unreserve');
        end
        try
            state.yphys.init.pockels_ao.control('DAQmx_Val_Task_Unreserve');
        end
        try
            state.yphys.init.scan_ao.control('DAQmx_Val_Task_Unreserve');
        end
    end
end

    %state.yphys.init.shutterAO.control('DAQmx_Val_Task_Unreserve');
try
    state.spc.init.eom.hAO2.control('DAQmx_Val_Task_Unreserve');
    %state.spc.init.taskA.control('DAQmx_Val_Task_Unreserve');
end

try
    state.spc.init.taskA.control('DAQmx_Val_Task_Unreserve');
end