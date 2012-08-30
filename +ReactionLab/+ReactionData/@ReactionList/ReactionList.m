classdef ReactionList < ReactionLab.Util.IContainer
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011
   
   
   methods
      
      function obj = ReactionList()
         valClass = 'ReactionLab.ReactionData.Reaction';
         obj = obj@ReactionLab.Util.IContainer(valClass);
      end
      
      function display(obj)
         if isempty(obj)
         elseif length(obj) == 1
            disp(obj)
         else
            items = obj.Values;
            for i1 = 1:length(items)
               display(items(i1));
            end
         end
      end
      
      function window(obj)
         ReactionLab.ReactionData.ReactionGUI(obj);
      end
   end
   
end