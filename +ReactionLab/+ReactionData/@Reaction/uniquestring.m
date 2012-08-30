function y = uniquestring(r)
% str = uniquestring(ReactionObj)
% return unique-id string composed of elements: 
%     speciesID/stoich coef, sorted by speciesID
%     the first stoich coef is positive
%       speIDtype = 'primeID'

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: May 8, 2010


spe = r.Species;     %  struct
  ids = {spe.primeId};
coefs = [spe.coef];

uniqueIds = unique(ids);
numIds = length(uniqueIds);
uniqueCoefs = zeros(1,numIds);
for i1 = 1:numIds
   ind = strcmp(uniqueIds{i1},ids);
   uniqueCoefs(i1) = sum(coefs(ind));
end

y = '';
signFirstCoef = sign(uniqueCoefs(1));
for i1 = 1:numIds
   coef = uniqueCoefs(i1);
   if coef ~=0
      y  = [y uniqueIds{i1} ':' ...
              num2str( coef * signFirstCoef ) '/'];
   end
end