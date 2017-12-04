function [a, bg] = spc_calcRoi_internal(a, bg, fn)
global gui spc

nRoi = length(gui.spc.figure.roiB);
for j = 1:nRoi
    if ishandle(gui.spc.figure.roiB(j));
        siz = spc.size;
        siz(2) = size(spc.project, 1);
        siz(3) = size(spc.project, 2);
        %siz(2) = siz(2) / nChannels;
        goodRoi = 1;
        if strcmp(get(gui.spc.figure.roiB(j), 'Type'), 'rectangle')
            ROI = get(gui.spc.figure.roiB(j), 'Position');
            tagA = get(gui.spc.figure.roiB(j), 'Tag');
            RoiNstr = tagA(6:end);
            
            theta = [0:1/20:1]*2*pi;
            xr = ROI(3)/2;
            yr = ROI(4)/2;
            xc = ROI(1) + ROI(3)/2;
            yc = ROI(2) + ROI(4)/2;
            x1 = round(sqrt(xr^2*yr^2./(xr^2*sin(theta).^2 + yr^2*cos(theta).^2)).*cos(theta) + xc);
            y1 = round(sqrt(xr^2*yr^2./(xr^2*sin(theta).^2 + yr^2*cos(theta).^2)).*sin(theta) + yc);
            ROIreg = roipoly(ones(siz(2), siz(3)), x1, y1);
        elseif strcmp(get(gui.spc.figure.roiB(j), 'Type'), 'line')
            xi = get(gui.spc.figure.roiB(j),'XData');
            yi = get(gui.spc.figure.roiB(j),'YData');
            ROIreg = roipoly(ones(siz(2), siz(3)), xi, yi);
            ROI = [xi(:), yi(:)];
        else
            ROI = 0;
            goodRoi = 0;
        end
        if goodRoi
            if j ~= 1
                if ~spc.switches.noSPC
                    bw = (spc.project >= spc.fit(gui.spc.proChannel).lutlim(1));
                    lifetimeMap = spc.lifetimeMap(bw & ROIreg);
                    %lifetimeMap = spc.lifetimeMap(ROIreg);
                    project = spc.project(bw & ROIreg);
                    lifetime = sum(lifetimeMap.*project)/sum(project);
                    
                    t1 = (1:range(2)-range(1)+1);
                    t1 = t1(:);
                    tauD = spc.fit(gui.spc.proChannel).beta0(2)*spc.datainfo.psPerUnit/1000;
                    tauAD = spc.fit(gui.spc.proChannel).beta0(4)*spc.datainfo.psPerUnit/1000;
                    tau_m = lifetime;
                end
            end
            
            F_int = spc.project(ROIreg);
            F_int = F_int(~isnan(F_int));
            intensity = sum(F_int(:));
            nPixel = intensity / mean(F_int(:));
            
            roiN = j-1;
            
            if roiN == 0 || isempty(roiN) %%%%%Background
                if spc.switches.noSPC
                    bg.time(fn) = datenum(spc.state.internal.triggerTimeString);
                else
                    bg.time(fn) = datenum([spc.datainfo.date, ',', spc.datainfo.time]);
                end
                bg.position{fn} = ROI;
                bg.mean_int(fn) = mean(F_int(:));
                bg.nPixel(fn) = nPixel;
                bg.mean_int(fn) = mean(F_int(:));
                if spc.switches.redImg
                    img_greenMax = spc.state.img.greenImgF(:,:,fn);
                    green_R = img_greenMax(ROIreg);
                    bg.green_int(fn) = sum(green_R);
                    bg.green_mean(fn) = mean(green_R);
                    bg.green_nPixel(fn) = bg.green_int(fn) / bg.mean_int(fn);
                    img_redMax = spc.state.img.redImgF(:,:,fn);
                    red_R = img_redMax(ROIreg);
                    bg.red_int(fn) = sum(red_R);
                    bg.red_mean(fn) = mean(red_R);
                    bg.red_nPixel(fn) = bg.red_int(fn) / bg.mean_int(fn);
                end
                
            else %No background
                if spc.switches.noSPC
                else
                    a(roiN).fraction_Sim(fn) = spc_getFraction((tau_m + spc.fit(gui.spc.proChannel).t_offset)*1000/spc.datainfo.psPerUnit);
                    a(roiN).fraction2(fn) = tauD*(tauD-tau_m)/(tauD-tauAD) / (tauD + tauAD -tau_m);
                    a(roiN).tauD(fn) = tauD;
                    a(roiN).tauAD(fn) = tauAD;
                    a(roiN).tau_m(fn) = tau_m;
                end
                a(roiN).position{fn} = ROI;
                a(roiN).nPixel(fn) = nPixel;
                a(roiN).mean_int(fn) = mean(F_int(:))- bg.mean_int(fn);
                a(roiN).int_int2(fn) = a(roiN).mean_int(fn)*a(roiN).nPixel(fn);
                a(roiN).max_int(fn) = max(F_int(:)) - bg.mean_int(fn);
                
                if spc.switches.redImg
                    img_redMax = spc.state.img.redImgF(:,:,fn);
                    red_R = img_redMax(ROIreg);
                    a(roiN).red_int(fn) = sum(red_R);
                    a(roiN).red_mean(fn) = mean(red_R) - bg.red_mean(fn);
                    a(roiN).red_nPixel(fn) = a(roiN).red_int(fn) / mean(red_R);
                    a(roiN).red_int2(fn) = a(roiN).red_mean(fn)*a(roiN).red_nPixel(fn);
                    a(roiN).red_max(fn) = max(red_R) -  bg.red_mean(fn);
                    img_greenMax = spc.state.img.greenImgF(:,:,fn);
                    green_R = img_greenMax(ROIreg);
                    a(roiN).green_int(fn) = sum(green_R);
                    a(roiN).green_mean(fn) = mean(green_R) - bg.green_mean(fn);
                    a(roiN).green_nPixel(fn) = a(roiN).green_int(fn) / mean(green_R);
                    a(roiN).green_int2(fn) = a(roiN).green_mean(fn)*a(roiN).green_nPixel(fn);
                    a(roiN).green_max(fn) = max(green_R) -  bg.green_mean(fn);
                    a(roiN).ratio = a(roiN).green_mean./a(roiN).red_mean;
                    
                end %reImg
                
            end %Background
        end %%%Good Roi
    end %%%is handle
end