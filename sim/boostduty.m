function d = boostduty(vo, vi)
% BOOSTDUTY Calculate the duty cycle of a boost converter.
%
%   d = BOOSTDUTY(vo,vi)
%     Description:
%       Using absolute input and output voltages to calculate the duty cycle.
%     Output:
%       d   duty cycle as unitless factor [0..1]
%     Input:
%       vi  input voltage in [V]
%       vo  output voltage [V]
%
%   d = BOOSTDUTY(vo)     using relative output voltage (out / in)
%     Description:
%       Using relative output voltage to calculate the duty cycle.
%     Output:
%       d   duty cycle as unitless factor [0..1]
%     Input:
%       vo  relative output voltage (output / input) as unitless factor [1..n]

  switch nargin
    case 2
      d = (-vi + vo) / (vo) ;
    case 1
      d = (-1 + vo) / (vo);
    otherwise
      error('wrong number of input arguments');
  endswitch
endfunction