function h = boosttf(vo,R,L,C,d)
% BOOSTTF Calculate the transfer function of an ideal boost converter.
%
%   d = BOOSTTF(vo,R,L,C,d)
%     Description:
%       Calculate the frequency domain transfer function using the complex
%       frequency operator s.
%     Output:
%       h   transfer function as by the control package function tf
%     Input:
%       vo  output voltage [V]
%       R   load resistance [Ohm]
%       L   boost inductance [Henry]
%       C   output capacitance [Farad]
%       d   duty cycle [0 < d < 1]
%
  switch nargin
    case 5
      s = tf('s');
      h = tf((vo/(1-d))*(1-s*L/R/(1-d)^2)/(1+s*L/R/(1-d)^2 + s^2*L*C/(1-d)^2));
    otherwise
      error('wrong number of input arguments');
  endswitch
endfunction