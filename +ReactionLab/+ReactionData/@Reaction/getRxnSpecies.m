function [s,col] = getRxnSpecies(r)
% [speList,collider] = getRxnSpecies(ReactionObj)
% return rxn species, and collider if present
% both s and col are struct

% Copyright 1999-2010 Michael Frenklach
% $ Revision: 1.1 $
% Last modified: May 8, 2010

c0 = struct('key',{},'primeId',{});
s = [];  col = c0;
if isempty(r), return, end

s = rmfield([r.Species],'coef');
getCollider(r.RateCoef);


   function getCollider(rk)
      switch class(rk)
         case 'ReactionLab.ReactionData.ReactionRate.ThirdBody'
         col = [col rk.Collider];
      case 'ReactionLab.ReactionData.ReactionRate.MassAction'
         col = [col c0];
      case 'ReactionLab.ReactionData.ReactionRate.Sum'
         c = rk.Container;
         for i1 = 1:length(c)
            getCollider(c{i1});
         end
      case 'ReactionLab.ReactionData.ReactionRate.Unimolecular'
         getCollider(rk.Low);
      case 'ReactionLab.ReactionData.ReactionRate.ChemActivation'
         getCollider(rk.High);
      otherwise
         error(['undefined class: ' class(rk)])
      end
   end

end