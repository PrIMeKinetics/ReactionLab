classdef ReactionSet < dynamicprops
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011
   
   properties
      Title     = '';
      PrimeId   = '';
      Path      = '';
      Comment   = '';
      Protected = 0;
      BiblioKey = '';
      BiblioId  = '';
      AdditionalData = struct('itemType',{},'description',{},'content',{});

      Elements
      Species
      Reactions
   end
   

   methods
      function obj = ReactionSet(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               rs = ReactionLab.ModelData.ReactionSet();
               obj = rs.dom2rxnset(arg);
            elseif ischar(arg)  % primeId
               rs = ReactionLab.ModelData.ReactionSet();
               rsDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg});
               obj = rs.dom2rxnset(rsDoc);
            else
               error(['incorrect class: ' class(arg)]);
            end % if
         end
      end
      
      function display(obj)
         disp(obj)
%          window(obj)
      end
   end
   
   
   methods (Static)
      rs = readChemkinFile(fileName,speDictFileName)
   end
   
end