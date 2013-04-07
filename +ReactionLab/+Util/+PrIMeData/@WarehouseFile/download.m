function y = download(obj,fileLocalDirPath)
% localFilePath = download(WarehouseFileObj,fileLocalDirPath)
% download file from Warehouse to fileLocalDirPath

% Copyright 1999-2013 Michael Frenklach
%      modified: March 26, 2013, myf
% Last modified: April  6, 2013, myf


res = obj.conn.GetFile(obj.FilePath,fileLocalDirPath);
if ~res.status
   error([obj.FilePath ': could not be downloaded']);
else
   y = char(res.result);
end