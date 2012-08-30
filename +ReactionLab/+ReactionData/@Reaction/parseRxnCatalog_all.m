function y = parseRxnCatalog_all(rxnDoc)
%   y = parserxncatalog(rxnDoc)

% Copyright 1999-2010 Michael Frenklach
% Last Modified: May 12, 2010

y = struct('primeId', {}, 'coef', {}, 'key', {});

speLinks = rxnDoc.GetElementsByTagName('speciesLink');
for i1 = 1:speLinks.Count
   speLink = speLinks.Item(i1-1);
   spePrimeId = char(speLink.GetAttribute('primeID'));
   speKey = char(speLink.GetAttribute('preferredKey'));
   speCoef = str2double(char(speLink.InnerText));
   y = add2side(y,spePrimeId,speCoef,speKey);
end


   function side = add2side(side,spePrimeId,speCoef,speKey)
      ind = find(strcmpi({side.primeId},spePrimeId));
      if isempty(ind)    % no match found, add new
         next = length(side) + 1;
         side(next).primeId = spePrimeId;
         side(next).coef    = speCoef;
         side(next).key     = speKey;
      else
         side(ind).coef = side(ind).coef + speCoef;
      end
   end


end