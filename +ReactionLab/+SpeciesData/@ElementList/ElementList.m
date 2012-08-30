classdef ElementList < ReactionLab.Util.IContainer
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011
   
   
   methods
      
      function obj = ElementList()
         valClass = 'ReactionLab.SpeciesData.Element';
         obj = obj@ReactionLab.Util.IContainer(valClass);
      end
      
      function display(obj)
         if ~isempty(obj)
            window(obj)
         end
      end
   
   end
   
end