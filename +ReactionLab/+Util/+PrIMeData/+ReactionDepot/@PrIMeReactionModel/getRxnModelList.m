function y = getRxnModelList()
% y = getRxnModelList()
% get list of all reaction models in PrIMe Warehouse

% Copyright 2009-2013 Michael Frenklach
% Last modified: December 9, 2012


% get the list of reaction-model catalog files
list = ReactionLab.Util.PrIMeData.WarehouseLink.getFileList('depository/models/catalog/');
nRxn = length(list);

y = ReactionLab.Util.PrIMeData.ReactionDepot.PrIMeReactionSet.empty(0,nRxn);
for i1 = 1:nRxn
   [~,rmPrimeId,~] = fileparts(char(list(i1)));
   y(i1).PrimeId = rmPrimeId;
end