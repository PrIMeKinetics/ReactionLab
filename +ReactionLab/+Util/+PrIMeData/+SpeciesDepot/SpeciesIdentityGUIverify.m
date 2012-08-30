classdef SpeciesIdentityGUIverify < ReactionLab.Util.PrIMeData.SpeciesDepot.SpeciesIdentityGUI

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 30, 2012
  
   methods
      function obj = SpeciesIdentityGUIverify(arg)
         obj = obj@ReactionLab.Util.PrIMeData.SpeciesDepot.SpeciesIdentityGUI(arg);
         obj.setButtonNames();
      end
      
      function setButtonNames(obj)
         set(obj.Hfig,'Name','Verify Species');
         set(obj.Hfound,   'String','Accept');
         set(obj.HnotFound,'String','Add to ''not found by InChI''');
      end
      
   end
   
end