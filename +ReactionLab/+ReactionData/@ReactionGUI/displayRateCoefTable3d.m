function displayRateCoefTable3d(rxnGUI,r,T,kF,kR,P)
% displayRateCoefTable3d(rxnGUIobj,ReactionObj,T,kF,kR,P)
%
% displays a table of reaction rate coefficients
%                    k(T,P) vs T and P

% Copyright 1999-2013 Michael Frenklach
% Last modified: February 25, 2013

direction = 'forward';
data = kF;

au = strrep(rxnGUI.aUnits,',',' ');
pu = rxnGUI.pUnits;

lenP = length(P);  nCols = min(lenP,10);
lenT = length(T);  nRows = min(lenT,30);

hRows = 20*(nRows+3);
wCols = 95*nCols;
pos = [200 250 wCols hRows];  % 405-320 = 85
Hfig = figure(...
   'Position', pos,...
   'NumberTitle', 'off',...
   'Name', [r.Eq ' / k_forward in ' au ],...
   'MenuBar', 'none',...
   'Resize', 'off');

Hplot = uimenu('Parent',Hfig,'Label','Plot');
uimenu('Parent', Hplot,...
   'Label', '3D',...
   'Callback', @plot3d );
uimenu('Parent', Hplot,...
   'Label', '2D vs T',...
   'Callback', @plot2T );
uimenu('Parent', Hplot,...
   'Label', '2D vs P',...
   'Callback', @plot2P );
Htable = uitable('Parent',Hfig,'Visible','on',...
        'Position',[0 0 wCols-3 hRows-30],...
        'ColumnWidth', num2cell(repmat(80,1,lenP)),...
        'ColumnName',  num2cell(P),...
        'RowName', T ,...
        'Data', data );

uicontrol('Parent',Hfig,...
   'Style', 'text',...
   'Position', [0 hRows-48 54 15],...
   'HorizontalAlignment', 'center',...
   'FontSize', 10,...
   'String', 'T  [K]');
uicontrol('Parent',Hfig,...
   'Style', 'text',...
   'Position', [57 hRows-31 wCols-62 20],...
   'HorizontalAlignment', 'center',...
   'FontSize', 10,...
   'String', ['P  in  ' pu] );

uicontrol('Parent',Hfig,...
   'Style','popupmenu',...
   'Position', [50 hRows-13 70 15],...
   'String',{'forward' 'reverse'},...
   'BackgroundColor', 'white',...
   'Callback', @selectDirection );

   function selectDirection(h,d)
      if get(h,'Value') == 1   % forward
         direction = 'forward';
         data = kF;
      else                     % reverse
         direction = 'reverse';
         data = kR;
      end
      set(Htable,'data', data );
      set(Hfig,'Name', [r.Eq ' / k_' direction ' in ' au]);
   end
   
   
   function plot3d(h,d)
      [Tmesh,Pmesh] = meshgrid(1./T,log10(P));
      figure('NumberTitle','off', 'Name',r.Eq);
      surfc(Tmesh,Pmesh,log10(data'))  %  mesh | surf
      colormap hsv
      xlabel('1/T  (K)');
      ylabel(['log10(P)  (' pu ')']);
      zlabel(['log10(k)   (' au ')']);
      title(['\fontsize{16} \color{blue} k \fontsize{12}' direction])
   end

   function plot2T(h,d) 
   % plot rate coefficient vs T at array of P's
      figure('NumberTitle','off', 'Name',r.Eq);
      leg = cell(1,lenP);
      for iP = 1:lenP
         leg{iP} = sprintf('%.2g',P(iP));
      end
      semilogy(1./T,data')
      legend(leg,'Location','Best')
      xlabel('1/T  (K)');
      ylabel(['log10(k)   (' au ')']);
      title(['\fontsize{16} \color{blue} k \fontsize{12}' direction])
      v = axis;
      v(1) = min(1./T);
      v(2) = max(1./T);
      axis(v)
   end

   function plot2P(h,d)
   % plot rate coefficient vs P at array of T's
      figure('NumberTitle','off', 'Name',r.Eq);
      leg = cell(1,lenT);
      for iT = 1:lenT
         leg{iT} = sprintf('%.2g',T(iT));
      end
      loglog(P,data)
      legend(leg,'Location','Best')
      xlabel(['log10(P)   (' pu ')']);
      ylabel(['log10(k)   (' au ')']);
      title(['\fontsize{16} \color{blue} k \fontsize{12}' direction])
      v = axis;
      v(1) = min(P);
      v(2) = max(P);
      axis(v)
   end

end