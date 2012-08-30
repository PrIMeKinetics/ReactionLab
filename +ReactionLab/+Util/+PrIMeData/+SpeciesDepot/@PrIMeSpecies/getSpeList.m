function y = getSpeList()
% y = getSpeList()
% get list of all species in PrIMe Warehouse

% Copyright 2009-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: December 25, 2011


% get the list of species catalog files
list = ReactionLab.Util.PrIMeData.WarehouseLink.getFileList('depository/species/catalog/');
nSpe = length(list);

y = ReactionLab.Util.PrIMeData.SpeciesDepot.PrIMeSpecies.empty(0,nSpe);
for i1 = 1:nSpe
   [~,spePrimeId,~] = fileparts(char(list(i1)));
   y(i1).PrimeId = spePrimeId;
end