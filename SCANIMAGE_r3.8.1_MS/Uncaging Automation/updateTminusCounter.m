function updateTminusCounter( seconds )
%updateTminusCounter( seconds ) updates the tminusText counter in mdia

global dia

if seconds<60
    set(dia.handles.mdia.tminusText,'String',[num2str(round(seconds)),' sec']);
else
    set(dia.handles.mdia.tminusText,'String',[num2str(round(seconds/60)),' min']);
end

end

