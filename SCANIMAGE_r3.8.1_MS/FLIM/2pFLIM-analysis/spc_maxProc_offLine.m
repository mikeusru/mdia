function spc_maxProc_offLine
global spc;
global gui;

page = str2num(get(gui.spc.spc_main.spc_page, 'String'));
if isempty(page)
    page = 1;
end
spc.page = page;

stack_project = [];
for i = 1:length(spc.stack.image1)
    stack_project = [stack_project, reshape(sum(spc.stack.image1{i}, 1), size(spc.stack.image1{1}, 2), size(spc.stack.image1{1}, 3))];
end
spc.stack.project = reshape(stack_project, size(spc.stack.image1{1}, 2), size(spc.stack.image1{1}, 3), length(spc.stack.image1));

if ~spc.switches.noSPC
    if all(page <= size(spc.stack.project, 3))
        [maxP, index_max] = max(spc.stack.project(:,:,page), [], 3);
    else
        page = 1:size(spc.stack.project, 3);
        spc.page = page;
        [maxP, index_max] = max(spc.stack.project(:,:,1:end), [], 3);
        set(gui.spc.spc_main.n_of_pages, 'string', num2str(spc.stack.nStack));
        set(gui.spc.spc_main.spc_page, 'String', num2str(page));
    end
    siz = size(spc.stack.image1{1});
    stack_max = zeros(siz);
    stack_max = stack_max(:);

    for i=1:length(page)
        %index = (index_max == page(i));
        if ~spc.switches.maxAve
            index = (index_max == i);
            siz_index = size(index);
            index = repmat (index(:), [1,siz(1)]);
            index = reshape(index, siz_index(1), siz_index(2), spc.size(1));
            index = permute(index, [3,1,2]);
            index = index(:);
            stack_max = stack_max + index .* double(spc.stack.image1{page(i)}(:));
        else
            stack_max = stack_max + double(spc.stack.image1{page(i)}(:));
        end
    end

    image1 = reshape(stack_max, siz);
    if spc.switches.maxAve
        image1 = image1 / length(page);
    end

    spc.imageMod = reshape(image1, siz);
    spc.project = reshape(sum(image1, 1), siz(2), siz(3));
end
%spc_redrawSetting;

try
    if ~spc.switches.maxAve
        if spc.switches.redImg
            spc.state.img.greenMax = max(spc.state.img.greenImg(:,:,page), [], 3);
            spc.state.img.redMax = max(spc.state.img.redImg(:,:,page), [], 3);
        end
    else
        if spc.switches.redImg
            spc.state.img.greenMax = mean(spc.state.img.greenImg(:,:,page), 3);
            spc.state.img.redMax = mean(spc.state.img.redImg(:,:,page), 3);
        end        
        
    end
    
end