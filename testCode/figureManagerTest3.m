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
load largeDiscreteData;
%
dataLengthLimit = 50000;
n = length( y );
x = (1:n)';
%
B = dop(x,4);
yf = B * ( B' * y );
%
%% generate a figure
fig1 = figureGen;
% start the plot manager
FM = FigureManager;
% generate managed plots
P1 = plot( x, y, 'k.', 'UserData', 'integerY');
grid on;
hold on;
xlabel('Measurement number');
ylabel('ADC reading');
%
axis tight
%