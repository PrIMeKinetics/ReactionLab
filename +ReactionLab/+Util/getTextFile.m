function [str,fileName] = getTextFile(fileType,filePath)
% [str,filePath] = getTextFile(fileType,filePath)

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: November 8, 2011


if nargin == 1
   filePath = ReactionLab.Util.getFilePath(fileType);
end

if isempty(filePath)
   str = [];  fileName = '';
   return
end


fid = fopen(filePath,'rt');
if fid < 0
   error(['file ' filePath ' couldn''t be open']);
end
c = textscan(fid,'%s','delimiter', sprintf('\n'));
fclose(fid);

str = strtrim(c{1});

[~,fn,fileExt] = fileparts(filePath);
fileName = [fn fileExt];