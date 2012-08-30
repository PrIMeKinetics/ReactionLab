classdef SpeciesList < ReactionLab.Util.IContainer
   
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 2, 2012

   properties (Dependent = true)
      Elements
   end
   
   
   methods
      function obj = SpeciesList()
         valClass = 'ReactionLab.SpeciesData.Species';
         obj = obj@ReactionLab.Util.IContainer(valClass);
      end
      
      function display(obj)
         if ~isempty(obj)
            window(obj)
         end
      end
      
      function window(obj)
         ReactionLab.SpeciesData.SpeciesDataGUI(obj);
      end
      
      function y = get.Elements(obj)
         y = getElements(obj);
      end
   end
   
   methods (Static)
      function obj = populateByPrimeId(primeIds)
         Hwait = waitbar(0);
         n = length(primeIds);
         obj = ReactionLab.SpeciesData.SpeciesList;
         for i1 = 1:n
            obj = obj.add(ReactionLab.SpeciesData.Species(primeIds{i1}));
            waitbar(i1/n,Hwait,['loading ' primeIds{i1}]);
         end
         close(Hwait);
      end
   end
   
end