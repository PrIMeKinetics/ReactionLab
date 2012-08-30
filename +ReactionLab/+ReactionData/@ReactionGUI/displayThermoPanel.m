function displayThermoPanel(rxnGUI,r)
% displayThermoPanel(rxnGUIobj,ReactionObject)

% Copyright 1999-2010 Michael Frenklach
% $ Revision: 1.1 $
% Last modified: November 20, 2010

set(rxnGUI.Hthermo.eqn,'String', r.Eq );

T = str2num(get(rxnGUI.Hthermo.T,'String'));
if isempty(T) || any(T <= 0)
   Hdlg = errordlg('Temperature values must be positive',...
                   'evaluation of rate coefficient','modal');
   waitfor(Hdlg);
   return;
end

if length(T) ~= 1
   set(rxnGUI.Hthermo.dH, 'String','');
   set(rxnGUI.Hthermo.dS, 'String','');
   set(rxnGUI.Hthermo.dG, 'String','');
   set(rxnGUI.Hthermo.eqK,'String','');
   rxnGUI.displayThermoTable(r,T);
else
   [eqK,~,~,dH,dS,dG] = r.keq(T,rxnGUI.eqKunits);
   deltaH = ReactionLab.Units.conv_energy(dH,'K',rxnGUI.hUnits);
   deltaS = ReactionLab.Units.conv_energy(dS,'K',rxnGUI.sUnits);
   deltaG = ReactionLab.Units.conv_energy(dG,'K',rxnGUI.hUnits);
   set(rxnGUI.Hthermo.dH, 'String',sprintf('%.2f',deltaH));
   set(rxnGUI.Hthermo.dS, 'String',sprintf('%.2f',deltaS));
   set(rxnGUI.Hthermo.dG, 'String',sprintf('%.2f',deltaG));
   set(rxnGUI.Hthermo.eqK,'String',sprintf('%.2g', eqK  ));
end

set(rxnGUI.Hthermo.panel,'Visible','on');
rxnGUI.HcurrentPanel = rxnGUI.Hthermo.panel;