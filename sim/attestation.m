% cleanup ----------------------------------------------------------------------
clear all;
close all;

% load packages ----------------------------------------------------------------
pkg load control;
pkg load signal;

% setup graphics ---------------------------------------------------------------
%graphics_toolkit gnuplot
graphics_toolkit qt

% definitions ------------------------------------------------------------------
vo  = 200;    % [V]   output voltage
L   = 200E-3; % [H]   inductance
C   = 5E-3;   % [F]   output capacitance
R   = 50;     % [Ohm] load resistance
fs  = 100E3;  % [Hz]  switching frequency

% 1A ---------------------------------------------------------------------------
vi1 = 50;
vi2 = 100;
vi3 = 150;
vi  = [vi1, vi2, vi3];

d1 = boostduty(vo, vi1);
d2 = boostduty(vo, vi2);
d3 = boostduty(vo, vi3);

fprintf("results for 1-A:");
fprintf("\n\tD(Vi = %dV) \t= %.2f", vi1, d1);
fprintf("\n\tD(Vi = %dV) \t= %.2f", vi2, d2);
fprintf("\n\tD(Vi = %dV) \t= %.2f", vi2, d3);
fprintf("\n---\n");

% 1B ---------------------------------------------------------------------------
s  = tf('s');
h1 = tf((vo/d1)*(1 - s*L/R/(1-d1)^2) / (1 + s*L/R/(1-d1)^2 + s^2*L*C/(1-d1)^2));
h2 = tf((vo/d2)*(1 - s*L/R/(1-d2)^2) / (1 + s*L/R/(1-d2)^2 + s^2*L*C/(1-d2)^2));
h3 = tf((vo/d3)*(1 - s*L/R/(1-d3)^2) / (1 + s*L/R/(1-d3)^2 + s^2*L*C/(1-d3)^2));



% 1C
fc = 1/10 * fs/2;
wc = 2*pi*fc;
k  = 1;

PT1 = k/(1 + s/wc);

[mag, pha, ome] = bode(h1);
%figure(1);
%  subplot(2,1,1);
%  loglog(ome, mag);
%  subplot(2,1,2);
%  semilogx(ome, pha);

