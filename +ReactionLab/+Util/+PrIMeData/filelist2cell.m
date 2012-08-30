function cellArray = filelist2cell(list)
% cellArray = filelist2cell(listNET)
%  convert .NET list items into cell array
%    and remove the file extension

% Copyright 1999-2009 Michael Frenklach
% Last Modified: December 30, 2009

cellArray = cell(list.Length,1);
for i1 = 1:list.Length
   [~,cellArray{i1},~] = fileparts(char(list(i1)));
end