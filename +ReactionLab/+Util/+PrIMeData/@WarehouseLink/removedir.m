function removedir(obj,primeId,reason,opt)
% removedir(WarehouseLinkObj,primeId,reason,displayOption)
% move primeId data directory to attic
% displayOption = 1  with dialog boxes, otherwise  line command

% Copyright 1999-2013 Michael Frenklach
%      modified: March 26, 2013, myf added display option
% Last modified: March 26, 2013, myf

if nargin < 4
   opt = 0;
end

webFilePath = char(obj.Common.PrimeID2path(primeId));
dataDirPath = [fileparts(fileparts(webFilePath)) '/data/'];
webDirPath = [dataDirPath primeId];

setProperty(obj,'submittedBy',obj.Username,webDirPath);
setProperty(obj,'updateReason',reason,webDirPath);

% move dir to attic
newDirPath = [dataDirPath '_attic/' primeId '_' int2str(0)];
res6 = Move(obj.ws,webDirPath,newDirPath,obj.Username,obj.Password);
if ~res6.status
   ReactionLab.Util.displayOption(opt,'error',...
                     [webDirPath ': could not move old directory to attic']);
end

ReactionLab.Util.displayOption(opt,'disp',['moved ' webDirPath ' to attic']);