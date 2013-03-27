function download(obj,fileLocalDirPath,opt)
% download(WarehouseFileObj,fileLocalDirPath,displayOption)
% displayOption = 1  with dialog boxes, otherwise  line command
% download file from Warehouse to fileLocalDirPath

% Copyright 1999-2013 Michael Frenklach
% Last modified: March 26, 2013, myf added display option

if nargin < 3
   opt = 0;
end

res = obj.conn.GetFile(fileLocalDirPath,obj.FilePath);
if ~res.result
   ReactionLab.Util.displayOption(opt,'error',...
                   [obj.FilePath ': could not download']);
end

ReactionLab.Util.displayOption(opt,'disp',[obj.FilePath ' downloaded to ' fileLocalDirPath]);