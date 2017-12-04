function acq_findfile(x)

%Physiology scope software
%Emiliano Rial Verde
%October-November 2005
%Updated for better performance in Matlab 2006a. November 2006
%
%Function to browse for files

switch x
    case 1
        name='comch1';
        type='AO #1';
    case 2
        name='comch2';
        type='AO #2';
    case 3
        name='comch3';
        type='AO #3';
    case 4
        name='comch4';
        type='AO #4';
    case 5
        name='?';
end

if strcmp(name, '?')
    cd([get(findobj('Tag', 'recfiletext'), 'UserData'), '\']);
    [filename, pathname]=uiputfile('*.dat', 'Select or create a file for acquisition', [datestr(date, 'mmddyy'), '_.dat']);
    cd([matlabroot, '\work']);
    if filename==0
    else
        a=fopen([matlabroot, '\work\Physiology\dat_directory_name.erv'], 'w+');
        fprintf(a, '%s', pathname(1:end-1));
        fclose(a);
        set(findobj('Tag', 'recfiletext'), 'String', filename);
        set(findobj('Tag', 'recfiletext'), 'UserData', pathname);
        set(findobj('Tag', 'recfiletext'), 'ToolTipString', [pathname, filename]);
    end
else
    if strcmp(get(findobj('Tag', [name, 'edit']), 'String'), 'nan')
        errordlg('Please select a valid value for the corresponding channel');
    else
        [filename, pathname]=uigetfile('C:\Program Files\acq\stims\*.mat', 'Select stimulation file');
        if filename==0
            set(findobj('Tag', [name, 'edit']), 'String', 'nan');
        else
            set(findobj('Tag', [name, 'text']), 'String', filename);
            set(findobj('Tag', [name, 'text']), 'UserData', pathname);
            set(findobj('Tag', [name, 'text']), 'ToolTipString', ['Stim. file for ', type, ': ', pathname, filename]);
        end
    end
end