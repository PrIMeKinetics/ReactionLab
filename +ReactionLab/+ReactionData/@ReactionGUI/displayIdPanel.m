function displayIdPanel(rxnGUI,r)
% displayIdPanel(rxnGUI,ReactionObject)

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: November 20, 2010

set(rxnGUI.Hid.eqn,'String', r.Eq );
rxnRk = r.RateCoef;
set(rxnGUI.Hid.rxnId, 'String', rxnRk.RxnPrimeId);
set(rxnGUI.Hid.rateId,'String', rxnRk.PrimeId   );
rxnRkClass = rxnRk.getClass;
set(rxnGUI.Hid.rateLaw,'String', rxnRkClass);

% set table
aUnits = rxnGUI.aUnits;
eUnits = rxnGUI.eUnits;
baseUnits = ReactionLab.Units.baseUnits();

rkTable = rxnGUI.Hid.rkTable;
columnNames = {'A' 'n' 'E' ' '};
data = {};
primeIds = {};

displayRk(rxnRk);
set(rxnGUI.Hid.rkTable,...
   'ColumnName',columnNames,...
   'Data',data,...
   'UserData',primeIds);

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
            data{end,end} = rk.Collider.key;
         case 'Unimolecular'
            displayRk(rk.High);
            data{end,end} = 'high-P limit';
            displayRk(rk.Low);
            displayFalloff(rk)
         case 'ChemicalActivation'
            displayRk(rk.Low);
            data{end,end} = 'low-P limit';
            displayRk(rk.High);
            displayFalloff(rk)
         otherwise
            error(['undefined rk class ' rkClass])
      end
 
      
      function singleRk(k)
         A = ReactionLab.Units.conv_rate(k.A,...
               {baseUnits.Conc baseUnits.Time},aUnits,k.Order);
         E = ReactionLab.Units.conv_energy(k.E,baseUnits.Energy,eUnits);
         data = [data; { sprintf('%g',A) sprintf('%g',k.n) sprintf('%g',E) ''}];
         primeIds = [primeIds k.PrimeId];
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