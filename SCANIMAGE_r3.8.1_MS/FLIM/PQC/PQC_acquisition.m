classdef PQC_acquisition < handle
    properties
        devices;
        deviceID;
        serial;
        device_properties;
        measurementTime;
        mode;
        open;
    end
    methods
        function obj = PQC_acquisition(deviceID, mode)  %CREATION
            global state;
            obj.devices = PQC_openDevice (state.spc.acq.SPCdata.serialFLIm);
            %
            if any(obj.devices == deviceID)
                obj.mode = mode;
                obj.open = 1;
                obj.deviceID = deviceID;
                obj.serial = state.spc.acq.SPCdata.serialFLIm;
                obj.measurementTime = 1000; 
                ret = PQC_initialize(deviceID, obj.mode);
                if ~ret
                    setParameters(obj);
                else
                    obj.open = 0;
                end
            else
                obj.open = 0;
            end
        end
        
        function ret = initialize(obj)
            if obj.open
                ret = PQC_initialize(obj.deviceID, obj.mode);
                if ~ret
                    obj.setParameters();
                end
            end
        end
        
        function pqData = getDeviceInfo(obj)
            global state;
            if obj.open
                pqData = PQC_getDeviceInfo(obj.deviceID, state.spc.acq.SPCdata);
                obj.device_properties = pqData;
            end
        end
        
        function setParameters(obj)
            global state spc
            if obj.open
                state.spc.acq.SPCdata = PQC_setParameters(obj.deviceID, state.spc.acq.SPCdata, 0);
                try
                    state.spc.acq.SPCdata.adc_resolution = ceil(spc.datainfo.pulseInt / state.spc.acq.SPCdata.resolution * 1000);
                    spc.datainfo.adc_re = state.spc.acq.SPCdata.adc_resolution;
                end
                obj.device_properties = state.spc.acq.SPCdata;
            end
        end
        
        function clearBuffer(obj)
            if obj.open
                PQC_startMeasurement(obj.deviceID, 1); %measure for 1 ms.
            end
        end
        
        function startMeas(obj)
            if obj.open
                PQC_startMeasurement(obj.deviceID, obj.measurementTime);
            end
        end
        
        function stopMeas(obj)
            if obj.open
                PQC_stopMeasurement(obj.deviceID);
            end
        end
        
        function data = readBuffer(obj)
            if obj.open
                [ret, data1] = PQC_readBuffer(obj.deviceID);
                if ~ret
                    data = data1;
                else
                    data = [];
                end
            else
                data = [];
            end
        end
        
        function [photons, events] = readBuffer_calc(obj)
            if obj.open
                [ret, photons1, events1] = PQC_readBufferAndCalc(obj.deviceID);
                if ~ret
                    photons = photons1;
                    events = events1;
                else
                    photons = [];
                    events = [];
                end
            else
                photons = [];
                events = [];
            end
        end
        
        function [ret, data] = getRates(obj)
            if obj.open
                [ret, data.sync_rate, data.ch_rate] = PQC_getRates(obj.deviceID);
                if ret < 0
                    obj.open = 0;
                    data.sync_rate = 0;
                    data.ch_rate = [0, 0];
                end
            else
                ret = -1;
                data.sync_rate = 0;
                data.ch_rate = [0, 0];
            end
        end
        
        function closeDevice(obj)
            obj.open = 0;
            PQC_closeDevice(obj.deviceID);
        end
    end
    
end