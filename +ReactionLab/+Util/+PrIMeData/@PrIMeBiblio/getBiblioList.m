function y = getBiblioList()
% y = getBiblioList()
% get list of all bibliography files in PrIMe Warehouse

% Copyright 2009-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: April 13, 2012


% get the list of bibliography catalog files
list = ReactionLab.Util.PrIMeData.WarehouseLink.getFileList('depository/bibliography/catalog/');
nBiblio = length(list);

y = ReactionLab.Util.PrIMeData.PrIMeBiblio.empty(0,nBiblio);
for i1 = 1:nBiblio
   [~,biblioPrimeId,~] = fileparts(char(list(i1)));
   y(i1).PrimeId = biblioPrimeId;
end