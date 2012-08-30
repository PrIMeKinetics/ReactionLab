function displayThermoPanel(speGUI)
% displayThermoPanel(speGUIobj)

% Copyright 1999-2011 Michael Frenklach
% $ Revision: 1.1 $
% Last modified: July 23, 2012

set(speGUI.HthermoCompare.panel,'Visible','off');

speGUI.Hcurrent.panel(1) = speGUI.Hthermo.panel(1);
speThermo = speGUI.Hthermo.currentThermo;
set(speGUI.Hthermo.key, 'String', speGUI.CurrentSpecies.Key);

set(speGUI.Hthermo.ref ,'String',speThermo.DataRef.key);

set(speGUI.Hthermo.id,'String',speThermo.Id);

T = str2num(get(speGUI.Hthermo.T,'String')); %#ok<ST2NM>
if isempty(T) || any(T <= 0)
   Hdlg = errordlg('Temperature values must be positive',...
                   'evaluation of thermo','modal');
   waitfor(Hdlg);
   set(speGUI.Hthermo.T,'String','');
   return;
end

hu = speGUI.hUnits;
su = speGUI.sUnits;

[deltaH,T]  = speThermo.eval(T,{ 'h',hu});
deltaHf = speThermo.eval(T,{'hf',hu});
heatCap = speThermo.eval(T,{'cp',su});
entropy = speThermo.eval(T,{ 's',su});
switch get(speGUI.Hthermo.Punits,'Value')
   case 1    % atm
      P = 100000;
   case 2    % bar
      P = 101325;
end
R = ReactionLab.PhysConst.univR(su);
entropy = entropy - R*log(P/speThermo.RefState.P);
set(speGUI.Hthermo.table,'Data', [ T; heatCap; deltaH; entropy; deltaHf ]' );

set(speGUI.Hthermo.cpUnits,'String',su);
set(speGUI.Hthermo.sUnits, 'String',su);
set(speGUI.Hthermo.hUnits, 'String',hu);

set(speGUI.Hthermo.panel,'Visible','on');