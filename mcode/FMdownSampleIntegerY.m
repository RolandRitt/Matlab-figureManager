function [xDec, yDec] = ...
    FMdownSampleIntegerY( x, y, nrPts)
%
% Do nothing if too few points are available
nrDataPts = length( x );
if nrDataPts / 4 <= nrPts
    xDec = x;
    yDec = y;
else
    %
    nrPts = round( nrPts / 4 );
    inds = unique(round(linspace(1,nrDataPts,nrPts)));
    %
    l = length( inds ) - 1;
    if isdatetime(x)
        x = datenum(x);
        bDatetime = 1;
    end
    xDec = [];
    yDec = [];
%     xDec = zeros(1,l);
%     yDec = zeros(1,l);
    %
    for k=1:l
        range = inds(k):inds(k+1);
        %     xTemp = x( range );
        yTemp = y( range );
        %
        yMax = max( yTemp );
        yMin = min( yTemp );
        %
        bins = yMin:yMax;
        cts = hist( yTemp, bins );
        %
        usedBins = bins( cts ~= 0 )';
        %
        xs = linspace( x(range(2)), x(range(end-1)),...
            length( usedBins ))';
        %
        tempInds = randperm(length(usedBins));
        ys = usedBins(tempInds);
        %
%         xDec(k*2-1:k*2) = xs;
%         yDec(k*2-1:k*2) = ys;
        xDec = [xDec; xs];
        yDec = [yDec; ys];
    end ;
    if bDatetime
        xDec = datetime(xDec,'ConvertFrom','datenum') ;
    end
    
end;