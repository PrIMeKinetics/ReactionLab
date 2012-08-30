function populateByPrimeId(obj,primeIds)
% populateByPrimeId(SpeciesListObj,primeIdArray)

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 2, 2012















for i1 = 1:length(ids)
   obj.add(ReactionLab.SpeciesData.Species(primeIds{i1}));
end