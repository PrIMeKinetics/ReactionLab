function removerecord(obj,primeId,reason)
% removerecord(WarehouseLinkObj,primeId,reason)
% remove file primeId and associated data
%   move to respective attics
%   objLink:  e.g., rxnPrimeId if primeId is rkPrimeId

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: August 1, 2011

fileObj = ReactionLab.Util.PrIMeData.WarehouseFile(obj.Username,obj.Password,primeId);
removefile(fileObj,reason);

removedir(obj,primeId,reason);

disp(['record removed  ' primeId])