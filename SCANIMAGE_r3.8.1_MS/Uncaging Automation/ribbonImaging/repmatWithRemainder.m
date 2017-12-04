function b = repmatWithRemainder( a , scanRatio, remainder)
        if remainder~=0
%             b=zeros(size(ceil(length(a)*scanRatio),1));
            x=1:length(a);
            xi=linspace(1,length(a),round(length(a)*scanRatio));
            b=interp1(x,a,xi);
%             b=repmat(a',ceil(scanRatio),1);
%             ending=a(1:floor(length(a*remainder)));
%             b=[b(:);ending(:)];
            b=b(:);
%             b=round(b);
%             b=b(1:round(length(a)*scanRatio));
        else
            b=repmat(a',scanRatio,1);
            b=b(:);
        end
    end