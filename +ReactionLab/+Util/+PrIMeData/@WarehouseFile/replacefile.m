function replacefile(obj,fileLocalPath,reason)
% replacefile(WarehouseFileobj,fileLocalPath,reason)
%
% replace file in Warehouse:
%   move current file to attic
%   upload the new file
%
% fileLocalPath =
%   '...\objPrimeId'              (e.g., '...\s00001234')
%   '...\objPrimeId\dataPrimeId'  (e.g., '...\s00001234\thp00000001')
%               =

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: December 31, 2010


outStr = '';

[~,primeId,~] = fileparts(fileLocalPath);
if length(primeid) == 9
   obj.setFile(primeId);
   outStr = [outStr primeId];
elseif length(primeId) > 9
   [~,objPrimeId,~] = fileparts(fileLocalPath);
   obj.setFile(primeId,objPrimeId);
   outStr = [outStr objPrimeId '\data\' primeId];
else
   error(['incorrect length of primeId ' primeId]);
end

removefile(obj,reason);
uploadfile(obj,fileLocalPath,reason);


disp(['replaced ' outStr]);