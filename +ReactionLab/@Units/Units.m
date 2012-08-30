classdef Units

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 2, 2011

   properties
      Conc   = '';
      Time   = '';
      Energy = '';
   end
   
   methods (Static = true)
      
      function y = baseUnits
         y.Conc   = 'mol/cm3';
         y.Time   = 's';
         y.Energy = 'K';
      end
      
      function y = baseRateUnits(order)
         switch order
            case 1
               y = '1/s';
            case 2
               y = 'cm3/mol/s';
            otherwise
               y = ['(cm3/mol)^' num2str(order-1) '/s'];
         end
      end
      
      [y,u,f] = conv_conc(x,units,newUnits)
      [y,u,f] = conv_energy(x,units,newUnits)
      [f,u] = conv_factor(units)
      [y,u,f] = conv_rate(x,givenUnits,newUnits,order)
      [y,u] = conv_temperature(x,fromUnits,toUnits)
      [y,u,f] = units2units(x,fromUnits,toUnits)

   end
    
end