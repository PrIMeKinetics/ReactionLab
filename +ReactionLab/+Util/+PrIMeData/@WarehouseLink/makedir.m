function makedir(obj,dirPath)
% makedir(WarehouseLinkObj,dirPath)
% make new directory dirPath in Warehouse

% Copyright 1999-2013 Michael Frenklach
% Created: April 4, 2013, myf


if nargin < 2 || isempty(dirPath)
   return
end

% Check if dir exist exists, and make one if not

%    z = obj.ws.Exist(path,obj.Username,obj.Password);
z = obj.conn.Exist(dirPath);
if ~z.status
   error([char(z.status) ' in Exist']);
end

if ~z.result
   res = obj.conn.CreateDir(dirPath);
   if ~res.status
      error(['could not create directory ' dirPath]);
   end
end