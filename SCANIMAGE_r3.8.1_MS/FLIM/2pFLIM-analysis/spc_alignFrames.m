function spc_alignFrames
global spc gui
%global tmp

spc.page = 1;

set(gui.spc.spc_main.spc_page, 'String', num2str(spc.page));
spc_redrawSetting(1);
if ~spc.switches.noSPC
    saveProject = spc.stack.project(:, :, spc.page);
else
    saveProject = spc.state.img.redImg(:,:,spc.page);
end

%header1 = sprintf('ImageJ=1.46r\nimages=%d\nchannels=%d\nslices=%d\nhyperstack=true\nmode=composite\n',  spc.stack.nStack, 2, spc.stack.nStack*2);
header1 = spc.state.header;

[pn, fn] = fileparts(spc.filename);

%greenFile = [pn, filesep, fn, '_Composite_MC.tif'];
greenFile = [pn, filesep, fn, '_green_MC.tif'];
redFile = [pn, filesep, fn, '_red_MC.tif'];

imwrite(uint16(spc.state.img.greenImg(:,:,spc.page)), greenFile, 'compression', 'none', ...
    'WriteMode', 'overwrite', 'Description', header1);
% imwrite(uint16(spc.state.img.redImg(:,:,spc.page)), greenFile, 'compression', 'none', ...
%     'WriteMode', 'append', 'Description', header1);
imwrite(uint16(spc.state.img.redImg(:,:,spc.page)), redFile, 'compression', 'none', ...
    'WriteMode', 'overwrite', 'Description', header1);

for i=2:spc.stack.nStack
%     set(gui.spc.spc_main.spc_page, 'String', num2str(i));
%     spc_redrawSetting(1);
    if ~spc.switches.noSPC
        project1 = spc.stack.project(:, :, i);
    else
        project1 = spc.state.img.redImg(:,:,i);
    end
    frac1 = 1/5;
    frac2 = 4/5;
    C = xcorr2(saveProject, project1(round(spc.size(2)*frac1):round(spc.size(2)*frac2), ...
        round(spc.size(3)*frac1):round(spc.size(3)*frac2)));
    [value1, index1] = max(C(:));
    [siz_x, siz_y] = size(C);
    
    index_x = floor(index1 / siz_y) + 1;
    index_y = index1 - (index_x-1) * siz_y;
    shift_x = index_x - (siz_x + 1)/2;
    shift_y = index_y - (siz_y + 1)/2;
    

    spc_shiftSPC2(round([shift_y, shift_x]-0.5), i);
    
    pause(0.03);
    imwrite(uint16(spc.state.img.greenImg(:,:,i)), greenFile, 'compression', 'none', ...
    'WriteMode', 'append', 'Description', header1);
    pause(0.03);
    imwrite(uint16(spc.state.img.redImg(:,:,i)), redFile, 'compression', 'none', ...
    'WriteMode', 'append', 'Description', header1);
    
    set(gui.spc.spc_main.spc_page, 'String', num2str(i));
    spc_redrawSetting(1);
    
%     tmp.shiftX(i) = shift_x;
%     tmp.shiftY(i) = shift_y;
end



end


function spc_shiftSPC2(shift, imageN)

global spc

sizR = size(spc.state.img.redMax);
if ~spc.switches.noSPC
    siz = size(spc.imageMod);
end
if shift(1) > 0
    if ~spc.switches.noSPC
        spc.stack.image1{imageN}(:, 1+shift(1):siz(2), :) = spc.stack.image1{imageN}(:, 1:siz(2)-shift(1), :);
    end
    spc.state.img.greenImg(1+shift(1):sizR(1), :, imageN) = spc.state.img.greenImg(1:sizR(1)-shift(1), :, imageN);
    spc.state.img.redImg(1+shift(1):sizR(1), :, imageN) = spc.state.img.redImg(1:sizR(1)-shift(1), :, imageN);
else
    shift(1) = -shift(1);
    if ~spc.switches.noSPC
        spc.stack.image1{imageN}(:, 1:siz(2)-shift(1), :) = spc.stack.image1{imageN}(:, 1+shift(1):siz(2), :);
    end
    spc.state.img.greenImg(1:sizR(1)-shift(1), :, imageN) = spc.state.img.greenImg(1+shift(1):sizR(1), :, imageN);
    spc.state.img.redImg(1:sizR(1)-shift(1), :, imageN) = spc.state.img.redImg(1+shift(1):sizR(1), :, imageN);
end


if shift(2) > 0
    if ~spc.switches.noSPC
        spc.stack.image1{imageN}(:, :, 1+shift(2):siz(3)) = spc.stack.image1{imageN}(:, :, 1:siz(3)-shift(2));
    end
    spc.state.img.greenImg(:, 1+shift(2):sizR(2), imageN) = spc.state.img.greenImg(:, 1:sizR(2)-shift(2), imageN);
    spc.state.img.redImg(:, 1+shift(2):sizR(2), imageN) = spc.state.img.redImg(:, 1:sizR(2)-shift(2), imageN);
else
    shift(2) = -shift(2);
    if ~spc.switches.noSPC
        spc.stack.image1{imageN}(:, :, 1:siz(3)-shift(2), :) = spc.stack.image1{imageN}(:, :, 1+shift(2):siz(3));
    end
    spc.state.img.greenImg(:, 1:sizR(2)-shift(2), imageN) = spc.state.img.greenImg(:, 1+shift(2):sizR(2), imageN);
    spc.state.img.redImg(:, 1:sizR(2)-shift(2), imageN) = spc.state.img.redImg(:, 1+shift(2):sizR(2), imageN);
end
end