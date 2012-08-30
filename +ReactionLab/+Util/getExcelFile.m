function [c,fileName] = getExcelFile(fileType)
% [cellArray,fileName] = getExcelFile(fileType)

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: November 23, 2011

filePath = ReactionLab.Util.getFilePath(fileType,'*.xls;*.xlsx');
if isempty(filePath)
   c = {};
   fileName = '';
else
   [~,~,c] = xlsread(filePath);
   [~,fn,ext] = fileparts(filePath);
   fileName = [fn ext];
end
