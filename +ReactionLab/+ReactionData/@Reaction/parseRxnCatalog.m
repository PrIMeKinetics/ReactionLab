function [lhs,rhs] = parseRxnCatalog(rxnDoc)
% [lhs,rhs] = parseRxnCatalog(rxnDoc)

% Copyright 1999-2010 Michael Frenklach
% Last Modified: May 12, 2010

lhs = struct('spePrimeId', {}, 'speCoef', {}, 'speKey', {});
rhs = lhs;

speLinks = rxnDoc.GetElementsByTagName('speciesLink');
for i1 = 1:speLinks.Count
   speLink = speLinks.Item(i1-1);
   spePrimeId = char(speLink.GetAttribute('primeID'));
   speKey = char(speLink.GetAttribute('preferredKey'));
   speCoef = str2double(char(speLink.InnerText));
   if speCoef < 0
      lhs = add2side(lhs,spePrimeId,-speCoef,speKey);
   elseif speCoef > 0
      rhs = add2side(rhs,spePrimeId, speCoef,speKey);
   else
      error(['uncorrect coefficient value: ' num2str(speCoef)]);
   end
end


   function side = add2side(side,spePrimeId,speCoef,speKey)
      ind = find(strcmpi({side.spePrimeId},spePrimeId));
      if isempty(ind)    % no match found, add new
         next = length(side) + 1;
         side(next).spePrimeId = spePrimeId;
         side(next).speCoef    = speCoef;
         side(next).speKey     = speKey;
      else
         side(ind).speCoef = side(ind).speCoef + speCoef;
      end
   end


end