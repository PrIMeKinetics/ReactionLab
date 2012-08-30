function elemList = getElements(speList)
% ElementListObj = getElements(SpeciesListObj)
%   return a unique set of elements of species

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: May 8, 2010

spe = speList.Values;

allElem = [spe.Elements];

uniqueElem = unique({allElem.symbol});

elemList = ReactionLab.SpeciesData.ElementList();
for i1 = 1:length(uniqueElem)
   el = ReactionLab.SpeciesData.Element(uniqueElem{i1});
   elemList = elemList.add(el);
end