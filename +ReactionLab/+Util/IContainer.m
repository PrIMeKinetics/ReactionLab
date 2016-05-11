classdef IContainer
% container interface 
   
% Copyright 2010-2015 Michael Frenklach
% Modified:   April 9, 2012
% Modified: January 2, 2015, myf: added remove method

   properties (SetAccess = 'private')
      ValueClass = '';
   end

   properties (SetAccess = 'protected')
      Container = {};
   end
   
   properties (Dependent = true)
      Length
      Values
   end
   
   
   methods
      function obj = IContainer(valueClass)
         if nargin > 0
            if ischar(valueClass)
               obj.ValueClass = valueClass;
            else
               error(['incorrect class ' class(valueClass)])
            end
         end
      end
      
      function y = get.Length(obj)
         y = length(obj.Container);
      end
      
      function y = get.Values(obj)
         a = obj.Container;
         if strcmp(obj.ValueClass,'any')
            y = a;
         else
            y = [a{:}];
         end
      end
      function y = isempty(obj)
         y = isempty(obj.Container);
      end
      function obj = clear(obj)
         obj.Container = {};
      end
      function obj = remove(obj,ind)
         obj.Container(ind) = [];
      end
      
      function obj = add(obj,item)
         if isa(item,obj.ValueClass)
            for i1 = 1:length(item)
               obj.Container = [obj.Container {item(i1)}];
            end
         elseif iscell(item)
            obj = obj.add([item{:}]);
         else
            error(['incorrect class: ' class(item)]);
         end
      end
      
      function obj = replace(obj,prop,propValue,newItem)
         [~,ind] = find(obj,prop,propValue);
         obj.Container{ind} = newItem;
      end
      
      function [y,ind] = find(obj,prop,value)
         ind = []; y = [];
         if isempty(obj), return, end
         objList = obj.Values;
         p = properties(objList);
         jp = find(strcmpi(prop,p));
         if isempty(jp), return, end
         prop = char(p(jp));
         if isnumeric(value)
            ind = find(round([objList.(prop)]) == round(value));
         else
            ind = find(strcmpi({objList(1:end).(prop)},value));
         end
         y = objList(ind);
      end
   end
   
end