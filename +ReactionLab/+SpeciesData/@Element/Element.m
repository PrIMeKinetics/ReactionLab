classdef Element
   
% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 28, 2010
   
   properties
      Id          = '';
      Name        = '';
      Symbol      = '';
      Mass        = [];
      RefElemSymbol = '';
      RefElemId     = '';
   end
   
   
   methods
      function obj = Element(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               obj = ReactionLab.SpeciesData.Element.loadDoc(arg);
            elseif ischar(arg)  % primeID
               elemDoc = ReactionLab.Util.gate2primeData('getDOM',{'element',arg});
               obj = ReactionLab.SpeciesData.Element.loadDoc(elemDoc);
            else
               error(['incorrect class: ' class(arg)]);
            end % if
         end
      end
      
      function display(obj)
         disp(obj)
      end

   end
   
   methods (Static)
      obj = dom2elem(docObj)
         
      function y = loadDoc(docObj)
         if ~isempty(docObj)
            y = ReactionLab.SpeciesData.Element.dom2elem(docObj);
         else
            y = [];
         end
      end
   end
   
end