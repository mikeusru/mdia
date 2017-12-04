classdef optLensClass < handle
    %optLens is the controller class for the Optotune Lens Driver 4.
    
    properties
        %% Set COM here
        port='COM8';
        
        %%
        BaudRate=115200;
        handshake='';
        serNum=[];
        current=0;
        temp=[];
        controlMode='serial';
        ID=[];
        firmwareVersion=[];
        signalMode='';
        upSwing=10;
        lowSwing=0;
        frequency=1;
        minTemp=[];
        maxTemp=[];
        focalPower=[];
        maxOutputCurrent=293;
        upperSoftwareCurrentLimit=293;
        lowerSoftwareCurrentLimit=0;
        optLens;
        lastReadCurrent=[];
        currentMode=1; %current, sinusoidal, triangular, rectangular modes
    end
    
    methods
        function initialize(obj) %connect lens controller
            obj.optLens=serial(obj.port,'BaudRate',obj.BaudRate);
            fopen(obj.optLens); %connect
            fprintf(obj.optLens,'Start'); %handshake
            obj.handshake = fscanf(obj.optLens);
        end
        
        function disconnect(obj)
            fclose(obj.optLens);
        end
        
        function serialNum(obj) %get Serial Number
            string='X';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            obj.serNum=fread(obj.optLens);
            obj.serNum(1)=[];
            obj.serNum(end-4:end)=[];
        end
        
        function setCurrent(obj,current) %set current command. current unit is mA
            string='Aw'; %write mode
            data=int16(current/obj.maxOutputCurrent * 4096);
            allhex=dec2hex(data,4);
            hex={allhex(1:2);allhex(3:4)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.current=current;
        end
        
        function getCurrent(obj) % get current value. not working... currently.
            string='Ar'; %write mode
            dummy=0;
            allhex=dec2hex(dummy,4);
            hex={allhex(1:2);allhex(3:4)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            tempInfo=fread(obj.optLens);
            current=tempInfo(2)*256+tempInfo(3);
            current=current*obj.maxOutputCurrent/4095;
            obj.lastReadCurrent=current;
        end
        
        function readTemp(obj) %read temp function.
            string='TA';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            tempDec=fread(obj.optLens);
            obj.temp=(tempDec(4)*256+tempDec(5))/16;
        end
        
        function analogControlMode(obj) %set analog control mode
            string='LA';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            obj.controlMode='analog';
        end
        
        function serialControlMode(obj) %set serial control mode
            string='LS';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            obj.controlMode='serial';
        end
        
        function readDeviceID(obj) %Device ID - read
            string='IR';
            data=0;
            allhex=dec2hex(data,16);
            hex={allhex(1:2);allhex(3:4);allhex(5:6);allhex(7:8);...
                allhex(9:10);allhex(11:12);allhex(13:14);allhex(15:16)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            devID=fread(optLens);
            devID([1,2,end-4:end])=[];
            obj.ID=devID;
        end
        
        function firmwareVersionRead(obj) %firmware version
            string='V';
            data=0;
            allhex=dec2hex(data,2);
            hex={allhex(1:2)};
            inputSignal=obj.signalCalc(string,hex);
            tempInfo=fwrite(obj.optLens,inputSignal);
            tempInfo([1,end-4:end])=[];
            obj.firmwareVersion=tempInfo;
        end
        
        function analogInputReading(obj) %get analog reading of channel A
            string='GAA';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            tempInfo=fread(optLens);
            tempInfo([1:3,end-4:end])=[];
            obj.ID=tempInfo;
        end
        
        function setSinusoidalSignal(obj) %set sinusoidal waveform
            string='MwSA';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            obj.signalMode='sin';
        
        end
        
        
        function setRectangularSignal(obj) %set rectangular waveform
            string='MwQA';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            obj.signalMode='rect';
                       
        end
        
        function setDCmode(obj)
            string='MwDA';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            obj.signalMode='DC';
        end
        
        function setTriangularSignal(obj)
            string='MwTA';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            obj.signalMode='tri';
                        
        end
        
        function setCtrlMode(obj)
            string='MwCA';
            inputSignal=obj.signalCalc(string);
            fwrite(obj.optLens,inputSignal);
            obj.signalMode='ctrl'; 
        end
        
        function setUpSwingLimit(obj,current) % upper swing limit for current. can only be used in sinusoidal, rectangular, or triangular mode
            string='PwUA';
            data=int16(current/obj.maxOutputCurrent * 4096);
            allhex=dec2hex(data,4);
            hex={allhex(1:2);allhex(3:4);'00';'00'};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.upSwing=current;
            
        end
        
        function setLowSwingLimit(obj,current) % lower swing limit for current. can only be used in sinusoidal, rectangular, or triangular mode
            string='PwLA';
            data=int16(current/obj.maxOutputCurrent * 4096);
            allhex=dec2hex(data,4);
            hex={allhex(1:2);allhex(3:4);'00';'00'};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.lowSwing=current;
            
        end
        
        function setFrequency(obj,freq) %set frequency
            string='PwFA';
            data=uint32(freq*1000);
            allhex=dec2hex(data,8);
            hex={allhex(1:2);allhex(3:4);allhex(5:6);allhex(7:8)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.frequency=freq;
        end
        
        function setTempLimits(obj,minTemp,maxTemp) %set temperature limits
            string='PwTA';
            data1=int16(maxTemp*16);
            data2=int16(minTemp*16);
            allhex=[dec2hex(data1,4), dec2hex(data2,4)];
            hex={allhex(1:2);allhex(3:4);allhex(5:6);allhex(7:8)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.minTemp=minTemp;
            obj.maxTemp=maxTemp;
            
        end
        
        function setFocalPower(obj,fPower) %set focal power
            string='PwDA';
            data=uint16((fPower+5)*200);
            dummy=0;
            allhex=[dec2hex(data,4), dec2hex(dummy,4)];
            hex={allhex(1:2);allhex(3:4);allhex(5:6);allhex(7:8)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.focalPower=fPower;
        end
        
        function setMaxOutputCurrent(obj,current) %set upper hardware limit for current
            string='CwMA';
            data=uint16(current*100);
            allhex=dec2hex(data,4);
            hex={allhex(1:2);allhex(3:4)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.maxOutputCurrent=current;
        end
        
        function setUpperSoftwareCurrentLimit(obj,current)
            string='CwUA';
            data=int16(current*4095/obj.maxOutputCurrent);
            allhex=dec2hex(data,4);
            hex={allhex(1:2);allhex(3:4)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.upperSoftwareCurrentLimit=current;
        end
        
        function setLowerSoftwareCurrentLimit(obj,current) %set lower software limit for current
            string='CwLA';
            data=int16(current*4095/obj.maxOutputCurrent);
            allhex=dec2hex(data,4);
            hex={allhex(1:2);allhex(3:4)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.lowerSoftwareCurrentLimit=current;
        end
        
        function setGainVar(obj,gainVar) %gain variable (write)
            string='Ow';
            data=uint16(gainVar*100);
            allhex=dec2hex(data,4);
            hex={allhex(1:2);allhex(3:4)};
            inputSignal=obj.signalCalc(string,hex);
            fwrite(obj.optLens,inputSignal);
            obj.gainVariable=gainVar;
        end
        
        
        %%
        function inputSignal=signalCalc(obj,string,hex)
            %claculate output signal along with CRC16 values
            %first input is string, then the hex.
            % hex is a cell array of double-digit hex strings
            
            gx = hex2dec('8005');          % CRC16 generator polynomial
            
            if nargin<3 %if no hex input
                for i=1:length(string)
                    inputStringHex{i}=sprintf('%x',string(i));
                end
                input=inputStringHex;
                msgSizeBytes = length(string);
            elseif nargin<4
                for i=1:length(string)
                    inputStringHex{i}=sprintf('%x',string(i));
                end                
                input=[inputStringHex, hex'];
                msgSizeBytes = length(string)+length(hex);
            end
            
            %message array
            
            ux = hex2dec(input);
            % Message variables
            bitReverseMsg = 1;                 % set to 1 to reverse each byte before CRC, and 0 for no reverse
            bitReverseCRC = 1;                 % set to 1 to reverse each byte of the CRC, and 0 for no reverse
            
            % table of 4 bit reverses
            it = [0 8 4 12 2 10 6 14 1 9 5 13 3 11 7 15];
            
            %Compute a lookup table and byte reversal table
            for i=0:255
                result = bitshift(i,8);
                for j=0:7
                    if (bitand(result, hex2dec('8000')))
                        result = bitxor(bitshift(result, 1), gx);
                    else
                        result = bitshift(result, 1);
                    end
                end
                result = bitand(result, hex2dec('FFFF'));
                crcTable(i+1) = uint16(result);
                
                lowNibble = bitand(i, hex2dec('F'));
                lowNibbleReverse = bitshift(it(lowNibble + 1), 4);
                highNibble = bitshift(i, -4);
                highNibbleReverse = it(highNibble + 1);
                rchrTable(i+1) = bitor(lowNibbleReverse, highNibbleReverse);
            end
            crcTableHex = dec2hex(crcTable);
            
            %compute the CRC
            crcVal = uint16(0);
            for i=1:msgSizeBytes
                if (bitReverseMsg)
                    dataVal = rchrTable(ux(i) + 1);
                else
                    dataVal = ux(i);
                end
                tableIndex = bitxor(dataVal, bitshift(crcVal,-8));
                tableVal = crcTable(tableIndex + 1);
                crcValLowByte = bitand(bitshift(crcVal, 8), hex2dec('FF00'));
                crcVal = bitxor(tableVal, crcValLowByte);
            end
            if (bitReverseCRC)
                crcHighByte = bitshift(crcVal, -8);
                crcHighByteReverse = rchrTable(crcHighByte + 1);
                crcLowByte = bitand(crcVal, hex2dec('FF'));
                crcLowByteReverse = bitshift(rchrTable(crcLowByte + 1), 8);
                crcVal = bitor(crcHighByteReverse, crcLowByteReverse);
            end
            
            crc = dec2hex(crcVal,4);
            inputSignal=[hex2dec(input); hex2dec(crc(3:4)); hex2dec(crc(1:2))];
        end
        
        
        
    end
end

