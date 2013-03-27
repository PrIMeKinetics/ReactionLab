function removerecord(obj,primeId,reason,opt)
% removerecord(WarehouseLinkObj,primeId,reason,displayOption)
% remove file primeId and associated data
%   move to respective attics
%   objLink:  e.g., rxnPrimeId if primeId is rkPrimeId
% displayOption = 1  with dialog boxes, otherwise  line command

% Copyright 1999-2013 Michael Frenklach
% Last modified: March 26, 2013, myf added display option

if nargin < 4
   opt = 0;
end

fileObj = ReactionLab.Util.PrIMeData.WarehouseFile(obj.Username,obj.Password,primeId);
removefile(fileObj,reason,opt);

removedir(obj,primeId,reason,opt);

ReactionLab.Util.displayOption(opt,'disp',['record removed  ' primeId]);