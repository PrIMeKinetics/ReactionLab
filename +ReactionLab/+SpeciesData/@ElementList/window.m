function window(elemList)
% window(ElementListObject)
%
% displays a list of Element objects

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: May 7, 2010

elList = elemList.Values;

name = 'elements';

Hprev = findobj('Tag','elementWindow');
if ~isempty(Hprev)
   for He = Hprev
      prevName = get(He,'Name');
%          set(He,'Visible','off','Visible','on')
      if strcmpi(name,prevName)
         return
      end
   end
end

pos = [200 250 430 200];
pos(1) = pos(1) + 10 * length(Hprev);
pos(2) = pos(2) - 20 * length(Hprev);
Hfig = figure(...
   'Position', pos,...
   'NumberTitle', 'off',...
   'Name', name,...
   'Tag', 'elementWindow',...
   'MenuBar', 'none',...
   'Resize', 'off');

headings = {'PrIMe Id','Symbol','Mass','Ref Elem','Ref Elem Id'};
t = uitable('Parent',Hfig,'Visible','on',...
            'Position',[10 10 410 180],...
            'ColumnFormat',{'char','char','char','char','char'},...
            'ColumnName',headings);

data = [ {elList.Id}; ...
         {elList.Symbol}; ...
         num2cell([elList.Mass]); ...
         {elList.RefElemSymbol}; ...
         {elList.RefElemId}        ]';
      
set(t,'Data',data);