function arrangeFigures( handles )
%arrangeFigures( handles ) tightly arranges all figures on the screen.
%Multiple monitors are supported. This function requires the image
%processing toolbox.
%
% handles (optional) is an array of figure handles. By default, all visible
% figures will be used.
%
% Created by Michael (Misha) Smirnov, August 2015, Max Planck Florida Institute
% for Neuroscience
if nargin<1
    handles=findall(0,'Type','Figure','Visible','on');
end

drawnow;
sysUnits=get(0,'Units');
set(0,'Units','characters');
monitorPositions = round(get(0,'MonitorPositions'));
monitorPositions=sortrows(monitorPositions,1);
minWidth=min(min(monitorPositions(:,[1, 3])));
screenWidth=abs(min(min(monitorPositions(:,[1, 3])))-max(max(monitorPositions(:,[1, 3]))));
screenHeight=abs(min(min(monitorPositions(:,[2, 4])))-max(max(monitorPositions(:,[2, 4]))));
screenVirtual=ones(screenHeight,screenWidth);

a=cell(1,size(monitorPositions,1));
b=cell(1,size(monitorPositions,1));
for j=1:size(monitorPositions,1)
    a{j}= monitorPositions(j,2)+1 : monitorPositions(j,4) +1;
    b{j}= monitorPositions(j,1)-minWidth+1 : monitorPositions(j,3)-minWidth+1;
end

placed=zeros(1,length(handles));
for k=1:length(a)
    screenVirtual(a{k} , b{k})=0;
    if k>1
        screenVirtual(a{k-1} , b{k-1})=1;
    end
    for i = 1:length(handles)
        if placed(i) %if figure has not been placed yet
            continue
        end
        oldUnits=get(handles(i),'Units');
        set(handles(i),'Units','characters');
        oldPos=round(get(handles(i),'OuterPosition'));
        seLineVert=strel('line',oldPos(3),90);
        seLineHorz=strel('line',oldPos(4),0);
        seRec=strel('rectangle',[oldPos(4),oldPos(3)]);
        screenVirtual2=imopen(~screenVirtual,seRec);
        screenVirtual2=imopen(screenVirtual2,seLineVert);
        screenVirtual2=imopen(screenVirtual2,seLineHorz);
        screenVirtual2=imopen(screenVirtual2,seRec);
        [col,row]=find(screenVirtual2'==1,1);
        if ~isempty(col)
            placed(i)=1;
        else
            continue
        end
        
        newPos=[col-1+minWidth,screenHeight-row-oldPos(4)+1,oldPos(3),oldPos(4)];
        set(handles(i),'OuterPosition',newPos,'Units',oldUnits);
        screenVirtual(row:row+oldPos(4),col:col+oldPos(3))=1;
        
    end
    
end

if ~isempty(find(placed==0,1))
    disp('Note - not all figures could be placed');
end
set(0,'Units',sysUnits);

end

