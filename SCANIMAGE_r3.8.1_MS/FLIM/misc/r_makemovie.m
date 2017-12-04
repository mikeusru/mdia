function r_makemovie(basename, numbers, montage, movie);
global gui
global spc

%%%%%%%%%%%%%%
% Making montage for FLIM. Movie file is crappy.
%%%%%%%%%%%%

if nargin == 3
    movie = 0;
end
%handles = gui.spc.lifetimerange;
% 
% up = str2num(get(handles.upper, 'String'));
% lw = str2num(get(handles.lower, 'String'));
% thresh = str2num(get(handles.spc_thresh, 'String'));
% thresh2 = str2num(get(handles.spc_lowthresh, 'String'));
% range1 = [lw, up];

if movie
    mov_name = ['anim-', basename, '.avi'];
%    mov = avifile(mov_name, 'fps', 2);
end


j = 1;
fig_h = figure;
	for i=numbers
        str1 = '000';
        str2 = num2str(i);
        str1(end-length(str2)+1:end) = str2;
        filename1 = [basename, str1, '_max.tif']
        filename2 = [basename, str1, '.tif'];
        if exist(filename1)
            spc_opencurves(filename1);
        elseif exist(filename2)
            spc_opencurves(filename2);
        else
            disp('No such file');
        end
        spc_updateMainStrings;
        spc_smooth(2);
        spc_drawLifetimeMap(0);
		spc_redrawSetting;
        figure(fig_h);
        subplot(montage(1), montage(2), j);
        image(spc.rgbLifetime);
        set(gca, 'XTickLabel', '', 'YTickLabel', '');
        if movie
            F = getframe(gca);
            mov = addframe(mov,F);
        end
        j = j+1;
	%     if j == 1
	%         imwrite(spc.rgbLifetime, 'animation.tif', 'format', 'tif', 'WriteMode', 'overwrite', 'Compression', 'none');
	%     else
	%          imwrite(spc.rgbLifetime, 'animation.tif', 'format', 'tif', 'WriteMode', 'append', 'Compression', 'none');
	%     end
    end

if movie
    mov = close(mov);
end
% spc_colorbar([lw, up]);
% set(handles.upper, 'String', num2str(up));
% set(handles.lower, 'String', num2str(lw));
% set(handles.spc_thresh, 'String', num2str(thresh));
% set(handles.spc_lowthresh, 'String', num2str(thresh2));