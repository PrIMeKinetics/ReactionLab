classdef PrIMeSpecies < handle
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: February 13, 2012

   properties (SetAccess = private)
      Doc     = [];
      PrimeId = '';
      Data    = {};
   end
   
   properties
      Hfig = [];
   end
   
   methods
      function obj = PrIMeSpecies(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               doc = arg;
            elseif ischar(arg)   % species primeId
               doc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg});
            else
               error(['incorrect object class ' class(arg)])
            end
            obj.Doc = doc;
         end
      end
      
      function y = isempty(obj)
         y = isempty(obj(1).Data);
      end
      
      function y = get(obj,prop)
         data = obj.Data;
         ind = find(strcmpi(data(:,1),prop));
         if ~isempty(ind)
            y = data(ind,2);
         else
            y = {};
         end
      end
   end
   
   
   methods (Static)
      out = warehouseSearch(varargin)
      y = getSpeList()
   end
    
end