function fileName = saveExcelFile(c,fileType)
% fileName = saveExcelFile(cellArray,fileType)

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: December 28, 2011

fileName = '';

filePath = ReactionLab.Util.saveFilePath(fileType,'*.xls;*.xlsx');
if ~isempty(filePath)
   y = xlswrite(filePath,c);
   if y
      [~,fn,ext] = fileparts(filePath);
      fileName = [fn ext];
   end
end
