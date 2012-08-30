function [y,u] = conv_temperature(x,fromUnits,toUnits)
%[newValue,newUnits] = conv_temperature(giveValue,givenUnits,newUnits)
% conversion from x[fromUnits] to x[toUnits]
%   newValue = x * f

% Copyright (c) 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: May 6, 2010

if nargin < 3
   error('incorrect number of arguments')
end

if ~strcmpi(toUnits,'K')
   error('for now convert only to Kelvin')
end
u = 'K';
switch upper(fromUnits)
   case 'K'
      y = x;
   case 'C'
      y = x + 273.16;
   case 'F'
      y = (x + 459.67)*5/9;
   otherwise
      error(['undefined units ' fromUnits])
end