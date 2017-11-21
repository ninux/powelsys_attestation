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
vo  = 200;        % [V]   output voltage
L   = 200E-6;     % [H]   inductance
C   = 5E-6;       % [F]   output capacitance
R   = 50;         % [Ohm] load resistance
fs  = 100E3;      % [Hz]  switching frequency

% derived definitions
wlb  = 0;         % [1]  angular frequency: lower bound exponent (10^x)
wub  = 6;         % [1]  angular frequency: upper bound exponent (10^x)
wn   = 1E3;       % [1]  angular frequency: number of points
angf = logspace(wlb,wub,wn);

% controller options
ctrl_pi    = 1;   % PI controller
ctrl_pit1  = 2;   % PIT1 Controller
ctrl_pidt2 = 3;   % PIDT2 Controller

mode_nov   = 1;   % no overshoot    -- moderate controller settings
mode_wov    = 0;  % with overshoot  -- aggressive controller settings

% controler selection
control_type = ctrl_pi;
%control_type = ctrl_pit1;
%control_type = ctrl_pidt2;

control_mode = mode_nov;


% 1A ---------------------------------------------------------------------------
% define input voltage
vi1 = 50;         % [V] input voltage 1
vi2 = 100;        % [V] input voltage 2
vi3 = 150;        % [V] input voltage 3
vi  = [vi1, vi2, vi3];

% calculate duty cycles for the different input voltages
d1 = boostduty(vo, vi1);
d2 = boostduty(vo, vi2);
d3 = boostduty(vo, vi3);

% print the duty cycle calculations
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
% define the complex frequency variable s
s  = tf('s');

% define the transfer functions of the boost converter
h1 = boosttf(vo,R,L,C,d1);
h2 = boosttf(vo,R,L,C,d2);
h3 = boosttf(vo,R,L,C,d3);

% calculate the bode plots of the different transfer functions
[mag1, pha1, angf1] = bode(h1, angf);
[mag2, pha2, angf2] = bode(h2, angf1);
[mag3, pha3, angf3] = bode(h3, angf1);

% write the data for system 1
data = [mag1, pha1, angf1'];
datapath = "./../data/";
filename = "h1.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% write the data for system 2
data = [mag2, pha2, angf2'];
datapath = "./../data/";
filename = "h2.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% write the data for system 3
data = [mag3, pha3, angf3'];
datapath = "./../data/";
filename = "h3.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% 1C ---------------------------------------------------------------------------
% define the controller transfer function
switch control_type
  case ctrl_pi        % PI controller
    switch control_mode
      case mode_nov
        kp = 9E-6;
        wi = 200E3;
      case mode_wov
        kp = 1E-4;
        wi = 20E3;
      otherwise
        error("unknown controller mode");
    endswitch
    g = kp * (1 + wi/s);
  case ctrl_pit1      % PIT1 controller
    switch control_mode
      case mode_nov
        kp = 0.00010;
        wi = 20E3;
        wt = 100E3;
      case mode_wov
        kp = 0.00010;
        wi = 20E3;
        wt = 100E3;
      otherwise
        error("unknown controller mode");
    endswitch
    g = kp * (1 + wi/s) / (1 + s/wt);
  case ctrl_pidt2     % PIDT2 controller
    switch controller_mode
      case mode_nov
        kp  = 1/500000;   %0.0002;
        wi1 = 100;        %1000;
        wi2 = 1E3;        %3e3;
        wt1 = 100E3;      %10e3;
        wt2 = 300E3;      %30e3;
      case mode_wov
        kp  = 1/500000;   %0.0002;
        wi1 = 100;        %1000;
        wi2 = 1E3;        %3e3;
        wt1 = 100E3;      %10e3;
        wt2 = 300E3;      %30e3;
      otherwise
        error("unknown controller mode");
    endswitch
    g   = kp * (1 + wi1/s) * (1 + s/wi2) / (1 + s/wt2) / (1 + s/wt1);
  otherwise
    error("unknown controller type");
endswitch

% calculate bode diagram for the controller
[mag1, pha1, angf1] = bode(g, angf);

% write data to file
data = [mag1, pha1, angf1'];
datapath = "./../data/";
filename = "g.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% 1D ---------------------------------------------------------------------------

% define the open loop system
go1 = h1*g;
go2 = h2*g;
go3 = h3*g;

% calculate the bode diagrams for the open loop systems
[mag1, pha1, angf1] = bode(go1);
[mag2, pha2, angf2] = bode(go2, angf1);
[mag3, pha3, angf3] = bode(go3, angf1);

% write data to file for system 1
data = [mag1, pha1, angf1'];
datapath = "./../data/";
filename = "go1.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% write data to file for system 2
data = [mag2, pha2, angf2'];
datapath = "./../data/";
filename = "go2.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% write data to file for system 3
data = [mag3, pha3, angf3'];
datapath = "./../data/";
filename = "go3.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s, %s\n", "magnitude", "phase", "angfreq");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% plot the step responses ------------------------------------------------------

% specify the step time
tstep = [0:8E-6:10E-3];

% calculate the step responses for the closed loop systems
[Y1,T1,X1] = step( go1 / (1+go1), tstep);
[Y2,T2,X2] = step( go2 / (1+go2), tstep);
[Y3,T3,X3] = step( go3 / (1+go3), tstep);

% write data to file for system 1
data = [T1*1E3,Y1];
datapath = "./../data/";
filename = "step1.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s\n", "time", "signal");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% write data to file for system 2
data = [T2*1E3,Y2];
datapath = "./../data/";
filename = "step2.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s\n", "time", "signal");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);

% write data to file for system 3
data = [T3*1E3,Y3];
datapath = "./../data/";
filename = "step3.csv";

fid = fopen(strcat(datapath, filename), "wt");
  fprintf(fid, "%s, %s\n", "time", "signal");
fclose(fid);
dlmwrite(strcat(datapath, filename), data, ",", "-append", "precision", 6);