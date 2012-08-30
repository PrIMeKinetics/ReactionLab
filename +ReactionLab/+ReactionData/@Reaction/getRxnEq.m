function [y,left,right] = getRxnEq(r)
% [y,left,right] = getRxnEq(ReactionObj)
% return rxn equation

% Copyright 1999-2010 Michael Frenklach
% $ Revision: 1.1 $
% Last modified: April 29, 2010

y = '';
rxnSpe = r.Species;
if isempty(rxnSpe(1).key), return, end

left  = '';
right = '';
for i1 = 1:length(rxnSpe)
   if rxnSpe(i1).coef < 0
      left  = addSide(left ,i1);
   else
      right = addSide(right,i1);
   end
end

if r.Reversible
  y = [left ' <=> ' right];
else
  y = [left ' -> '  right];
end


   function s = addSide(side,ind)
      spe = rxnSpe(ind);
      if ~isempty(side)
         side = [side ' + '];
      end
      if ~isempty(spe.coef) && abs(spe.coef) ~= 1
         side = [side num2str(abs(spe.coef)) ' '];
      end
      s = [side spe.key];
   end

end