function displayAFimages(imageHolder,afPosition,afRoi)
%function to show AF images to user. Show minimized images together with spine area highlighted and best focus image selected.
global state af ua dia

imsize=[state.acq.pixelsPerLine,state.acq.linesPerFrame]; % figure out image height and width
imsize= [max(imsize), max(imsize)]; %make images square if they are not

if nargin<4
    try
        if isfield(ua,'zoomedOut') && ua.zoomedOut
            zoomscale=ua.zoomscale;
            rw=imsize(1)/(zoomscale/2);
            rh=imsize(2)/(zoomscale/2);
            afRoi=round([imsize(1)/2-rw/2, imsize(2)/2-rh/2, rw, rh]);
        elseif isfield(af,'closestspine')
            afRoi = [af.closestspine.x1-af.roisize/2,af.closestspine.y1-af.roisize/2,af.roisize,af.roisize];
        end
    catch ME
        getReport(ME);
    end
end

if nargin<3
    imageHolder = af.images;
    afPosition = af.position;
end
af.images=[];
af.position=[];

try
    if af.params.displaytoggle && af.params.isAFon && ~isempty(imageHolder) % make sure display images is activated
        % check if figure exists. if not, make it. if yes, select it.
        if ~ishandle(af.afDispHandle) || ~strcmp(get(af.afDispHandle,'name'),'Autofocus Results')
            af.afDispHandle = figure;
            %            af.afDispAxis = axes('parent',af.afDispHandle);
        else
            %             figure(af.afDispHandle);
        end
        set(af.afDispHandle,'numbertitle','off','name','Autofocus Results');
        set(af.afDispHandle,'MenuBar','None');
        set(af.afDispHandle,'Units','pixels','Position',[300,300,imsize(1)*length(imageHolder)*1.02,imsize(2)]);
        for i=1:length(imageHolder)
            s = subaxis(1,length(imageHolder),i, 'Spacing', 0.002, 'Padding', 0, 'Margin', 0,'Parent',af.afDispHandle);
            imagesc(imageHolder{i},'Parent',s);
            colormap(s,gray);
            %show ROI
            rectangle('Position',afRoi,'EdgeColor','r','Parent',s);
            if i==af.bestfocus
                rectangle('Position',[4,4,imsize-4],'EdgeColor','g','LineWidth',4,'Parent',s);
            end
            text(10,10,['Z: ' num2str(afPosition.af_list_abs_z(i))],'Color','r','Parent',s);
            axis(s, 'tight');
            axis(s,'off');
        end
        
    end
    %clear AF values for next iteration
catch ME
    %     disp(ME.stack);
    disp(getReport(ME));
    %     throw(ME);
end

end

