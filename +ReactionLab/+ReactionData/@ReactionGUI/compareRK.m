function compareRK(rxnGUI,ind)
% compareRK(rxnGUobj,tableIndex)
%
%  plots reaction rates for sum, etc.

% Copyright 1999-2016 Michael Frenklach
%  Created: January 1, 2016
% Modified: 

T = 500:100:3000;

r = rxnGUI.CurrentReaction;
rkListInTable = getappdata(rxnGUI.Hid.rkTable,'rkListInTable');
rks = rkListInTable(ind);
for i1 = 1:length(rks)
   rki = rks{i1};
   kF(:,i1) = rki.eval(T,rxnGUI.aUnits)';
   if strcmp(rki.getClass,'ThirdBody')
      str{i1} = rki.Collider.key;
      indPlot = 1;
   else
      str{i1} = num2str(i1);
      indPlot = 2;
   end
end

figure('NumberTitle','off', 'Name',r.RateCoef.Eq);
if indPlot == 1   % vs T
   semilogy(T,kF);
   xlabel('T (K)');
else
   semilogy(1./T,kF);
   xlabel('1/T [1/K]')
end
ylabel(['k (' rxnGUI.aUnits ')'])
legend(str,'Location','best');