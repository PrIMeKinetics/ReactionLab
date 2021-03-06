function y = get_lastid(conn,dirPath)
% y = get_lastid(conn,dirPath)
%     new Matlab

% Copyright 1999-2015 Michael Frenklach
% Modified: January 17, 2010
% Modified:   April  7, 2015

out = conn.ListFiles(dirPath);
if ~out.status
   error(char(out.statusMessage));
end

list = out.result;
count = 0;
for i1 = 1:list.Length
   fileName = char(list(i1));
   if isempty(strfind(fileName,'attic'))
      s = strtok(fileName,'.xml');  % primeId
      s(1) = [];                    % remove first letter ('b')
      count = count + 1;
      x(count) = str2double(s);
   end
end

x_sorted = sort(x);
y = x_sorted(end);