classdef mdiaPositionClass < handle
    %hPos is a class to handle all the positions in mdia
    
    properties %variables
        allPositionsDS=dataset; %dataset for all individual position info
        fovDS=dataset; %dataset for FOV info
        workingFOV=[];
        workingPositions=[];
        finishedPositions = [];
        posXYZ_graph_offset=[];
        imagingTimers=struct([]);
        timelineSetup=struct([]);
        staggerTime=[];
        collectFOVstackWhenDone = false; %collect stack of entire FOV area after done imaging
    end
    
    methods %functions
        
        function initialize(obj)
            obj.allPositionsDS=obj.emptyPositionDataset();
            obj.fovDS = obj.emptyFOVdataset();
        end
        
        function loadTimeline(obj,fpath)
            [timePath,~,~]=fileparts(fpath);
            timepath=[timePath,'\timings.mat'];
            if exist(timepath,'file')
                S = load(timepath);
                varNames = fieldnames(S);
                for i = 1:length(varNames)
                    obj.(varNames{i}) = S.(varNames{i});
                end
            end
        end
        
        function newPos = setWorkingPositions(obj,resetAll)
            %initialize/set the positions currently being imaged
            global dia
            if nargin<2 || isempty(resetAll)
                resetAll=false;
            end
            
            if resetAll
                obj.finishedPositions = [];
                obj.workingPositions = [];
            end
            %first, take only the positions in the lowest FOV number
            ds = obj.allPositionsDS;
            ind = ~ismember(ds.posID,obj.finishedPositions)... %don't use finished positions
            & ds.FOVnum == min(ds.FOVnum)... %take positions from lowest FOV
            & ~ismember(ds.posID,obj.workingPositions); %take out positions which are already added
            ds = ds (ind,:);
            if isempty(ds)
                newPos = [];
                return
            end
            %Order the positions by Z
            posnXYZ = getPosCoordinates(obj);
            posnXYZ = posnXYZ(ind,:);
            zOrder=sortrows([ds.posID,posnXYZ(:,3)],2);
            if size(zOrder,1) <= (dia.acq.maxPositions - length(obj.workingPositions))
                newPos = zOrder(:,1);
            else
                newPos = zOrder(1:(dia.acq.maxPositions - length(obj.workingPositions)),1);
            end
            obj.workingPositions = [obj.workingPositions ; newPos];
        end
        
        function defineROI(obj)
            global state gh ua dia
            zoomVal=state.acq.zoomFactor;
            if zoomVal~=ua.params.initialZoom
                errString=['Imaging Zoom value (' num2str(ua.params.initialZoom) ') and current Zoom value (' num2str(zoomVal) ') must be equal.'];
                errordlg(errString);
                return
            end
            
            if ua.params.fovModeOn
                choice=questdlg('Add ROI in FOV mode? Original XY motor values will be incorrect.','Add in FOV mode?','OK','Cancel','Cancel');
                if strcmp(choice,'Cancel')
                    return
                end
            end
            xyzPos = obj.getMotorAndEtlPosition; %make sure ETL position is considered
            motorZ = xyzPos(3);
            posID=state.hSI.zprvPosn2PositionID(xyzPos); %compare current coordinates to find closest position.
            if posID==0 %if position does not yet exist, add it and record new position #
                state.hSI.roiAddPosition(xyzPos); %same as clicking 'add' in the motor controls GUI. possibly. need to check.
                posID=state.hSI.zprvPosn2PositionID(xyzPos); %get position number from scanimage
            elseif ua.params.fovModeOn
                errString='ERROR - Scanimage already has a position saved with these motor coordinates. Try changing them slightly.';
                errordlg(errString,'FOV Mode ADD ROI failed');
                return
            end
            
            %% Delete all current ROIs
            for roiNum=1:length(gh.yphys.figure.yphys_roi)
                if ishandle(gh.yphys.figure.yphys_roi(roiNum))
                    a=findobj('Tag', num2str(roiNum));
                    delete(a);
                end
            end
            
            %% define new ROI
            if isfield(ua,'roiTotal') && ua.roiTotal>0
                roiNum=ua.roiTotal+1;
            else
                roiNum=1;
            end
            yphys_makeRoi(roiNum); %define new ROI
            
            %% record info to dataset
            
            roiPosition=get(gh.yphys.figure.yphys_roi(roiNum), 'Position');
            zRoofOffset=state.motor.absZPosition-ua.params.zRoof;
            
            ua.roiTotal=roiNum;
            
            if ua.params.fovModeOn %add position to FOV structure
                disp('Adding position to FOV');
                FOVnum=1;
                scanShiftFast=state.acq.scanShiftFast;
                scanShiftSlow=state.acq.scanShiftSlow;
                scanRotation=state.acq.scanRotation;
                setNewPosParams(obj,posID,roiNum,roiPosition,zoomVal,zRoofOffset,motorZ,FOVnum,scanShiftFast,scanShiftSlow,scanRotation);
            else
                setNewPosParams(obj,posID,roiNum,roiPosition,zoomVal,zRoofOffset,motorZ);
            end
            
            %% show ROI
            axes(state.internal.axis(1));
            gh.yphys.figure.yphys_roi(roiNum) = rectangle('Position', roiPosition, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(roiNum));
            gh.yphys.figure.yphys_roiText(roiNum) = text(roiPosition(1)-3, roiPosition(2)-3, num2str(roiNum), 'Tag', num2str(roiNum), 'ButtonDownFcn', 'yphys_roiDelete');
            set(gh.yphys.figure.yphys_roiText(roiNum), 'Color', 'Red');
            
            axes(state.internal.axis(2));
            gh.yphys.figure.yphys_roi2(roiNum) = rectangle('Position', roiPosition, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(roiNum));
            gh.yphys.figure.yphys_roiText2(roiNum) = text(roiPosition(1)-3, roiPosition(2)-3, num2str(roiNum), 'Tag', num2str(roiNum), 'ButtonDownFcn', 'yphys_roiDelete');
            set(gh.yphys.figure.yphys_roiText2(roiNum), 'Color', 'Red');
            
            axes(state.internal.maxaxis(2));
            gh.yphys.figure.yphys_roi3(roiNum) = rectangle('Position', roiPosition, 'Curvature',[1, 1], 'EdgeColor', 'cyan', 'ButtonDownFcn', 'yphys_dragRoi', 'Tag', num2str(roiNum));
            gh.yphys.figure.yphys_roiText3(roiNum) = text(roiPosition(1)-3, roiPosition(2)-3, num2str(roiNum), 'Tag', num2str(roiNum), 'ButtonDownFcn', 'yphys_roiDelete');
            set(gh.yphys.figure.yphys_roiText3(roiNum), 'Color', 'Red');
            
            updateUAgui;
            
            if ua.params.autoAddRefImg %add reference image
                addRefImg(obj,posID);
            end
            
            updateUAgui;
            
        end
        
        function setNewPosParams(obj,posID,roiNum,roiPosition,zoomVal,zRoofOffset,motorZ,FOVnum,scanShiftFast,scanShiftSlow,scanRotation)
            global ua
            ds=obj.emptyPositionDataset(0);
            
            ds.posID=posID;
            ds.roiNum=roiNum;
            ds.roiPosition={roiPosition};
            ds.zoomVal=zoomVal;
            ds.zRoofOffset=zRoofOffset;
            ds.motorZ=motorZ;
            ds.zDrift = 0;
            ds.scanShiftFastDrift = 0;
            ds.scanShiftSlowDrift = 0;
            if ua.params.fovModeOn
                ds.FOVnum=FOVnum;
                ds.scanShiftFast=scanShiftFast;
                ds.scanShiftSlow=scanShiftSlow;
                ds.scanRotation=scanRotation;
            end
            ind = find(obj.allPositionsDS.posID==posID);
            if isempty(ind) || ~ind
                obj.allPositionsDS=vertcat(obj.allPositionsDS,ds);
            else
                obj.allPositionsDS(ind,:)=ds;
            end
        end
        
        
        function addRefImg(obj,posID) %add reference image
            global ua state dia af
            channel=af.params.channel;
            if ua.drift.useMaxProjection
                I=updateCurrentImage(channel,2);
            else
                if state.acq.averagingDisplay %check if can use average display
                    I=state.internal.tempImageDisplay{channel};
                else
                    I=state.acq.acquiredData{2}{channel};
                end
            end
            %% zoom out and save zoomed out image
            initialzoom=ua.params.initialZoom;
            hasRefZoomOut=false;
            
            if ua.drift.zoomOutDrift
                newzoom=ua.drift.zoomfactor;
                setZoomValue(newzoom);
                setScanProps(dia.handles.mdia.defineUncagingROIpushbutton);
                ua.zoomedOut=true;
                if ua.drift.useMaxProjection
                    I2=updateCurrentImage(channel,2);
                else
                    I2=updateCurrentImage(channel,1);
                end
                setZoomValue(initialzoom);
                ua.zoomedOut=false;
                obj.allPositionsDS.refImgZoomOut(obj.allPositionsDS.posID==posID)={I2};
                hasRefZoomOut=true;
            end
            obj.allPositionsDS.refImg(obj.allPositionsDS.posID==posID)={I};
            obj.allPositionsDS.hasRef(obj.allPositionsDS.posID==posID)=true;
            obj.allPositionsDS.hasRefZoomOut(obj.allPositionsDS.posID==posID)=hasRefZoomOut;
        end
        
        function clearFOV(obj)
            obj.allPositionsDS.FOVnum(:)=0;
            obj.allPositionsDS.scanShiftFast(:)=0;
            obj.allPositionsDS.scanShiftSlow(:)=0;
            obj.allPositionsDS.scanRotation(:)=0;
            obj.fovDS=obj.emptyFOVdataset();
        end
        
        function posnXYZ = getPosCoordinates(obj)
            global state
            posnXYZ=zeros(size(obj.allPositionsDS,1),3);
            for i=1:size(obj.allPositionsDS,1)
                j=obj.allPositionsDS.posID(i);
                ts=state.hSI.positionDataStructure(j);
                posnXYZ(i,1)=ts.motorX;
                posnXYZ(i,2)=ts.motorY;
                posnXYZ(i,3)=ts.motorZ;
            end
        end
        
        function saveNewFOV(obj,pos)
            ind=size(obj.fovDS,1)+1;
            obj.fovDS.motorX(ind,1) = pos(1);
            obj.fovDS.motorY(ind,1) = pos(2);
            obj.fovDS.Xvertices(ind,1) = pos(3);
            obj.fovDS.Yvertices(ind,1) = pos(4);
        end
        
        function translateMotorToScanningROIs(obj) %translates the motor
            %positions to scan angle ROIs, but keeps the Z value and stuff intact.
            global ua dia
            obj.fovDS = obj.emptyFOVdataset();
            ofst=[dia.hPos.posXYZ_graph_offset(1) dia.hPos.posXYZ_graph_offset(2) 0 0];
            imzoom = ua.params.initialZoom;
            fovwidth=ua.fov.fovwidth;
            fovheight=ua.fov.fovheight;
            posns = obj.allPositionsDS.posID;
            unusedP=true(size(posns)); %used in order to prevent duplicate imaging of positions in overlapping fields of view
            posnXYZ = getPosCoordinates(obj);
            fovNum=1;
            for i = find(isvalid(ua.fov.handles.fov))' %add FOVs and set included positions
                ds = obj.emptyFOVdataset(0);
                pos=getPosition(ua.fov.handles.fov(i))+ofst;
                hr=rectangle('Position',pos - ofst,'EdgeColor','k');
                ds.graphPosition = pos;
                ds.motorX = pos(1)+fovwidth/2;
                ds.motorY = pos(2)+fovheight/2;
                ds.Xvertices = [pos(1), pos(1), pos(1)+fovwidth, pos(1)+fovwidth, pos(1)];
                ds.Yvertices = [pos(2), pos(2) + fovheight, pos(2) + fovheight, pos(2), pos(2)];
                %find positions inside FOV
                in=inpolygon(posnXYZ(:,1),posnXYZ(:,2),ds.Xvertices,ds.Yvertices);
                incPosInd=(unusedP & in); %unused positions which are included
                unusedP(in)=false; %update unused positions list
                obj.allPositionsDS.FOVnum(incPosInd,1) = fovNum;
                obj.fovDS=vertcat(obj.fovDS,ds);
                ua.fov.handles.fovFixed(fovNum)=hr;
                delete(ua.fov.handles.fov(i));
                fovNum=fovNum+1;
            end
            %set scanning parameters for individual positions
            for i=1:size(obj.fovDS,1)
                ind=find((obj.allPositionsDS.FOVnum == i));
                for j=1:length(ind)
                    posX=obj.fovDS.motorX(i,1) - fovwidth/2 - posnXYZ(ind(j),1) + fovwidth/imzoom/2; % scanshift is inverse to X direction
                    posY=obj.fovDS.motorY(i,1) - fovheight/2 - posnXYZ(ind(j),2) + fovheight/imzoom/2;
                    pos= [-posX -posY fovwidth/imzoom fovheight/imzoom];
                    [ scanShiftFast, scanShiftSlow, scanRotation, ~, ~, newZoomFactor] = scanShiftCalc( pos );
                    obj.allPositionsDS.scanShiftFast(ind(j),1) = -scanShiftFast;
                    obj.allPositionsDS.scanShiftSlow(ind(j),1) = -scanShiftSlow;
                    obj.allPositionsDS.scanRotation(ind(j),1) = scanRotation;
                    obj.allPositionsDS.zoomVal(ind(j),1) = newZoomFactor;
                end
            end
            
            updateUAgui;
            disp('Positions Set to FOV');
        end
        
        function moveToNewScanAngle(obj, posID, setZoom )
            %moves the scanning ROI to a particular position
            global state
            if nargin<3
                setZoom=false;
            end
            posnXYZ = getPosCoordinates(obj);
            ind = obj.allPositionsDS.posID==posID;
            fovNum=obj.allPositionsDS.FOVnum(ind);
            motorX = obj.fovDS.motorX(fovNum,1);
            motorY = obj.fovDS.motorY(fovNum,1);
%             disp('Moving To ');
%             disp([motorX,motorY,posnXYZ(ind,3)]);
            motorOrETLMove([motorX,motorY,posnXYZ(ind,3)],1);
            if setZoom
                setZoomValue(obj.allPositionsDS.zoomVal(ind));
            end
            scanParams = {'scanShiftFast' 'scanShiftSlow' 'scanRotation'};
            for i = 1:length(scanParams)
                state.acq.(scanParams{i})= obj.allPositionsDS.(scanParams{i})(ind);
                updateGUIByGlobal(['state.acq.' scanParams{i}]);
            end
            setScanProps; %needed to reset scanning shift
        end
        
        function moveToNewMotorPosition(obj,posID)
            global state
            %check if already at position
            posnXYZ = getPosCoordinates(obj);
            ind=obj.allPositionsDS.posID==posID;
            currentXYZpos = obj.getMotorAndEtlPosition();
            currentposID=state.hSI.zprvPosn2PositionID(currentXYZpos);
            %if not, move
            if currentposID==0 || currentposID~=posID
                motorOrETLMove(posnXYZ(ind,:));
            end
        end
        
        function deletePosition(obj,posID)
            global state
            obj.allPositionsDS(obj.allPositionsDS.posID==posID,:)=[];
            if isfield(obj.imagingTimers,'timer');
                ind = [obj.imagingTimers.posID] == posID;
                stop(obj.imagingTimers(ind).timer);
                delete(obj.imagingTimers(ind).timer);
                obj.imagingTimers(ind) = [];
                setWorkingPositions(obj);
            end
            state.hSI.roiRemovePosition(posID);
        end
        
        function updateZRoof(obj,posID,motorZ)
            posnXYZ = getPosCoordinates(obj);
            ind = obj.allPositionsDS.posID==posID;
            obj.allPositionsDS.zRoofOffset(ind) = posnXYZ(ind,3) - motorZ;
        end
        
        function makeTableForGUIs(obj,h,tableNum)
            if ~ishandle(h)
                return
            end
            cNames={'Position','Spine','Z Depth','Ref Img', 'Ref Img 2','FOV','Step'};
            cWidth={48 45 60 51 51 40 70};
            cDataType={'char', 'char', 'char', 'char', 'char', 'char','char'};
            ds=obj.allPositionsDS;
            uidata=num2cell([ds.posID,ds.roiNum,ds.zRoofOffset,ds.hasRef,ds.hasRefZoomOut, ds.FOVnum]);
            if isempty(uidata) %if empty, create empty array to avoid errors
                uidata=cell(0,length(cWidth));
            end
            switch tableNum
                case 1
                    cOrder=[1,2,3,6];
                case 2
                    cOrder=[1,4,5];
            end
            
            if isfield(obj.imagingTimers,'activeTimerInd') %indicate which timer is active for the position
                [Loca,Locb] = ismember(ds.posID,[obj.imagingTimers.posID]);
                ind = Locb(Locb>0);
                steps = cell(size(Loca));
                steps(Loca) = {obj.imagingTimers(ind).activeTimerInd}';
                stepInd=~cellfun(@isempty,steps);
                if ~isempty(find(stepInd,1))  %if steps isn't empty
                    tNames={obj.timelineSetup.name};
                    steps(stepInd) = tNames([steps{stepInd}]);
                    uidata=[uidata,steps];
                    if tableNum==1
                        cOrder=[1,2,3,6,7];
                    end
                end
            end
            
            set(h,'ColumnName',cNames(cOrder));
            set(h,'data',uidata(:,cOrder));
            set(h,'ColumnWidth',cWidth(cOrder));
            set(h,'ColumnFormat',cDataType(cOrder));
        end
        
        function makeImagingTimers(obj,grabAndTime)
            if nargin<2
                grabAndTime=false;
            end
            global dia ua
            allPosIDs = obj.allPositionsDS.posID;
            if isempty(allPosIDs)
                error('No Current Positions Set');
            end
            for i=1:length(allPosIDs)
                obj.imagingTimers(i).posID = allPosIDs(i);
                obj.imagingTimers(i).startLater = false;
                for j=1:length(obj.timelineSetup)
                    timerInfo.posID = obj.imagingTimers(i).posID;
                    timerInfo.timerIndex = i;
                    timerInfo.timelineIndex = j;
                    timerInfo.singleRun = grabAndTime;
                    if strcmp(obj.timelineSetup(j).action,'Imaging')
                        totalSteps=obj.timelineSetup(j).steps;
                        period=obj.timelineSetup(j).period;
                        obj.imagingTimers(i).stepCountdown(j)=obj.timelineSetup(j).steps;
                        obj.imagingTimers(i).timer(j)=timer('StartDelay',.1,'StartFcn',@mdiaTimerStartFcn,'TimerFcn',@mdiaTimerFcn,'StopFcn',@mdiaTimerStopFcn,...
                            'TasksToExecute', totalSteps, 'Period',period,...
                            'ExecutionMode','fixedRate','Name',['mdiaPos',num2str(obj.imagingTimers(i).posID),'Timer',num2str(j)],'BusyMode','queue','UserData',timerInfo);
                    elseif strcmp(obj.timelineSetup(j).action,'Uncaging') %do uncaging with a timer to keep things consistent
                        obj.imagingTimers(i).stepCountdown(j)=1;
                        obj.imagingTimers(i).timer(j)=timer('StartDelay',.1,'StartFcn',@mdiaTimerStartFcn,'TimerFcn',@mdiaTimerFcn,'StopFcn',@mdiaTimerStopFcn,...
                            'ExecutionMode','singleShot','Name',['mdiaPos',num2str(obj.imagingTimers(i).posID),'Timer',num2str(j)],'BusyMode','queue','UserData',timerInfo);
                    end
                    if grabAndTime 
                        obj.imagingTimers(i).timer(1).TasksToExecute=1;
                        break
                    end
                end
            end
        end
        
        function staggerAndStartInitialPositions(obj,posns) %add tasks to first step of timers based on stagger counter
            global dia
            if nargin<2
                posns = obj.workingPositions';
                startTimers = true;
            else
                startTimers = false;
            end
            posInd = [obj.imagingTimers.posID];
            timerInd = [];
            for i = posns
                ind = find(i == posInd);
                timerInd=[timerInd,ind];
            end
            staggerCounter=0;
            for i = timerInd
                additionalTasks = obj.staggerTime * 60 / obj.imagingTimers(i).timer(1).Period * staggerCounter;
                obj.imagingTimers(i).timer(1).TasksToExecute =  obj.imagingTimers(i).timer(1).TasksToExecute + additionalTasks;
                obj.imagingTimers(i).stepCountdown(1) = obj.imagingTimers(i).timer(1).TasksToExecute;
                staggerCounter=staggerCounter+1;
            end
            for i = timerInd
                if startTimers %regular beginning
                    start(obj.imagingTimers(i).timer(1));
                else %timer being added on to already running timers
                    obj.imagingTimers(i).activeTimerInd = 1;
                    obj.imagingTimers(i).startLater = true;
                    if dia.acq.allowTimerStart %only start timer if exclusive mode or something isn't on, otherwise it'll start later
                        start(obj.imagingTimers(i).timer(obj.imagingTimers(i).activeTimerInd));
                    end
                end
            end
        end
                
        function addTimelineStep(obj,h,insertPos) %if insertPos has a value, the step is inserted at that index value
            if nargin>2 && ~isempty(insertPos)
                a = obj.timelineSetup(1:insertPos-1);
                c = obj.timelineSetup(insertPos:end);
            elseif nargin < 3
                insertPos = [];
            end
            ind=length(obj.timelineSetup)+1;
            obj.timelineSetup(ind).name = get(h.stepNameEdit,'String');
            if get(h.imagingRB,'value')
                obj.timelineSetup(ind).action='Imaging'; %imaging
                t = str2double(get(h.durationEdit,'String'));
                p = str2double(get(h.periodEdit,'String'));
                obj.timelineSetup(ind).steps = floor(t*60/p);
                obj.timelineSetup(ind).period = p;
                obj.timelineSetup(ind).exclusive = logical(get(h.exclusiveCB,'value'));
                obj.timelineSetup(ind).pageAcq = false;
            elseif get(h.uncagingRB,'value')
                pA=get(h.pageAcqCB,'Value');
                obj.timelineSetup(ind).pageAcq=pA;
                obj.timelineSetup(ind).action='Uncaging'; %uncaging
                obj.timelineSetup(ind).exclusive=true;
            end
            if ~isempty(insertPos)
                b = obj.timelineSetup(ind);
                obj.timelineSetup = [a, b c];
            end
            makeTimelineTableGui(obj,h);
        end
        
        function makeTimelineTableGui(obj,h)
            cNames={'Step Name','Action','Repeats','Period','Exclusive'};
            cWidth={90 70 45 45 51};
            cDataType={'char', 'char','char', 'char', 'logical'};
            tl=obj.timelineSetup';
            for i=1:length(tl)
                tl(i).pageAcq = logical(tl(i).pageAcq);
                if tl(i).pageAcq
                    tl(i).action = 'PageAcq';
                end
            end

            uidata=struct2cell(tl);
            if isempty(uidata) %if empty, create empty array to avoid errors
                uidata=cell(0,length(cWidth));
            else
                uidata=uidata';
            end
            cOrder = [1,5,3,4,2];
            set(h.timelineUIT,'ColumnName',cNames(cOrder));
            set(h.timelineUIT,'data',uidata(:,cOrder));
            set(h.timelineUIT,'ColumnWidth',cWidth(cOrder));
            set(h.timelineUIT,'ColumnFormat',cDataType(cOrder));
            
            drawTimeline(obj,h);
        end
        
        function drawTimeline(obj,h)
            global dia
            hAx=h.timelineAX;
            uncageTime=dia.acq.uncagingTimeEst;
            t=obj.timelineSetup;
            if isempty(t)
                return
            end
%             setWorkingPositions(obj);
%             posns = obj.workingPositions;
            posns = dia.hPos.allPositionsDS.posID(dia.hPos.allPositionsDS.FOVnum == min(dia.hPos.allPositionsDS.FOVnum));
%             posns = [1:5]'; %fake positions just for testing timeline graphic
            if isempty(posns)
                posns = 1:dia.acq.maxPositions;
            end
%             tTotal=sum([t.steps].*[t.period])...
%                 + uncageTime * length(strfind([t.action],'Uncaging'));
            elapsedTime=zeros(1,length(posns));
            nPosAll = length(posns);
            nPos = 1 : min(nPosAll,dia.acq.maxPositions); %max positions at a time
            %do stagger/exclusive thing, then add next set of positions, each at end
            %of another position, and do exclusive thing again. repeat
            %until out of positions.
            st=obj.staggerTime;
            n=nPosAll;
            while n > 0
                for j=1:length(t)
                    switch t(j).action
                        case 'Imaging'
                            for i=nPos
                                if i > dia.acq.maxPositions && j==1 %set elapsed time based on previously ending positions
                                    elapsedTime(i) = max([endTimes{i - dia.acq.maxPositions,:}]);
                                end
                                startTimes{i,j} = elapsedTime(i) + st*(i-1);
                                endTimes{i,j} = startTimes{i,j} +  t(j).steps * t(j).period / 60;
                                elapsedTime(i) = elapsedTime(i) + (endTimes{i,j}-startTimes{i,j}) + st*(i-1);
                                if j==1 && i <= dia.acq.maxPositions %start first round at 0
                                    startTimes{i,j}=0;
                                end
                            end
                            if t(j).exclusive
                                color(j)='g';
                            else
                                color(j)='b';
                            end
                        case 'Uncaging'
                            for i=nPos
                                if i > dia.acq.maxPositions && j==1 %set elapsed time based on previously ending positions
                                    elapsedTime(i) = elapsedTime(i - dia.acq.maxPositions);
                                end
                                startTimes{i,j} = elapsedTime(i) + st*(i-1);
                                endTimes{i,j} = startTimes{i,j} +  uncageTime / 60;
                                elapsedTime(i) = elapsedTime(i) + (endTimes{i,j}-startTimes{i,j}) +  + st*(i-1);
                                if j==1 && i <= dia.acq.maxPositions %start first round at 0
                                    startTimes{i,j}=0;
                                end
                            end
                            color(j)='r';
                    end
                    
                    st=0; %set stagger time to 0 for the rest of the steps
                    
                end
                
                %push timeline forward where there is exclusive imaging and
                %uncaging
                i=1;
                shiftIndex= [t.exclusive];
                while i<=max(nPos)
                    %             for i=1:nPos %run for each position
                    
                    for j=1:length(t)
                        %%%%%%%%%%% the thinking is that if j gets to a shiftindex of 0, it needs
                        %%%%%%%%%%% to move on to other positions because poking holes in the
                        %%%%%%%%%%% timeline shouldn't happen when the hole poker will shift
                        if ~shiftIndex(j) && i~=max(nPos)
                            break
                        elseif ~shiftIndex(j) && i==max(nPos)
                            i=0;
                            shiftIndex(j)=1;
                            break
                            %                     elseif shiftIndex(j) && i==nPos
                            
                        end
                        if t(j).exclusive
                            eventSize = endTimes{i,j}-startTimes{i,j};
                            for iCell=1:size(endTimes,1) %run for each row
                                if iCell==i %so positions don't interact with themselves
                                    continue
                                end
                                for jCell = 1:size(endTimes,2) %run for each column
                                    ind = (startTimes{i,j} < endTimes{iCell,jCell}) ...
                                        & (endTimes{i,j} > startTimes{iCell,jCell});
                                    ind=find(ind);
                                    for k=ind
                                        if t(jCell).exclusive
                                            %don't break up continuous events
                                            startTimes{iCell,jCell}=endTimes{i,j};
                                            endTimes{iCell,jCell} = endTimes{iCell,jCell} + eventSize;
                                        else
                                            startTimes{iCell,jCell}=[startTimes{iCell,jCell}(1:k), endTimes{i,j},startTimes{iCell,jCell}(k+1:end)];
                                            endTimes{iCell,jCell} = [endTimes{iCell,jCell}(1:k-1), startTimes{i,j}, endTimes{iCell,jCell}(k:end) + eventSize];
                                            sameVal=startTimes{iCell,jCell} == endTimes{iCell,jCell};
                                            startTimes{iCell,jCell}(sameVal) = [];
                                            endTimes{iCell,jCell}(sameVal) = [];
                                        end
                                        %shift future timeline events
                                        for jFuture=jCell+1:size(startTimes,2)
                                            startTimes{iCell,jFuture} = startTimes{iCell,jFuture} + eventSize;
                                            endTimes{iCell,jFuture} = endTimes{iCell,jFuture} + eventSize;
                                        end
                                        break %only need to shift stuff once...
                                    end
                                end
                            end
                        end
                    end
                    i=i+1;
                end
                %after the first set, add positions one at a time
                n = n - 1;
                nPos = (max(nPos) + 1);
                nPos(nPos>nPosAll) = [];
            end
            cla(hAx);
            for j=1:length(t)
                [patchHndls] = timeline(num2cell(posns),startTimes(:,j),endTimes(:,j),'facecolor',color(j),'Parent',hAx);
                hold(hAx,'on')
            end
            hold(hAx,'off')
            xlim(hAx,[0 max(max(cellfun(@max,endTimes)))]);
            [legend_handle,icons,~,~]=legend(hAx,'Imaging','Exclusive Imaging','Uncaging');
            legend_markers = findobj(icons,'Type', 'Patch');
            for i = 1:length(legend_markers)
                switch legend_markers(i).Tag
                    case 'Imaging'
                        set(legend_markers(i), 'FaceColor','b');
                    case 'Exclusive Imaging'
                        set(legend_markers(2), 'FaceColor', 'g');
                    case 'Uncaging'
                        set(legend_markers(3), 'FaceColor', 'r');
                end
            end
            xlabel(hAx,'Time (min)');
            ylabel(hAx,'Position');        
        end
        
        function createFolders(obj)
            global state
            for i = obj.allPositionsDS.posID' % make dirs for all positions. if dir exists and has files in it, create a new one.
                ind = [obj.imagingTimers.posID] == i;
                obj.imagingTimers(ind).savePath = cell(1,length(obj.timelineSetup)); %savePath is under imagingTimers struct since it's easy to add stuff to it
                for j=1:length(obj.timelineSetup)
                    obj.imagingTimers(ind).savePath{j} = [state.files.savePath, '\Position', ...
                        num2str(obj.imagingTimers(ind).posID),'\',num2str(j),'_',genvarname(obj.timelineSetup(j).name)];
                    if ~exist(obj.imagingTimers(ind).savePath{j},'dir')
                        mkdir(obj.imagingTimers(ind).savePath{j});
                    end
                end
                obj.imagingTimers(ind).acqNum=1;
            end
        end
    end
    
    methods(Static)
        
        function xyzPos = getMotorAndEtlPosition() %update motor position and make sure ETL value is considered
            global dia state
            motorGetPosition();
            if dia.etl.acq.etlOn
                state.motor.absZPosition=state.motor.absZPosition+etlVoltToMotorZCalc;
            end
            xyzPos = [state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition];
        end
        
        function ds = emptyPositionDataset(defaultValue)
            if nargin<1
                defaultValue=[];
            end
            %initialize/reset position dataset
            %add all variables to struct S
            S.posID=defaultValue;
            S.roiNum=defaultValue;
            S.hasRef=defaultValue;
            S.hasRefZoomOut=defaultValue;
            S.zoomVal=defaultValue;
            S.zRoofOffset=defaultValue;
            S.motorZ=defaultValue;
            S.FOVnum=defaultValue;
            S.scanShiftFast=defaultValue;
            S.scanShiftSlow=defaultValue;
            S.scanRotation=defaultValue;
            S.zDrift = defaultValue;
            S.scanShiftFastDrift = defaultValue;
            S.scanShiftSlowDrift = defaultValue;
            S.roiPosition={defaultValue};
            S.refImg={defaultValue};
            S.refImgZoomOut={defaultValue};
            %different rule for cells
            if isempty(defaultValue)
                S.roiPosition={};
                S.refImg={};
                S.refImgZoomOut={};
            end
            %transform struct S to dataset for easier indexing
            ds=struct2dataset(S);
        end
        
        function ds = emptyFOVdataset(defaultValue)
            %initialize FOV dataset
            if nargin<1
                defaultValue=[];
            end
            Sf.motorX=defaultValue;
            Sf.motorY=defaultValue;
            Sf.Xvertices=(defaultValue);
            Sf.Yvertices=(defaultValue);
            Sf.graphPosition = (defaultValue);
            %transform struct Sf to dataset for easier indexing
            ds = struct2dataset(Sf);
        end
        
        
    end
    
end

