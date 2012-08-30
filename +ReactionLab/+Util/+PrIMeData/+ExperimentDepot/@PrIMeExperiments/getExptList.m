function y = getExptList()
% y = getExptList()
% get list of all experiments in PrIMe Warehouse

% Copyright 2009-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: March 9, 2012


% get the list of experiment catalog files
list = ReactionLab.Util.PrIMeData.WarehouseLink.getFileList('depository/experiments/catalog/');
nExpt = length(list);

y = ReactionLab.Util.PrIMeData.PrIMeExperiments.empty(0,nExpt);
for i1 = 1:nExpt
   [~,exptPrimeId,~] = fileparts(char(list(i1)));
   y(i1).PrimeId = exptPrimeId;
end