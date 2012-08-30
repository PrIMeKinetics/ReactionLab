classdef SpeciesIdentityGUImulti < ReactionLab.Util.PrIMeData.SpeciesDepot.SpeciesIdentityGUI

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: February 13, 2012
  
   methods
      function obj = SpeciesIdentityGUImulti(arg)
         obj = obj@ReactionLab.Util.PrIMeData.SpeciesDepot.SpeciesIdentityGUI(arg);
         obj.setButtonNames();
      end
      
      
      function setButtonNames(obj)
         set(obj.Hfound,   'String','Select displayed');
         set(obj.HnotFound,'String','Add unresolved to ''not found''');
      end
   end
   
end