classdef Dataset < dynamicprops
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011
   
   properties
      PrimeId   = '';
      Title     = '';
      Comment   = '';
      BiblioKey = '';
      BiblioId  = '';
      ReactionModelId    = '';
      ReactionModelTitle = '';
      
      OptimizationVariables
      SurrogateModels
      Targets
      
      AdditionalData = struct('itemType',{},'description',{},'content',{});
   end
   

   methods
      function obj = Dataset(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               ds = ReactionLab.ModelData.Dataset();
               obj = ds.dom2dataset(arg);
            elseif ischar(arg)  % primeId
               ds = ReactionLab.ModelData.Dataset();
               dsDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg});
               obj = ds.dom2dataset(dsDoc);
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
   
end