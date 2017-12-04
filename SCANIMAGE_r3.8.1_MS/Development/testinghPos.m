clear obj hPos
obj=mdiaPositionClass;
obj.initialize;

%%
for i=1:3
    obj.allPositionsDS.posID(i,1)=i;
end
% obj.allPositionsDS.FOVnum([1;2],:)=1
% obj.clearFOV

%%
hPos = obj;

%% timers...
for i=1:3
    tm(i)=timer('BusyMode','queue','ExecutionMode','FixedRate','Name',['spineTimer',num2str(i)],...
        'Period',.5,'TimerFcn',@mdiaTimerFcn,'StopFcn','disp(''Stopped Timer One'')',...
        'TasksToExecute',10,'StartDelay',1,'UserData',i);
end
t2=timer('BusyMode','queue','ExecutionMode','FixedRate','Name','spineTimer2',...
    'Period',2,'TimerFcn','disp(''timerTwo''),pause(1)','StopFcn','disp(''Stopped Timer Two'')',...
    'TasksToExecute',0,'StartDelay',1);

t3=timer('BusyMode','queue','ExecutionMode','FixedRate','Name','spineTimer3',...
    'Period',2,'TimerFcn','disp(''timerThree''),pause(1)','StopFcn','disp(''Stopped Timer Two'')',...
    'TasksToExecute',10,'StartDelay',1);

start(tm);
start(t2);
start(t3);


delete(tm(:));
delete(t2);
delete(t3);
%%
