function fileList = getFileList(dirName)
% fileList = getFileList(dirName)
% get a list of all files in PrIMe Warehouse directory

% Copyright 2009-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: June 20, 2011

w = ReactionLab.Util.PrIMeData.WarehouseLink();

% get the list of catalog files
list = w.conn.ListFiles(dirName);

fileList = ReactionLab.Util.PrIMeData.filelist2cell(list.result);
while isempty(fileList{end})
   fileList(end) = [];
end