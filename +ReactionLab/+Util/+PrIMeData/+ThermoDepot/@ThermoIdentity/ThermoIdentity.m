classdef ThermoIdentity < handle

% Copyright 1999-2013 Michael Frenklach
% Last modified: December 2, 2012

   properties (SetAccess = 'private')
      Chemkin
      Hpanel
   end

   properties
      Hresults
   end
  
   
   methods
      function obj = ThermoIdentity(chemkinObj)
         if nargin > 0
            obj.Chemkin = chemkinObj;
            obj.Hpanel = feval(chemkinObj.HpanelTemplate);
            obj.initializeFirstWindow();
         end
      end
   end
   
end