classdef RateCoefficient
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: November 20, 2010
   
   properties
      PrimeId = '';
      RxnPrimeId = '';
      Eq = '';    % rxn equation for this rate coef
      Direction = '';  % 'forward|reverse'
   end
   
   
   methods (Abstract)
      y = isempty(rk)
      y = eval(rk,T,P)
      rk = dom2rk(rk,rkDoc)
   end
   
   methods
      function y = getClass(rk)
         c1 = textscan(class(rk), '%s', 'delimiter', '.');
         y = c1{:}{end};
      end
      
      function y = isPdepedent(rk)
         if any(strcmpi(rk.getClass, ...
                {'Unimolecular' 'ChemicalActivation'} ))
            y = 1;
         else
            y = 0;
         end
      end
   end
   
end