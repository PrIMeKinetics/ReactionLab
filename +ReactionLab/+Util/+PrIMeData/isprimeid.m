function y = isprimeid(str,symbol)
% yes_no = isprimeid(charString,typeChar)
%
% eg, y = isprimeid('s00000049','s')
%     y = isprimeid({'s00000049' 's00001234'},'s')

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
      len = length(symbol);
      if all(strcmpi(s(1:len),symbol)) && ...
         all(isstrprop(s(len+1:end),'digit')) && ...
         length(s(len+1:end)) == 8
         y = true;
      else
         y = false;
      end
   end

end