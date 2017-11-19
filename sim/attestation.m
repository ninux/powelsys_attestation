% cleanup ----------------------------------------------------------------------
clear all;
close all;

% load packages ----------------------------------------------------------------
pkg load control;
pkg load signal;

% setup graphics ---------------------------------------------------------------
graphics_toolkit gnuplot
%graphics_toolkit qt

% definitions ------------------------------------------------------------------
vo  = 200;    % [V]   output voltage
L   = 200E-6; % [H]   inductance
C   = 5E-6;   % [F]   output capacitance
R   = 50;     % [Ohm] load resistance
fs  = 100E3;  % [Hz]  switching frequency

% derived definitions
wlb  = 0;      % [1]  angular frequency: lower bound exponent (10^x)
wub  = 6;      % [1]  angular frequency: upper bound exponent (10^x)
wn   = 1E3;    % [1]  angular frequency: number of points
angf = logspace(wlb,wub,wn);

% controller options
ctrl_pi    = 1;   % PI controller
ctrl_pit1  = 2;   % PIT1 Controller
ctrl_pidt2 = 3;   % PIDT2 Controller

% controler selection
control = ctrl_pi;
%control = ctrl_pidt2;

% 1A ---------------------------------------------------------------------------
vi1 = 50;
vi2 = 100;
vi3 = 150;
vi  = [vi1, vi2, vi3];

d1 = boostduty(vo, vi1);
d2 = boostduty(vo, vi2);
d3 = boostduty(vo, vi3);

datapath = "./../data/";
filename = "duty.csv";
fid = fopen(strcat(datapath, filename),"wt");
  fprintf(fid, "Duty Cycle Calculation Results:");
  fprintf(fid, "\n\tD(Vi = %dV) \t= %.2f", vi1, d1);
  fprintf(fid, "\n\tD(Vi = %dV) \t= %.2f", vi2, d2);
  fprintf(fid, "\n\tD(Vi = %dV) \t= %.2f", vi2, d3);
  fprintf(fid, "\n---\n");
fclose(fid);

% 1B ---------------------------------------------------------------------------
s  = tf('s');
h1 = boosttf(vo,R,L,C,d1);
h2 = boosttf(vo,R,L,C,d2);
h3 = boosttf(vo,R,L,C,d3);

%h1 = tf((vo/(1-d1))*(1-s*L/R/(1-d1)^2)/(1+s*L/R/(1-d1)^2 + s^2*L*C/(1-d1)^2));
%h2 = tf((vo/(1-d2))*(1-s*L/R/(1-d2)^2)/(1+s*L/R/(1-d2)^2 + s^2*L*C/(1-d2)^2));
%h3 = tf((vo/(1-d3))*(1-s*L/R/(1-d3)^2)/(1+s*L/R/(1-d3)^2 + s^2*L*C/(1-d3)^2));

[mag1, pha1, angf1] = bode(h1, angf);
[mag2, pha2, angf2] = bode(h2, angf1);
[mag3, pha3, angf3] = bode(h3, angf1);

data = [mag1, pha1, angf1'];
datapath = "./../data/";
filename = "h1.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

data = [mag2, pha2, angf2'];
datapath = "./../data/";
filename = "h2.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

data = [mag3, pha3, angf3'];
datapath = "./../data/";
filename = "h3.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% 1C
switch control
  case ctrl_pi
    kp = 0.00010; % 9E-6 
    ki = 20e3;    % 200E3
    g = kp * (1 + ki/s);
  case ctrl_pit1
    g = 1;
  case ctrl_pidt2
    kp  = 0.0002;
    wi1 = 1000;
    wi2 = 3e3;
    wt1 = 10e3;
    wt2 = 30e3;
    g   = kp * (1 + wi1/s) * (1 + s/wi2) / (1 + s/wt2) / (1 + s/wt1);
  otherwise
    g   = 1;
endswitch

[mag1, pha1, angf1] = bode(g, angf);

data = [mag1, pha1, angf1'];
datapath = "./../data/";
filename = "g.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% 1D

go1 = h1*g;
go2 = h2*g;
go3 = h3*g;

[mag1, pha1, angf1] = bode(go1);
[mag2, pha2, angf2] = bode(go2, angf1);
[mag3, pha3, angf3] = bode(go3, angf1);

data = [mag1, pha1, angf1'];
datapath = "./../data/";
filename = "go1.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

data = [mag2, pha2, angf2'];
datapath = "./../data/";
filename = "go2.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

data = [mag3, pha3, angf3'];
datapath = "./../data/";
filename = "go3.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% plot the step answers
tstep = [0:8E-6:10E-3];
[Y1,T1,X1] = step( go1 / (1+go1), tstep);
[Y2,T2,X2] = step( go2 / (1+go2), tstep);
[Y3,T3,X3] = step( go3 / (1+go3), tstep);

data = [T1,Y1];
datapath = "./../data/";
filename = "step1.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s\n", "time", "signal");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

data = [T2,Y2];
datapath = "./../data/";
filename = "step2.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s\n", "time", "signal");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

data = [T3,Y3];
datapath = "./../data/";
filename = "step3.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s\n", "time", "signal");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);