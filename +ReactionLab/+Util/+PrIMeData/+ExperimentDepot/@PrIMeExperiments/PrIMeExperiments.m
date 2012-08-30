classdef PrIMeExperiments < handle
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: April 23, 2012

   properties (SetAccess = private)
      Doc     = [];
      Data    = {};
   end
   
   properties
      Hfig = [];
   end
   
   properties (Dependent = true)
      PrimeId
      Biblio
   end
   
   methods
      function obj = PrIMeExperiments(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               doc = arg;
            elseif ischar(arg)   % experiment primeId
               doc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg});
            else
               error(['incorrect object class ' class(arg)])
            end
            obj.Doc = doc;
         end
      end
      
      function y = get.PrimeId(obj)
         y = char(obj.Doc.DocumentElement.GetAttribute('primeID'));
      end
      
      function y = get.Biblio(obj)
         bibNodes = obj.Doc.GetElementsByTagName('bibliographyLink');
         y = cell(bibNodes.Count,2);
         for i1 = 1:bibNodes.Count
            bibRecord = bibNodes.Item(i1-1);
            y{i1,1} = char(bibRecord.GetAttribute('primeID'));
            y{i1,2} = char(bibRecord.GetAttribute('preferredKey'));
         end
      end
      
      function y = isempty(obj)
         y = isempty(obj(1).Data);
      end
      
      function y = get(obj,prop)
         data = obj.Data;
         if isempty(data)
            y = {};
         else
            ind = find(strcmpi(data(:,1),prop));
            if ~isempty(ind)
               y = data(ind,2);
            else
               y = {};
            end
         end
      end
   end
   
   
   methods (Static)
      [y,z] = warehouseSearch(varargin)
      y = getExptList()
   end
    
end