function editCellArray(obj,ind)
% editCellArray(SpeciesIdentityObj,indDict)
%   display and edit a cell array

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 30, 2012

d = obj.SpeDict(ind);
curType = d.type;

H = ReactionLab.Util.displayCellArray(d.dict,d.fileName);
Hfig = H.Hfig;

% Hedit = H.Hedit;
% uimenu('Parent',Hedit,...
%    'Label','New dictionary',...
%    'Callback', @newDict );
% uimenu('Parent',Hedit,...
%    'Label','Add as dictionary',...
%    'Callback', @addDict);

Haction = uimenu('Parent',Hfig,...
   'Label','Data');
% uimenu('Parent',Haction,...
%    'Label','Delete selected',...
%    'Callback', @deleteRow);
% uimenu('Parent',Haction,...
%    'Label','Add new row',...
%    'Callback', @addRow);
uimenu('Parent',Haction,...
   'Label','Show',...
   'Callback', @show);
% uimenu('Parent',Haction,...
%    'Label','Show by value',...
%    'Callback', @showByValue);

Htable = H.Htable;
data = get(Htable,'Data');
[n,m] = size(data);
colName   = get(Htable,'ColumnName');
pos = get(Hfig,'Position');
colW = pos(3)*0.9/(size(data,2) + 1);
set(Htable,'ColumnWidth',{colW},...
           'ColumnName', [colName' {' '}],...
           'ColumnEditable', true(1,m+1),...
           'Data',[data repmat({false},n,1)] );

        
%    function newDict(hh,dd)
%       set(Htable,'Data',{'' '' false});
%       curType = '';
%    end
% 
%    function addDict(hh,dd)
%       data = get(Htable,'Data');
%       if any(any(cellfun(@isempty,data(:,1:2),'UniformOutput',true)))
%          errordlg('there is an empty cell','','modal')
%          return
%       end
%       answer = inputdlg({'Enter the name for the new dictionary',...
%                          'Enter the type of the new dictionary'},...
%                          'Species Dictionary',1,{'newDictionary',curType} );
%       if ~isempty(answer)
%          obj.SpeDictPrev = obj.SpeDict;
%          obj.addSpeDict(answer{1},data,answer{2});
%          obj.SetCurDataFcn();
%       end
%       closereq;
%    end
% 
%    function deleteRow(hh,dd)
%       data = get(Htable,'Data');
%       data([data{:,end}],:) = [];
%       data(:,3) = {false};
%       set(Htable,'Data',data);
%    end
% 
%    function addRow(hh,dd)
%       data = get(Htable,'Data');
%       ind = find([data{:,3}],1,'first');
%       if isempty(ind), return, end
%       data = [data(1:ind,:); {'' '' false}; data(ind+1:end,:)];
%       data(:,3) = {false};
%       set(Htable,'Data',data);
%    end

   function show(hh,dd)
      if strcmpi(curType,'primeId')
         data = get(Htable,'Data');
         ids = data([data{:,3}],2);
         if isempty(ids), return, end
%          speList = ReactionLab.SpeciesData.SpeciesList;
%          speList = ReactionLab.SpeciesData.SpeciesList.populateByPrimeId(ids);
         ReactionLab.SpeciesData.SpeciesGUI(...
            ReactionLab.SpeciesData.SpeciesList.populateByPrimeId(ids) );
      end
   end

end