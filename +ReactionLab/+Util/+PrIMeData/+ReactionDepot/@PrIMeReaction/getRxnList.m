function y = getRxnList()
% y = getRxnList()
% get list of all reactions in PrIMe Warehouse

% Copyright 2009-2013 Michael Frenklach
% Last modified: December 9, 2012


% get the list of reaction catalog files
list = ReactionLab.Util.PrIMeData.WarehouseLink.getFileList('depository/reactions/catalog/');
nRxn = length(list);

y = ReactionLab.Util.PrIMeData.ReactionDepot.PrIMeReaction.empty(0,nRxn);
for i1 = 1:nRxn
   [~,rxnPrimeId,~] = fileparts(char(list(i1)));
   y(i1).PrimeId = rxnPrimeId;
end