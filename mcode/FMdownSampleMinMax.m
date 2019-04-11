function [xDec, yDec] = ...
    FMdownSampleMinMax( x, y, nrPts)
%
% Do nothing if too few points are available
nrDataPts = length( x );
if nrDataPts <= nrPts
    xDec = x;
    yDec = y;
else
    %
    bDatetime = 0;
    inds = unique(round(linspace(1,nrDataPts,nrPts)));
    l = length( inds ) - 1;
    %   xDec = x(1:l);
    %   yDec = y(1:l);
    if isdatetime(x)
        x = datenum(x);
        bDatetime = 1;
    elseif isduration(x)
        x = datenum(x);
        bDatetime = 2;
    end
        
    xDec = zeros(1,l);
    yDec = zeros(1,l);
    for k=1:l
        xTemp = x( inds(k):inds(k+1) );
        yTemp = y( inds(k):inds(k+1) );
        %
        xUse = mean( xTemp );
        
        xtemp1 = xTemp(1);
        xtemp2 = xTemp(end);
        x1 = (xtemp1+xUse)/2;
        x2 = (xtemp2+xUse)/2;
        
        yMin = min( yTemp );
        yMax = max( yTemp );
        
        xDec(2*k-1) = x1;
        xDec(2*k) = x2;
        
        yDec(2*k-1:(2*k)) = [yMin; yMax];
        
    end ;
    
    switch bDatetime
        case 1 %datetime
            xDec = datetime(xDec,'ConvertFrom','datenum') ;
        case 2 %datenum
            
            xDec = datetime(xDec,'ConvertFrom','datenum') - datetime(xDec(1),'ConvertFrom','datenum') ;
                 
    end
        
%     if bDatetime
%         xDec = datetime(xDec,'ConvertFrom','datenum') ;
%     end
    
end;