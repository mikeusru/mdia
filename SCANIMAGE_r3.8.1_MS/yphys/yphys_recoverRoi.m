function yphys_recoverRoi
global gh
try
    if ~isempty(findobj('Tag', '1'))
        hroi = gh.yphys.figure.yphys_roi(1);
        set(hroi, 'visible', 'off');
        set(hroi, 'visible', 'on');
    else
        return;
    end
end
for i = 1:4
    try
        hroi = gh.yphys.figure.yphys_roi2(1, i);
        set(hroi, 'visible', 'off');
        set(hroi, 'visible', 'on');
    end
end
for i = 1:4
    try
        hroi = gh.yphys.figure.yphys_roi3(1, i);
        set(hroi, 'visible', 'off');
        set(hroi, 'visible', 'on');
    end
end