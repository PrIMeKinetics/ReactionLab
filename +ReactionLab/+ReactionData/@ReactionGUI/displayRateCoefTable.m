function displayRateCoefTable(rxnGUI,rk,T,kF,eqK,P)
% displayRateCoefTable(rxnGUIobj,RateCoefObj,T,kF,eqK,P)
%
% displays a table of reaction rate coefficients

% Copyright 1999-2016 Michael Frenklach
% Modified: February 25, 2013
% Modified: December 30, 2015, myf: changed r.Eq to rk.Eq

au = rxnGUI.aUnits;

kR = kF./eqK;

if nargin < 6
   nRows = length(T);
   colNames = {'T (K)','k-forw','k_rev','Keq'};
   data = [ T; kF; kR; eqK]';
   funH = @plotVsT;
   str = ['in  ' au];
elseif length(T) > 1
   nRows = length(T);
   colNames = {'T (K)','k-forw','k_rev','Keq'};
   data = [ T; kF; kR; eqK]';
   funH = @plotVsT;
   str = ['in  ' au  '   at P = ' num2str(P) ' ' rxnGUI.pUnits];
else
   nRows = length(P);
   colNames = {['P/' rxnGUI.pUnits],'k-forw','k_rev','Keq'};
   data = [ P; kF; kR; repmat(eqK,size(P))]';
   funH = @plotVsP;
   str = ['in  ' au  '   at T = ' num2str(T) ' K'];
end

nRows = min(nRows,30);
hRows = 20*(nRows+3);
pos = [200 250 325 hRows];
Hfig = figure(...
   'Position', pos,...
   'NumberTitle', 'off',...
   'Name', rk.Eq,...
   'Tag', 'rateCoefTable',...
   'MenuBar', 'none',...
   'Resize', 'off');

Hplot = uimenu('Parent',Hfig,'Label','Plot');
uimenu('Parent', Hplot,...
   'Label', 'k_forward',...
   'Callback', { funH kF ['k_forward  [' strrep(au,',',' ') ']']} );
uimenu('Parent', Hplot,...
   'Label', 'k_reverse',...
   'Callback', { funH kR ['k_reverse  [' strrep(au,',',' ') ']']} );
uimenu('Parent', Hplot,...
   'Label', 'Keq',...
   'Callback', { funH eqK ['Keq  [' strtok(au,',') ']']} );

uitable('Parent',Hfig,'Visible','on',...
        'Position',[0 0 322 hRows-30],...
        'ColumnWidth', { 60 80 80 80 },...
        'ColumnName',colNames,...
        'ColumnFormat',{'numeric','numeric','numeric','numeric'},...
        'RowName', [] ,...
        'Data', data );
     
uicontrol('Parent',Hfig,...
   'Style', 'text',...
   'Position', [10 hRows-25 300 20],...
   'HorizontalAlignment', 'center',...
   'BackgroundColor', get(Hfig,'Color'),...
   'FontSize', 10,...
   'String', str );

   function plotVsT(h,d,y,yLabel)
      figure('NumberTitle','off', 'Name',rk.Eq);
      semilogy(1./T,y,'o');
      xlabel('1/T [1/K]')
      ylabel(yLabel)
   end

   function plotVsP(h,d,y,yLabel)
      figure('NumberTitle','off', 'Name',rk.Eq);
      loglog(P,y,'o');
      xlabel(['P  [' rxnGUI.pUnits ']'])
      ylabel(yLabel)
   end


end