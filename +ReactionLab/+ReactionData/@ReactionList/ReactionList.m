classdef ReactionList < ReactionLab.Util.IContainer
   
% Copyright 1999-2016 Michael Frenklach
% Modified:   January 1, 2011
% Modified:   January 2, 2015, myf: commented out display -- use .window
% Modified: December 31, 2015, myf: added isDirectionMatch method
   
   
   methods
      
      function obj = ReactionList()
         valClass = 'ReactionLab.ReactionData.Reaction';
         obj = obj@ReactionLab.Util.IContainer(valClass);
      end
      
      function y = isDirectionMatch(obj)
         rr = obj.Values;
         y = 1;
         for i1 = 1:obj.Length
            y = y * rr(i1).isDirectionMatch();
            if ~y, return, end
         end
      end
      
      function window(obj)
         ReactionLab.ReactionData.ReactionGUI(obj);
      end
   end
   
end