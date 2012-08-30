function plotThermoData(speGUI,ind)
% plotThermoData(speGUIobj,index
%
% plots Cp, H, S, Hf vs T
% index 2   3  4  5

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: January 15, 2011


hu = speGUI.hUnits;
su = speGUI.sUnits;

spe = speGUI.CurrentSpecies;
speThermo = spe.Thermo;
T = linspace(speThermo.Tmin,speThermo.Tmax,30);

switch ind
   case 2   % Cp
      y = speThermo.eval(T,{'cp',su});
      yLabel = ['Cp  [' strrep(su,'_',' ') ']'];
   case 3   % H
      y = speThermo.eval(T,{ 'h',hu});
      yLabel = ['H  [' strrep(hu,'_',' ') ']'];
   case 4   % S
      y = speThermo.eval(T,{ 's',su});
      switch get(speGUI.Hthermo.Punits,'Value')
         case 1    % atm
            P = 100000;
         case 2    % bar
            P = 101325;
      end
      R = ReactionLab.PhysConst.univR(su);
      y = y - R*log(P/speThermo.RefState.P);
      yLabel = ['S  [' strrep(su,'_',' ') ']'];
   case 5   % Hf
      y = speThermo.eval(T,{ 'hf',hu});
      yLabel = ['Hf  [' strrep(hu,'_',' ') ']'];
   otherwise
      error(['undefined value of index ', num2str(ind)]);
end


figure('NumberTitle','off', 'Name', spe.Key);
plot(T,y,'o');
xlabel('T [K]')
ylabel(yLabel)