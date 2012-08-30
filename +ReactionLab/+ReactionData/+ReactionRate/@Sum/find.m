function [y,ind] = find(sumList,prop,value)
% [SumObj,index] = find(SumObj,Property, value)
% return the index of the Sum object in SumList if found,
%      empty otherwise
% prop is the class property, e.g.,

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: April 15, 2010

ind = []; y = [];
if isempty(sumList), return, end

sumRksList = sumList.Container;   % cell array

for i1 = 1:length(sumRksList)
   item = sumRksList{i1};
   p = properties(item);
   jp = find(strcmpi(prop,p));
   if ~isempty(jp)
      prop = char(p(jp));
      if isnumeric(value)
         isfound = round([item.(prop)]) == round(value);
      elseif any(strcmpi(prop,{'col' 'collider'}))
         col = [item.Collider];
         isfound = strcmpi(col.primeId,value);
      else
         isfound = strcmpi(item.(prop),value);
      end
      if isfound
         ind = i1;
         y = item;
         return
      end
   end
end