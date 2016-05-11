function y = getExptList()
% y = getExptList()
% get list of all experiments in PrIMe Warehouse

% Copyright 2009-2015 Michael Frenklach
% Modified:   March  9, 2012
% Modified: January 29, 2015, myf: updated line 14


% get the list of experiment catalog files
list = ReactionLab.Util.PrIMeData.WarehouseLink.getFileList('depository/experiments/catalog/');
nExpt = length(list);

y = ReactionLab.Util.PrIMeData.ExperimentDepot.PrIMeExperiments.empty(0,nExpt);
for i1 = 1:nExpt
   [~,exptPrimeId,~] = fileparts(char(list(i1)));
   y(i1) = ReactionLab.Util.PrIMeData.ExperimentDepot.PrIMeExperiments(exptPrimeId);
end