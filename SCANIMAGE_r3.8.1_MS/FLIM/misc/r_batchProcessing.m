function r_BatchProcessing(basename, numbers);
global gui
global spc



j = 1;
for i=numbers
    str1 = '000';
    str2 = num2str(i);
    str1(end-length(str2)+1:end) = str2;
    filename1 = [pwd, '\', basename, str1, '_max.tif'];
    filename2 = [pwd, '\', basename, str1, '.tif'];
    if exist(filename1)
        spc_opencurves(filename1);
    elseif exist(filename2)
        spc_opencurves(filename2);
    else
        disp('No such file');
    end
    spc_auto(1) ;      

    j = j+1;
end
