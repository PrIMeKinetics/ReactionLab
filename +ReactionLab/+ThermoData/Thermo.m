classdef Thermo
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011

   properties
      Id
      Comment  = '';
      DataRef  = struct('key','','id','');  % bibliography
      RefState = struct('T',[],'P',[]);  %  K, Pa
   end
   
   properties (SetAccess = 'protected')
      Trange = [];
   end
   
   properties (Dependent = true)
      Tmin
      Tmax
   end
   
   properties (Abstract, SetAccess = 'protected')
      Data
   end
   
   
   methods (Abstract)
      [y,Tactual,prop] = eval(obj,T,prop)
      y = findTrange(obj)
   end
   
   methods
      function y = get.Tmin(obj)
         y = obj.Trange(1);
      end
      function y = get.Tmax(obj)
         y = obj.Trange(2);
      end
   end

end