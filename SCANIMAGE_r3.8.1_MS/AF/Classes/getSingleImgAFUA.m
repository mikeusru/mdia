classdef getSingleImgAFUA < handle
    % at first this class will be used to get one frame from the data
    % acquisition system
    
    properties
        latestFrame=[];
        finishFrameGet=false;
        doGetSingleFrame=false;
        doGetMultipleETLframes=false;
        channel=1;
        I2=[];
        multCounter=0;
        nFrames=1;
        s1=0;
        s2=0;
        zStep=1;
        doSetETLswing=false;
       
    end
    events
        frameAcquired
    end
    
    methods
        function frameAcqTrigger(obj)
            if obj.doGetSingleFrame || obj.doGetMultipleETLframes || obj.doSetETLswing
                notify(obj,'frameAcquired');
            end
        end
        
        function setETLswing(obj) %nope, this doesn't work because it slows everything down too much. probably need to use analog.
            global dia
            addlistener(obj,'frameAcquired',@getLatestFrame);
                            
            obj.doSetETLswing=true;
            dia.hOL.setDCmode;
            dia.hOL.setCurrent(0);
            dia.hOL.setTriangularSignal; %hopefully it remembers the info from before
        end
        
        function endETLswing(obj)
            obj.doSetETLswing=false;
        end
        
        function getMultipleETLframes(obj)
            global dia gh
            
            if obj.multCounter==0 %initiate
                obj.doGetMultipleETLframes=true;
                obj.I2=zeros(obj.nFrames,128);
                addlistener(obj,'frameAcquired',@getLatestFrame);
                obj.multCounter=1;
                obj.finishFrameGet=false;

            elseif obj.multCounter==obj.nFrames+1 %end
                obj.doGetMultipleETLframes=false;
                obj.multCounter=0;
                obj.finishFrameGet=true;
                mainControls('focusButton_Callback',gh.mainControls.focusButton);
            else %add
                i=obj.multCounter;
                x=i*obj.zStep;
                current = obj.s1*x*x + obj.s2*x;
                dia.hOL.setCurrent(current);
                obj.I2(i,:)=obj.latestFrame(1,:);
                obj.multCounter=obj.multCounter+1;
            end
            
        end
        
        function getSingleFrame(obj)
            obj.doGetSingleFrame=true;
            obj.finishFrameGet=false;
            
            addlistener(obj,'frameAcquired',@getLatestFrame);
        end
        
        function getLatestFrame(obj,eventData)
            global af state gh
            % collect image
            if obj.doSetETLswing
                obj.setETLswing;
            else
                channel=obj.channel;
                %             if state.acq.averagingDisplay %check if can use average display
                %                 I=state.internal.tempImageDisplay{channel};
                %             else
                I=state.acq.acquiredData{1}{channel};
                %             end
                obj.latestFrame=I;
            end
            
            if  obj.doGetMultipleETLframes
                obj.getMultipleETLframes;
            elseif obj.doGetSingleFrame
                obj.doGetSingleFrame=false;
                mainControls('focusButton_Callback',gh.mainControls.focusButton);
                obj.finishFrameGet=true;
            end
        end
        
    end
    
    
    
end

