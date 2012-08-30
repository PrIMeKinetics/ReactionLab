function deletefile(obj)
% deletefile(WarehouseFileobj)
%
% delete file without moving it to attic --- only for the administrator

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: January 1, 2011

res = obj.ws.Delete(obj.FilePath,obj.Username,obj.Password);
if ~res.result
   error([obj.FilePath ': could not be deleted']);
end

disp(['deleted ' obj.FilePath])