function iLine = findKeyword(txt,kw)
% iLine = findKeyword(txt,kw)
% return the index of the row with the keyword

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: November 20, 2011

iCell = strfind(txt,kw);
iLine = find(cellfun(@isempty,iCell) == 0);
if isempty(iLine), return, end
line = txt{iLine};
if strcmp(line(1),'!')
   iLine = [];
end