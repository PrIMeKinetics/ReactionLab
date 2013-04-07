function deletefile(obj,opt)
% deletefile(WarehouseFileobj,displayOption)
% displayOption = 1  with dialog boxes, otherwise  line command
%
% delete file without moving it to attic --- only for the administrator

% Copyright 1999-2013 Michael Frenklach
%      modified: March 26, 2013, myf added display option
% Last modified: March 29, 2013, myf

if nargin < 2
   opt = 0;
end

res = obj.ws.Delete(obj.FilePath,obj.Username,obj.Password);
if ~res.status
   ReactionLab.Util.displayOption(opt,'error',...
              [obj.FilePath ': could not be deleted']);
end

ReactionLab.Util.displayOption(opt,'disp',['deleted ' obj.FilePath])