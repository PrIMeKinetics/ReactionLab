function removedir(obj,primeId,reason)
% removedir(WarehouseLinkObj,primeId,reason)
% move primeId data directory to attic

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: December 31, 2010

webFilePath = char(obj.Common.PrimeID2path(primeId));
dataDirPath = [fileparts(fileparts(webFilePath)) '/data/'];
webDirPath = [dataDirPath primeId];

setProperty(obj,'submittedBy',obj.Username,webDirPath);
setProperty(obj,'updateReason',reason,webDirPath);

% move dir to attic
newDirPath = [dataDirPath '_attic/' primeId '_' int2str(0)];
res6 = Move(obj.ws,webDirPath,newDirPath,obj.Username,obj.Password);
if ~res6.result
   error([webDirPath ': could not move old directory to attic']);
end

disp(['moved ' webDirPath ' to attic'])