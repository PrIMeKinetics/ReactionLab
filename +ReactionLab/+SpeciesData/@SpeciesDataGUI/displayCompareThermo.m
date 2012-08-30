function displayCompareThermo(speGUI)
% displayCompareThermo(speGUIobj)

% Copyright 1999-2011 Michael Frenklach
% $ Revision: 1.1 $
% Last modified: January 16, 2011

T = str2num(get(speGUI.HthermoCompare.T,'String')); %#ok<ST2NM>
if isempty(T) || any(T <= 0)
   Hdlg = errordlg('Temperature values must be positive',...
                   'evaluation of thermo','modal');
   waitfor(Hdlg);
   set(speGUI.HthermoCompare.T,'String','');
   return;
end

set(speGUI.Hthermo.panel(1),'Visible','off');
speGUI.Hcurrent.panel(1) = speGUI.HthermoCompare.panel(1);
set(speGUI.HthermoCompare.key, 'String', speGUI.CurrentSpecies.Key);

hu = speGUI.hUnits;
su = speGUI.sUnits;
u = '';
set(speGUI.HthermoCompare.P,'Visible','off');

indProp  = get(speGUI.HthermoCompare.prop,'Value');    % 1-Cp, 2-H, 3-S, 4-Hf
funcList = {@evalCp,@evalH,@evalS,@evalHf};
Hfunc = funcList{indProp};

thObjList = speGUI.Hfiles.thObjSelected;
numTh = length(thObjList);
data = T';
colName = {'T (K)'};
colFormat = {'numeric'};
colWidth = { 50 };
for i1 = 1:numTh
   th = thObjList(i1);
   propVal = Hfunc(th);
   data = [data propVal'];
   colName{i1+1} = th.Id;
   colFormat{i1+1} = 'numeric';
   colWidth{i1+1} = 80;
end

% for comparison of two sets add diff
if size(data,2) == 3  % cols: T, set1, set2
   data(:,4) = data(:,2) - data(:,3);
   colName{end+1}   = 'diff';
   colFormat{end+1} = 'numeric';
   colWidth{end+1}  = 80;
end

set(speGUI.HthermoCompare.table,...
   'ColumnWidth', colWidth,...
   'ColumnName',  colName, ...
   'ColumnFormat',colFormat,...
   'Data', data );

set(speGUI.HthermoCompare.units,'String',u);
set(speGUI.HthermoCompare.panel,'Visible','on');


   function heatCap = evalCp(speThermo)
      heatCap = speThermo.eval(T,{'cp',su});
      u = su;
   end
   function deltaH = evalH(speThermo)
      deltaH = speThermo.eval(T,{ 'h',hu});
      u = hu;
   end
   function entropy = evalS(speThermo)
      entropy = speThermo.eval(T,{ 's',su});
      switch get(speGUI.Hthermo.Punits,'Value')
         case 1    % atm
            P = 100000;
            Punits = 'atm';
         case 2    % bar
            P = 101325;
            Punits = 'bar';
      end
      R = ReactionLab.PhysConst.univR(su);
      entropy = entropy - R*log(P/speThermo.RefState.P);
      u = su;
      set(speGUI.HthermoCompare.P,...
         'Visible','on',...
         'String',['Pressure = 1 ' Punits ' ']);
   end
   function deltaHf = evalHf(speThermo)
      deltaHf = speThermo.eval(T,{'hf',hu});
      u = hu;
   end

end