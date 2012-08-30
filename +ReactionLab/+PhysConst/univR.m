function [y,correctUnits] = univR(units)
%y = UNIVR(units) returns universal gas constant

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: December 22, 2011

switch lower(units)
	case {'k' 'kelvin' '' 'kelvins' 'kelv'}
		y = 1.;
		correctUnits = 'K';
	case {'c' 'cal' 'cal/mol'   'kcal/kmol', ...
                   'cal/mole'  'kcal/kmole',...
                   'cal/mol_k' 'kcal/kmol_k' }
		y = 1.9858775;
		correctUnits = 'cal/mol_K';
	case {'kcal' 'kcal/mol' 'kcal/mole' 'kcal/mol_k'}
		y = 1.9858775e-3;
		correctUnits = 'kcal/mol_K';
	case {'j' 'joul' 'j/mol' 'j/mol_k'    ...
             'kj/kmol' 'kj/kmol_k' ...
             'joules/kmol' 'joules/mole' ...
             'kpa_m3/kmol_k'}
		y = 8.3144621;
		correctUnits = 'J/mol_K';
	case {'kj' 'kjou' 'kj/mol' 'kj/mol_k' ...
         'kjoules/mol' 'kjoules/mole' ...
         'bar_m3/kmol_k'}
		y = 8.3144621e-3;
		correctUnits = 'kJ/mol_K';
   case {'ev' 'e' 'evolts' 'evol'}
      y = 5.189e+19;
      correctUnits = 'eV/mol_K';
   case {'atm_cm3/mol_k' 'atm_l/kmol_k'}
      y = 82.05746;
		correctUnits = 'atm_cm3/mol_K';
   case 'atm_cm3/k'
      y = 82.05746/6.022e+23;
		correctUnits = 'atm_cm3/K';
   case {'erg/mol_k' 'cgs'}
      y = 8.314472e+7;
      correctUnits = 'erg/mol_K';
	otherwise
		y = [];
      correctUnits = '';
end