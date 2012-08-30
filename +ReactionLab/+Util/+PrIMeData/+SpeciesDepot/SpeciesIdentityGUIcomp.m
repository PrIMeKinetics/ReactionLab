classdef SpeciesIdentityGUIcomp < ReactionLab.Util.PrIMeData.SpeciesDepot.SpeciesIdentityGUI

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 30, 2012
  
   methods
      function obj = SpeciesIdentityGUIcomp(arg)
         obj = obj@ReactionLab.Util.PrIMeData.SpeciesDepot.SpeciesIdentityGUI(arg);
         obj.setButtonNames();
      end
      
      function setButtonNames(obj)
         set(obj.Hfig,'Name','Species by Composition');
         set(obj.Hfound,   'String','Select displayed');
         set(obj.HnotFound,'String','Add to ''submit as new''');
      end
      
   end
   
end