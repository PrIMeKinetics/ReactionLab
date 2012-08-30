function [y,z,isRev] = parseRxnEq(rxnEq)
%  [leftSide,rightSide,isrevesible] = parseRxnEq(rxnEq)

% Copyright 1999-2010 Michael Frenklach
% Last Modified: May 12, 2010


[lhs,rhs] = getSides(rxnEq);

y = parseSide(lhs);
z = parseSide(rhs);


   function [left,right] = getSides(eq)
      % '=', '=>' or '<=>'
      j = findstr(eq,'=');
      if isempty(j)
         error('there is no ''='' sign')
      else
         left  = eq(  1:j-1);
         right = eq(j+1:end);
      end
      jl = findstr(left, '<');
      jr = findstr(right,'>');
      if isempty(jl)
         if isempty(jr)
            isRev = 1;
         else
            isRev = 0;
            right(jr) = [];
         end
      else
         isRev = 1;
         left(jl)  = [];
         right(jr) = [];
      end
   end


   function y = parseSide(s)
      y = struct('name', {}, 'coef', {});
      c = textscan(s,'%s','delimiter','+');
      tokens = strtrim(c{:});
      for i1 = 1:length(tokens)
         [name,coef] = parseToken(tokens{i1});
         ind = find(strcmpi({y.name},name));
         if isempty(ind)      % no match found, add new
            next = length(y) + 1;
            y(next).name = name;
            y(next).coef = coef;
         else
            y(ind).coef = y(ind).coef + coef;
         end
      end
   end
   
   
   function [name,coef] = parseToken(token)
   % parse coefficients if present
      iLetter = find(isletter(token));
      firstIndexOfLetter = iLetter(1);
      if firstIndexOfLetter == 1   % there is no coefficient present
         name = token;
         coef = 1;
      else
         name = token(firstIndexOfLetter:end);
         if strcmpi(name,'M)')
            name = 'M';
         end
         str  = token(1:iLetter(1)-1); % characters before letter
         coef = str2double(str);
         if isnan(coef)
            coef = 1;
         end
      end
   end

   
end