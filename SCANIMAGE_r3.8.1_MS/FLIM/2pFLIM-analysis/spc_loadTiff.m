function error = spc_loadTiff (fname)
global spc;
global gui;


error = 0;
finfo = imfinfo (fname);
header = finfo(1).ImageDescription;
pages = 1:length(finfo);
spc.stack.image1 = {};
stack_project = [];
if findstr(header, 'spc')
    delim = strfind(header, ';');
    evalc(header(1:delim(1)));
    for j=1:length(delim)-1
        try
            evalc(header(delim(j)+1:delim(j+1)));
        catch
            header(delim(j)+1:delim(j+1));
        end
    end
    %evalc(header);
    spc.switches.noSPC = 0;
    spc.datainfo.scan_y = spc.SPCdata.scan_size_y*spc.SPCdata.scan_rout_x;
    spc.datainfo.scan_rx = spc.SPCdata.scan_rout_x;
    try
        spc.datainfo.scan_ry = spc.SPCdata.scan_rout_y;
    catch
        spc.datainfo.scan_ry = 1;
    end
    spc.size = [spc.size(1), spc.datainfo.scan_y, spc.datainfo.scan_x];
    for i=1:length(pages)
        image1 = double(imread(fname, pages(i)));
        image1 = reshape(image1, spc.size);
        spc.stack.image1{i} = uint16(image1);
        stack_project = [stack_project, reshape(sum(image1, 1), spc.size(2), spc.size(3))];
    end
    size2 = size(image1);
    spc.stack.project = reshape(stack_project, spc.size(2), spc.size(3), length(pages));
    spc.stack.nStack = length(pages);
    if spc.stack.nStack > 1
        set(gui.spc.spc_main.slider1, 'enable', 'on');
        set(gui.spc.spc_main.minSlider, 'enable', 'on');
        set(gui.spc.spc_main.slider1, 'min', 1, 'max', spc.stack.nStack);
        set(gui.spc.spc_main.minSlider, 'min', 1, 'max', spc.stack.nStack);
        set(gui.spc.spc_main.slider1, 'sliderstep', [1/(spc.stack.nStack-1), 1/(spc.stack.nStack-1)]);
        set(gui.spc.spc_main.minSlider, 'sliderstep', [1/(spc.stack.nStack-1), 1/(spc.stack.nStack-1)]);
        set(gui.spc.spc_main.slider1, 'value', spc.stack.nStack);
        set(gui.spc.spc_main.minSlider, 'value', 1);
    else
        set(gui.spc.spc_main.slider1, 'enable', 'off');
        set(gui.spc.spc_main.minSlider, 'enable', 'off');
        set(gui.spc.spc_main.slider1, 'min', 0, 'max', 1);
        set(gui.spc.spc_main.minSlider, 'min', 0, 'max', 1);
        set(gui.spc.spc_main.slider1, 'sliderstep', [1,1]);
        set(gui.spc.spc_main.minSlider, 'sliderstep', [1,1]);
    end
    set(gui.spc.spc_main.spc_page, 'String', num2str([1:spc.stack.nStack]));
    

else
    disp('This is not a spc file !!');
    error = 2;
    return;
end
spc.filename = fname;
%spc.size = [spc.size(1), spc.datainfo.scan_y, spc.datainfo.scan_x];
spc.page = [1:spc.stack.nStack];


