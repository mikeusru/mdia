function xyPixels = fixBrokenLines(xPxInd,lineLabel,sizeImage)
        xyPixels=[xPxInd',(lineLabel)'];
        for i=1:max(xyPixels(:,2))
            ind=xyPixels(:,2)==i;
            xPixelValues=xyPixels(ind,1);
            if numel(xPixelValues)>1
                pixelJump=find(abs(diff(xPixelValues))>2); %in case there are breaks in the line
                p = polyfit(1:length(xPixelValues),xPixelValues',1);
                if isempty(pixelJump)
                    newXPixelValues=round(mean(xPixelValues)-length(xPixelValues)/2) : round(mean(xPixelValues)-length(xPixelValues)/2) + length(xPixelValues) -1;
                    if p(1)<0
                        newXPixelValues = fliplr(newXPixelValues);
                    end
                else
                    xPixelSegment=xPixelValues(1:pixelJump(1));
                    newXsegment=round(mean(xPixelSegment)-length(xPixelSegment)/2) : round(mean(xPixelSegment)-length(xPixelSegment)/2) + length(xPixelSegment) -1;
                    if p(1)<0
                        newXsegment = fliplr(newXsegment);
                    end
                    newXPixelValues=newXsegment;
                    for j=1:length(pixelJump)
                        if j==length(pixelJump)
                            maxInd=length(xPixelValues);
                        else
                            maxInd=pixelJump(j+1);
                        end
                        xPixelSegment=xPixelValues(pixelJump(j)+1 : maxInd);
                        newXsegment=round(mean(xPixelSegment)-length(xPixelSegment)/2) : round(mean(xPixelSegment)-length(xPixelSegment)/2) + length(xPixelSegment) -1;
                        if p(1)<0
                            newXsegment = fliplr(newXsegment);
                        end
                        newXPixelValues=[newXPixelValues,newXsegment];
                    end
                end
                xyPixels(ind,1)=newXPixelValues;
            end
        end
        %correct for pixels out of bounds
        xyPixels(xyPixels(:,1)>floor(sizeImage(1)),1)=floor(sizeImage(1));
        xyPixels(xyPixels(:,1)<1)=1;
        xyPixels(xyPixels(:,2)>floor(sizeImage(2)),2)=floor(sizeImage(2));
        xyPixels(xyPixels(:,2)<1)=1;
    end