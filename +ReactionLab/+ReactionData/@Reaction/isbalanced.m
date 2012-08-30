function y = isbalanced(r,rs)
%index = isbalanced(ReactionObj,ReactionSetObject)
%  checks if reaction r is balanced
%     returns 1 if OK, 0 otherwise

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: May 5, 2010

e.symbol = '';
e.number = 0;
i3 = 0;
eList = {''};

rxnSpe = r.Species;
for i1 = 1:length(rxnSpe)
   f = rxnSpe(i1);
   spePrimeId = f.primeId;
   if nargin > 1
      spe = rs.Species.find('PrimeId',spePrimeId);
      if isempty(spe)
         spe = ReactionLab.SpeciesData.Species(spePrimeId);
      end
   else
      spe = ReactionLab.SpeciesData.Species(spePrimeId);
   end
   elem = spe.Elements;
   for i2 = 1:length(elem)
      el = elem(i2);
      ind = find(strcmpi(eList,el.symbol));
      if isempty(ind)
         i3 = i3 + 1;
         e(i3).symbol = el.symbol;
         e(i3).number = el.number * f.coef;
         eList = {e.symbol};
      else
         e(ind).number = e(ind).number + el.number * f.coef;
      end
   end
end

if any([e.number])
   y = 0;
else
   y = 1;
end