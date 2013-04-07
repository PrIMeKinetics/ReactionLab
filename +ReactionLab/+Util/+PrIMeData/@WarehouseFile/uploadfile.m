function uploadfile(obj,fileLocalPath,reason,opt)
% uploadfile(WarehouseFileObj,fileLocalPath,reason,displayOption)
% displayOption = 1  with dialog boxes, otherwise  line command
% upload file to Warehouse

% Copyright 1999-2013 Michael Frenklach
%      modified: March 26, 2013, myf added display option
% Last modified: March 29, 2013, myf

if nargin < 4
   opt = 0;
end

res = obj.conn.Upload(fileLocalPath,obj.FilePath);
if ~res.status
   ReactionLab.Util.displayOption(opt,'error',...
                   [obj.FilePath ': could not upload']);
end

setProperty(obj,'submittedBy',obj.Username);
setProperty(obj,'updateReason',reason);

ReactionLab.Util.displayOption(opt,'disp',['uploaded ' fileLocalPath ' as ' obj.FilePath]);