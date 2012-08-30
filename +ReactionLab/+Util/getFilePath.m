function filePath = getFilePath(fileType,filterSpec)
% filePath = getFilePath('Element|Species|...','*.*')

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: November 8, 2011

if nargin == 1
   filterSpec = '*.*';
end

[fileName,pp] = uigetfile(filterSpec,['Select ' fileType ' file']);
if fileName==0
   filePath = [];
   return;
end
addpath(pp);
filePath = fullfile(pp,fileName);