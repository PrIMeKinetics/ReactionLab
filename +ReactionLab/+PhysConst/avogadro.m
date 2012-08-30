function y = avogadro(units)
%y = AVOGADRO(units) returns Avogadro number

% Copyright 1999-2008 Michael Frenklach
% $Revision: 1.1 $
% Last modified: May 18, 2008

if nargin==0,  units = 'mol'; end

switch lower(units)
   case {'mol' 'cgs' 'si'}
      y = 6.02214e+23;
   case 'kmol'
      y = 6.02214e+26;
	otherwise
		error(['unknown unit: ' units])
end