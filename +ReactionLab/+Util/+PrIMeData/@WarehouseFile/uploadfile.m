function uploadfile(obj,fileLocalPath,reason)
% uploadfile(WarehouseFileObj,fileLocalPath,reason)
% upload file to Warehouse

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: January 1, 2011


res = obj.conn.Upload(fileLocalPath,obj.FilePath);
if ~res.result
   error([obj.FilePath ': could not upload']);
end

setProperty(obj,'submittedBy',obj.Username);
setProperty(obj,'updateReason',reason);

disp(['uploaded ' fileLocalPath ' as ' obj.FilePath]);