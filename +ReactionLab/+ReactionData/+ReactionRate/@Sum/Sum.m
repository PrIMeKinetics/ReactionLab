classdef Sum < ReactionLab.ReactionData.ReactionRate.RateCoefficient ...
             & ReactionLab.Util.IContainer

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011


   methods
      function obj = Sum(varargin)
         valClass = 'any';
         obj = obj@ReactionLab.Util.IContainer(valClass);
         if nargin > 1
            if isa(varargin{1},'System.Xml.XmlDocument')
               rk = ReactionLab.ReactionData.ReactionRate.Sum();
               obj = rk.dom2rk(varargin{1});
            elseif ischar(varargin{1})  % rxnPrimeId,rkPrimeId
               rk = ReactionLab.ReactionData.ReactionRate.Sum();
               rkDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',varargin{1:2}});
               obj = rk.dom2rk(rkDoc);
            else
               error(['incorrect class: ' class(varargin{1})]);
            end % if
         end
      end
      
      function obj = add(obj,item)
         if iscell(item)
            obj = add@ReactionLab.Util.IContainer(obj,[item{:}]);
         else
            obj.Container = [obj.Container {item}];
         end
      end
      
      function y = getClasses(obj)
         items = obj.Container;
         len = length(items);
         y = cell(1,len);
         for i1 = 1:len
            y{i1} = class(items{i1});
         end
      end
      
      function [y,className] = isSameClass(obj)
         className = unique(getClasses(obj));
         if length(className) == 1
            y = 1;
         else
            y = 0;
         end
      end
   end

end