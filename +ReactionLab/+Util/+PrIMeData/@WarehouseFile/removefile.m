function removefile(obj,reason,opt)
% removefile(WarehouseFileobj,reason,displayOption)
% displayOption = 1  with dialog boxes, otherwise  line command
%
% move Warehouse file to attic

% Copyright 1999-2013 Michael Frenklach
% Last modified: March 26, 2013, myf added display option

if nargin < 3
   opt = 0;
end

setProperty(obj,'submittedBy',obj.Username);
setProperty(obj,'updateReason',reason);

% get the current revision number
res3 = obj.conn.GetRevisionNumber(obj.FilePath);
rev = res3.result;
if rev < 0
   ReactionLab.Util.displayOption(opt,'error',...
               ['file ' obj.FilePath ' does not exist']);
end

% Check if attic exists, make one if not
[webFileDir,~,~] = fileparts(obj.FilePath);
atticPath = [webFileDir '/_attic'];
res4 = Exist(obj.ws,atticPath,obj.Username,obj.Password);
if ~res4.result
   res5 = obj.conn.CreateDir(atticPath);
   if ~res5.result
      ReactionLab.Util.displayOption(opt,'error',...
                  [obj.FilePath ': could not create attic']);
   end
end

% move old file to attic
newFilePath = [atticPath '/' obj.PrimeId '_' num2str(rev) '.xml'];
res6 = Move(obj.ws,obj.FilePath,newFilePath,obj.Username,obj.Password);
if ~res6.result
   ReactionLab.Util.displayOption(opt,'error',...
            [obj.FilePath ': could not move old file to attic.']);
end

ReactionLab.Util.displayOption(opt,'disp',['moved ' obj.FilePath ' to attic']);