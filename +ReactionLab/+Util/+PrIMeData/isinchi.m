function y = isinchi(str)
% yes_no = isinchi(charString)
%
% eg, y = isinchi('inchi=...')
%     y = isinchi({'inchi=...' 'inchi=...'})

% Copyright 1999-2012 Michael Frenklach
% Last Modified: January 2, 2012


if ischar(str)
   y = checkSingle(str);
elseif iscell(str)
   y = cellfun(@checkSingle,str,'UniformOutput',true);
else
   error(['undefined argument class ' class(str)]);
end


   function y = checkSingle(s)
      s = strtrim(s);
      s = strtok(s,'=');
      if all(strcmpi(s,'inchi'))
         y = true;
      else
         y = false;
      end
   end

end