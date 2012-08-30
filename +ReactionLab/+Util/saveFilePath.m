function filePath = saveFilePath(fileType,filterSpec)
% filePath = saveFilePath('Element|Species|...','*.*')

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: December 28, 2011

if nargin == 1
   filterSpec = '*.*';
end

[fileName,pp] = uiputfile(filterSpec,['Save ' fileType ' file'],fileType);
if fileName==0
   filePath = [];
   return;
end
addpath(pp);
filePath = fullfile(pp,fileName);