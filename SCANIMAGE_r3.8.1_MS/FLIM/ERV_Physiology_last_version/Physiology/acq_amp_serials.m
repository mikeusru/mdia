function acq_amp_serials

%Physiology scope software
%Emiliano Rial Verde
%October 2006
%
%Function to select Multiclamp 700 Amplifiers

a=dir('C:\Program Files\acq\amps');
amp_serials=[];
for i=1:size(a,1)
    if a(i).isdir==0
        if isempty(strfind(a(i).name, '_1.txt'))
        else
            s=a(i).name;
            amp_serials=[amp_serials; s(1:end-6)];
        end
    end
end
ok=0;
while ok==0
    [selection,ok] = listdlg('ListString', amp_serials, 'Name', 'Select Amps', 'ListSize', [150 100]);
    if length(selection)>2
        ok=0;
        errordlg('Slect a maximum of 2 amplifiers!', 'Selection Error');
    end
end
if length(selection)==1
    amp_serials=[amp_serials(selection, :); 'no_ampli'];
else
    amp_serials=amp_serials(selection, :);
end
txt=fopen('C:\Program Files\acq\amps\amp_serials.erv', 'wt');
fprintf(txt, '%s\n', amp_serials(1,:));
set(findobj('Tag', 'amp1serialtext'), 'String', amp_serials(1,:));
fprintf(txt, '%s', amp_serials(2,:));
set(findobj('Tag', 'amp2serialtext'), 'String', amp_serials(2,:));
fclose(txt);

