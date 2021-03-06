function displayIdPanel(rxnGUI,r)
% displayIdPanel(rxnGUI,ReactionObject)

% Copyright 1999-2016 Michael Frenklach
% Modified: November 20, 2010
% Modified:  January  3, 2015, myf: falloff panel 'off' when not needed
% Modified:  January 17, 2016, myf: added select column
% Modified:  March 4, 2016, Jim Oreluk: added set/get to GUI objects.
% Changed bc to a single row (Matlab 2013a does not handle more than 2 rows 
% of colors).
set(rxnGUI.Hid.foPanel,'Visible','off');  % in case it was 'on'

rxnRk = r.RateCoef;
set(rxnGUI.Hid.eqn,   'String', rxnRk.Eq);
set(rxnGUI.Hid.rxnId, 'String', rxnRk.RxnPrimeId);
set(rxnGUI.Hid.rateId,'String', rxnRk.PrimeId   );
rxnRkClass = rxnRk.getClass;
set(rxnGUI.Hid.rateLaw,'String', rxnRkClass);

% set table
aUnits = rxnGUI.aUnits;
eUnits = rxnGUI.eUnits;
baseUnits = ReactionLab.Units.baseUnits();

rkTable = rxnGUI.Hid.rkTable;
columnNames = {'A' 'n' 'E' ' ' 'select'};
data = {};
primeIds = {};
rkListInTable = {};

displayRk(rxnRk);

data(:,5) = {false};
indSelected = r.SelectedIndex;
if ~isempty(indSelected)
   data(indSelected,5) = {true};
end

% set backroundColor beased on Direction
%panelColor = rxnGUI.Hid.panel.BackgroundColor;
panelColor = get(rxnGUI.Hid.panel, 'BackgroundColor');
[n,m] = size(data);
nm = n*m;
bc = ones(nm,3);  % default is [1 1 1], white
rD = r.Direction;
if strcmp(rD,'forward')
   %rxnGUI.Hid.eqn.BackgroundColor = panelColor;
   set(rxnGUI.Hid.eqn, 'BackgroundColor', panelColor);
   bcMatch    = [1 1 1];   % white
   bcMismatch = [1 1 0];   % yellow
else
   %rxnGUI.Hid.eqn.BackgroundColor = [1 1 0];
   set(rxnGUI.Hid.eqn, 'BackgroundColor', [1 1 0]);
   bcMatch    = [1 1 0];
   bcMismatch = [1 1 1];
end
if r.isDirectionMatch
   bc = repmat(bcMatch,n,1);
else
   for i1 = 1:length(rkListInTable)
      rki = rkListInTable{i1};
      if strcmp(rki.Direction,rD)
         bc(i1,:) = bcMatch;
      else
         bc(i1,:) = bcMismatch;
      end
   end
end

% set(rxnGUI.Hid.rkTable,...
%    'ColumnName',columnNames,...
%    'BackgroundColor', bc, ...
%    'Data',data,...
%    'UserData',primeIds);

set(rxnGUI.Hid.rkTable,...
   'ColumnName',columnNames,...
   'BackgroundColor', bc(1,:), ...
   'Data',data,...
   'UserData',primeIds);



setappdata(rkTable,'rkListInTable',rkListInTable);

set(rxnGUI.Hid.panel,'Visible','on');
rxnGUI.HcurrentPanel = rxnGUI.Hid.panel;


   function displayRk(rk)
      rkClass = rk.getClass;
      switch rkClass
         case 'Sum'
            rks = rk.Values;
            for i2 = 1:length(rks)
               displayRk(rks{i2});
            end
         case 'MassAction'
            singleRk(rk);
         case 'ThirdBody'
            singleRk(rk);
            columnNames{4} = 'Collider';
            data{end,end-1} = rk.Collider.key;
         case 'Unimolecular'
            displayRk(rk.High);
            data{end,end-1} = 'high-P limit';
            displayRk(rk.Low);
            displayFalloff(rk)
         case 'ChemicalActivation'
            displayRk(rk.Low);
            data{end,end-1} = 'low-P limit';
            displayRk(rk.High);
            displayFalloff(rk)
         otherwise
            error(['undefined rk class ' rkClass])
      end
 
      
      function singleRk(k)
         A = ReactionLab.Units.conv_rate(k.A,...
               {baseUnits.Conc baseUnits.Time},aUnits,k.Order);
         E = ReactionLab.Units.conv_energy(k.E,baseUnits.Energy,eUnits);
         data = [data; { sprintf('%g',A) sprintf('%g',k.n) sprintf('%g',E) '' false}];
         primeIds = [primeIds {k.PrimeId}];
         rkListInTable = [rkListInTable {k}];
      end
      
      function displayFalloff(k)
         fo = k.Falloff;
         set(rxnGUI.Hid.foType,'String',fo.Type);
         if ~strcmpi(fo.Type,'lindemann')
            set(rxnGUI.Hid.foParam,...
               'Visible','on',...
               'Callback', @showFalloffParam );
         end
         set(rxnGUI.Hid.foPanel,'Visible','on');
         
            function showFalloffParam(h,dd)
               d = fo.Data;
               HfoTableFig = figure('Visible','on',...
                     'Position', [600 200 290 100],...
                     'NumberTitle', 'off',...
                     'Name', [r.Eq ' / ' fo.Type],...
                     'MenuBar', 'none',...
                     'Resize','off');
               rxnGUI.Hid.foTableFig = HfoTableFig;
               rxnGUI.Hid.foTable = uitable('Parent',HfoTableFig,...
                     'Position',[0 0 287 100],...
                     'RowName', [] ,...
                     'ColumnFormat', {'char' 'numeric' 'char'},...
                     'ColumnName', {'Parameter' 'Value' 'Units'},...
                     'Data', [{d.param}; {d.value}; {d.units}]'   );
            end
            
      end
      
   end

end