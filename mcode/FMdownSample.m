function [xDec, yDec] = ...
  FMdownSample( x, y, nrPts)
%
% Do nothing if too few points are available
nrDataPts = length( x );
if nrDataPts <= nrPts
  xDec = x;
  yDec = y;
else
  %
  inds = unique(round(linspace(1,nrDataPts,nrPts)));
  %
  xDec = x( inds );
  yDec = y( inds );
end;