classdef Species < dynamicprops
   
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: April 8, 2012
   
   properties
      Ids                     % containers.Map
      Key      = '';
      Names    = {};
      Formulas = {};
      Mass     = [];
      Elements = struct('symbol','','number',[]);
      Thermo   = [];
      AdditionalData = struct('itemType',{},'description',{},'content',{});
   end
   
   properties (Dependent = true)
      PrimeId
      InChI
      CASNo
      CAIndexName
   end
   
   
   methods
      function obj = Species(arg)
         obj.Ids = containers.Map;
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               obj = ReactionLab.SpeciesData.Species.loadDoc(arg);
            elseif ischar(arg)  % primeID
               speDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg});
               obj = ReactionLab.SpeciesData.Species.loadDoc(speDoc);
            else
               error(['incorrect class: ' class(arg)]);
            end % if
         end
      end
      
      function set.Names(obj,name)
         obj.Names = union(obj.Names,name);
      end
      function set.Formulas(obj,formula)
         obj.Formulas = union(obj.Formulas,formula);
      end
      
      function y = get.PrimeId(obj)
         y = getId(obj,'primeID');
      end
      function y = get.InChI(obj)
         y = getId(obj,'InChI');
      end
      function y = get.CASNo(obj)
         y = getId(obj,'CASRegistryNumber');
      end
      function y = get.CAIndexName(obj)
         y = getId(obj,'CAIndexName');
      end
      
      function display(obj)
         disp(obj)
%          window(obj)
      end
   end
   
   methods (Access = 'protected')
      function y = getId(obj,attr)
          if obj.Ids.isKey(attr)
            y = obj.Ids(attr);
         else
            y = '';
         end
      end
   end
   
   methods (Static)
      obj = dom2spe(docObj)
      
      function y = loadDoc(docObj)
         if ~isempty(docObj)
            y = ReactionLab.SpeciesData.Species.dom2spe(docObj);
         else
            y = [];
         end
      end

   end
   
end