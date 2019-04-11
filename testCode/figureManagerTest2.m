%% Static error for eddy current position sensor
%
% This data is from the data acquisition system used by
% Silvia Brunenbauer in the thermo visco elastic
% measurement system.
%
% (c) 2016 Paul O'Leary
%
%%
close all;
clear all;
%% Load a large data set
load lowerToolhalf_20161115_15_34;
%
sensorNames = extractfield( sensor, 'Name');
inds = [1,2,3,5,6];
%inds = [3,5,6];
dms = analogData(:,3);
dr =  analogData(:,5);
%
dms = dms - mean( dms);
dms = dms / norm(dms);
dr = dr - mean(dr) ;
dr = dr / norm(dr);
[x, lags] = xcorr( dms, dr);
%% generate a figure
fig1 = figureGen;
% start the plot manager
FM = FigureManager( fig1 );
% generate managed plots
[n,m] = size( analogData );
t = ((1:n)')/120E3;
xLabel = 'time';
%
plotMulti( t, analogData(:,inds), xLabel, sensorNames(inds) );
%%
% fig2 = figure;
% FM2 = FigureManager;
% subplot(2,1,1)
% plot( dms - dr );
% subplot(2,1,2);
% plot( dms, 'k', 'Tag', 'discreteY');
% hold on;
% stairs( -dr, 'r');
