function cellArray = list2cell(list)
% cellArray = list2cell(listNET)
%  convert .NET String list items into cell array

% Copyright 1999-2009 Michael Frenklach
% Last Modified: November 11, 2009

cellArray = cell(list.Length,1);
for i1 = 1:list.Length
   cellArray{i1} = char(list(i1));
end