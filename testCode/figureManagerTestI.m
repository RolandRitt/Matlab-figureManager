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
% fig1 = figureGen;
% % start the plot manager
% FM = FigureManager;
% % generate managed plots
% A(1) = subplot(2,1,1);
% P1 = plot( x, y, 'r', 'UserData', 'MinMax');
% grid on;
% hold on;
% A(2) = subplot(2,1,2);
% P1 = plot( x, y, 'r.', 'UserData', 'integerY');
% grid on;
% hold on;
% %
% linkaxes( A, 'xy');
% grid on;
% hold on;
% axis tight
%
figure
FM = FigureManager;
P1 = plot( x, y, 'r.', 'UserData', 'integerY');
grid on;
hold on;
%P2 = plot( x, y, 'b-.');
%
%linkaxes( A, 'xy');
grid on;
hold on;
axis tight