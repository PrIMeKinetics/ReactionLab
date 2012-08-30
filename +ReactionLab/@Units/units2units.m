function [y,u,f] = units2units(x,fromUnits,toUnits)
%[newValue,units,convFactor] = units2units(value,fromUnits,toUnits)
% conversion from x[fromUnits] to x[toUnits]
%   newValue = x * f

% Copyright (c) 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: May 6, 2010

if nargin < 3
   error('incorrect number of arguments')
end

%if strcmpi(fromUnits,{'C','F','K'})
if ~isempty(find(strcmpi(fromUnits,{'C','F','K'}),1))
   if ~strcmpi(toUnits,'K')
      error('for now convert only to Kelvin')
   end
   u = 'K';
   switch upper(fromUnits)
      case 'K'
         y = x;  f = 1;
      case 'C'
         y = x + 273.16; f = NaN;
      case 'F'
         y = (x + 459.67)*5/9;  f = NaN;
      otherwise
         error(['undefined units ' fromUnits])
   end
else
    f1    = ReactionLab.Units.conv_factor(fromUnits);
   [f2,u] = ReactionLab.Units.conv_factor(  toUnits);
   f = f2/f1;
   y = x * f;
end