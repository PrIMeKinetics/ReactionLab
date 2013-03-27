function replacefile(obj,fileLocalPath,reason,opt)
% replacefile(WarehouseFileobj,fileLocalPath,reason,displayOption)
% displayOption = 1  with dialog boxes, otherwise  line command
%
% replace file in Warehouse:
%   move current file to attic
%   upload the new file
%
% fileLocalPath =
%   '...\objPrimeId'              (e.g., '...\s00001234')
%   '...\objPrimeId\dataPrimeId'  (e.g., '...\s00001234\thp00000001')
%               =

% Copyright 1999-2013 Michael Frenklach
% Last modified: March 26, 2013, myf added display option

if nargin < 4
   opt = 0;
end

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
   ReactionLab.Util.displayOption(opt,'error',...
            ['incorrect length of primeId ' primeId]);
end

removefile(obj,reason,opt);
uploadfile(obj,fileLocalPath,reason,opt);


ReactionLab.Util.displayOption(opt,'disp',['replaced ' outStr]);