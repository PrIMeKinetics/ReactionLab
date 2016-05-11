function [y,u,f] = units2units(x,fromUnits,toUnits)
%[newValue,units,convFactor] = units2units(value,fromUnits,toUnits)
% conversion from x[fromUnits] to x[toUnits]
%   newValue = x * f

% Copyright (c) 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Modified: May 6, 2010
% Modified: March 19, 2016: Jim Oreluk - Added conversion between all
% temperatures.

if nargin < 3
   error('incorrect number of arguments')
end

if ~isempty(find(strcmpi(fromUnits,{'C', 'ºC', 'F', 'ºF', 'K'}),1))
    switch upper(toUnits)
        case'K'
            switch upper(fromUnits)   
                case {'F', 'ºF'}
                    y = (x + 459.67) * (5/9); f = NaN;
                case {'C', 'ºC'}
                    y = x + 273.15; f = NaN;
                case 'K'
                    y = x; f = 1;
            end
        case {'F', 'ºF'}
            switch upper(fromUnits)  
                case {'F', 'ºF'}
                    y = x; f = 1;
                case {'C', 'ºC'}
                    y = x * (9/5) + 32; f = NaN;
                case 'K'
                    y = x * (9/5) - 459.67; f = NaN;
            end
        case {'C', 'ºC'}
            switch upper(fromUnits)
                case {'F', 'ºF'}
                    y = (x - 32) / (9/5); f = NaN;
                case {'C', 'ºC'}
                    y = x; f = 1;
                case 'K'
                    y = x - 273.15; f = NaN;
            end
        otherwise
            error(['undefined units ' toUnits])
    end
else
    f1    = ReactionLab.Units.conv_factor(fromUnits);
   [f2,u] = ReactionLab.Units.conv_factor(  toUnits);
   f = f2/f1;
   y = x * f;
end