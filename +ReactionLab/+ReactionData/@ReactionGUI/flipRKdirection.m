function flipRKdirection(rxnGUI,ind)
% flipRKdirection(rxnGUobj,tableIndex)

% Copyright 1999-2016 Michael Frenklach
%  Created:  January 11, 2016
% Modified: February 25, 2016, myf: fixed a typo
% Modified: March 4, 2016, Jim Oreluk: made changed to graphics objects to
% work in Matlab 2013. Original code is commented above changes.

r = rxnGUI.CurrentReaction;
Htable = rxnGUI.Hid.rkTable;
rkListInTable = getappdata(Htable,'rkListInTable');
rks = rkListInTable(ind);

% if k is Sum of MassAction types
if strcmp(r.RateCoef.getClass,'Sum') ...
            && strcmp(rks{1}.getClass,'MassAction')
   rk = r.RateCoef;
elseif length(ind) > 1
   return
else
   rk = rks{1};
end

% rkRev = rk.reverse();

Hfig = figure('NumberTitle','off','Name',rk.Eq, ...
   'Position', [560 528 700 420]);      % [560 528 700 420]
Hx = uicontrol('Parent',Hfig, ...
   'Style', 'popupmenu',...
   'String', {'1/T' 'ln T'}, ...
   'Position', [250 10 40 30],...
   'Callback', @plotRK);

uicontrol('Parent',Hfig,...
      'Style', 'text',...
      'Position', [500 380 30 15],...
      'HorizontalAlignment', 'right',...
      'FontSize', 10, ...
      'String', 'T = ');
Htemp = uicontrol('Parent',Hfig,...
      'Style', 'edit',...
      'Position', [535 379 100 20],...
      'FontSize', 10, ...
      'String','500:100:3000',...
      'CallBack', @fit );
uicontrol('Parent',Hfig,...
      'Style', 'text',...
      'Position', [645 380 30 15],...
      'HorizontalAlignment', 'left',...
      'FontSize', 10, ...
      'String', 'K');

fitStr = {'select equation' 'k = A exp(-E/T)' ...
      'k = A T^n exp(-E/T)' 'k = A T^n'       ...
      'k = k1 + k2'  'k = A exp(E1/T + E2/T^2 +...)'};
Hfit = uicontrol('Parent',Hfig, ...
   'Style', 'popupmenu',...
   'Position', [520 330 150 30],...
   'HorizontalAlignment', 'center',...
   'FontSize', 10, ...
   'String', fitStr, ...
   'Callback', @fit);
Htable = uitable('Parent',Hfig,'Visible','on',...
   'Position',[520 180 150 62 ],...
   'ColumnWidth', { 100 },...
   'ColumnFormat', {'numeric'},...
   'ColumnEditable', false, ...
   'RowName', {'A' 'n' 'E'},...
   'ColumnName', [] ,...
   'FontSize', 10, ...
   'Data', {} );

uicontrol('Parent',Hfig,...
      'Style', 'text',...
      'Position', [500 50 30 15],...
      'HorizontalAlignment', 'right',...
      'FontSize', 10, ...
      'String', 'mse= ');
Hnorm = uicontrol('Parent',Hfig,...
      'Style', 'edit',...
      'Position', [535 50 100 20],...
      'FontSize', 10, ...
      'String','',...
      'CallBack', @showDev );
Hdev = uicontrol('Parent',Hfig,...
      'Style', 'pushbutton',...
      'Position', [640 50 40 20],...
      'HorizontalAlignment', 'right',...
      'FontSize', 10, ...
      'String', 'Show',...
      'Visible','off',...
      'CallBack', @showDev );
   
Hdone = uicontrol('Parent',Hfig,...
      'Style', 'pushbutton',...
      'Position', [500 10 60 20],...
      'FontSize', 10, ...
      'String','Accept',...
      'CallBack', @accept );
uicontrol('Parent',Hfig,...
      'Style', 'pushbutton',...
      'Position', [580 10 60 20],...
      'FontSize', 10, ...
      'String','Cancel',...
      'CallBack', @(h,d) closereq );

T = []; kRev = []; kU = ''; kFit = []; x = [];
fit([],[]);


   function fit(h,d)
%      T = str2num(Htemp.String);
      T = str2num(get(Htemp, 'String'));
      numT = length(T);
      if numT < 2
         return
      end
      [kF,kU] = rk.eval(T);
      eqK = r.keq(T,'mol');
      kRev = kF./eqK;
      %switch Hfit.Value
      switch get(Hfit, 'Value')
         case 1   % nothing is selected
            Hplot = semilogy(1./T,kRev,'o');   % Position: [560 528 560 420]
            %Hplot.Parent.Position = [0.1 0.15 0.52 0.8];
            hParent = get(Hplot, 'Parent');
            set(hParent, 'Position', [0.1 0.15 0.52 0.8]);
            ylabel(['k (' kU ')']);
%             Hdone.Enable = 'off';
%             Hdev.Visible = 'off';            
            set(Hdone, 'Enable', 'off');
            set(Hdev, 'Visible', 'off');
            return
         case 2   % k = A exp(-E/T)
            p = polyfit(1./T,log(kRev),1);
            rows = {'A' 'E'};
            val = {exp(p(2)); -p(1)};
            kFit = exp(polyval(p,1./T));
%            Hdone.Enable = 'on';
            set(Hdone, 'Enable', 'on');
         case 3   % k = A T^n exp(-E/T)
            if numT < 3, return; end
            X = [ones(1,length(T)); log(T); 1./T]' ;
            Y = log(kRev)';
            A = X\Y;
            rows = {'A' 'n' 'E'};
            val = {exp(A(1)); A(2); -A(3)};
            kFit = exp(X * A)';
%            Hdone.Enable = 'on';
            set(Hdone, 'Enable', 'on');
         case 4   % k = A T^n
            p = polyfit(log(T),log(kRev),1);
            rows = {'A' 'n'};
            val = {exp(p(2)); p(1)};
            kFit = exp(polyval(p,log(T)));
%            Hdone.Enable = 'on';
            set(Hdone, 'Enable', 'on');
         case 5  % k = k1 + k2
            if numT < 4, return; end
            n1 = 1:floor(numT/2);
            n2 = (n1+1):numT;
            p1 = polyfit(1./T(n1),log(kRev(n1)),1);
            p2 = polyfit(1./T(n2),log(kRev(n2)),1);
            fun = @(X,T) log(exp(X(2)).*exp(X(1)./T) + exp(X(4)).*exp(X(3)./T));
            options = optimoptions(@lsqcurvefit,'Diagnostics','off','Display','off');
            X = lsqcurvefit(fun,[p1 p2],T,log(kRev),[],[],options);
            rows = {'A1' 'E1' 'A2' 'E2'};
            val = {exp(X(2)) -X(1) exp(X(4)) -X(3)}';
            kFit = exp(fun(X,T));
%            Hdone.Enable = 'on';
            set(Hdone, 'Enable', 'on');
         case 6  % poly
            res = inputdlg('order','',1,{'2'});
            if isempty(res) || isempty(res{:})
               return
            else
               pOrder = str2double(res{1});
               if numT < pOrder+1
                  return
               end
            end
            p = polyfit(1./T,log(kRev),pOrder);
            rows = {'A'};
            for i1 = 1:pOrder
               rows = [rows; {['E' int2str(i1)]}];
            end
            val = num2cell(fliplr(p))';
            val{1} = exp(val{1});
            kFit = exp(polyval(p,1./T));
%            Hdone.Enable = 'off';
            set(Hdone, 'Enable', 'off');
      end
      setTable(rows,val);
%       Hnorm.String = num2str(norm((kRev-kFit)./kRev));
%       Hdev.Visible = 'on';
      set(Hnorm, 'String', num2str(norm((kRev-kFit)./kRev)));
      set(Hdev, 'Visible', 'on');
      plotRK(Hx,[]);
   end

   function setTable(rows,data)
%       Htable.RowName = rows;
      set(Htable, 'RowName', rows);
%      pos = Htable.Position;
      pos = get(Htable, 'Position');
      hh = 21*length(rows);
      pos(4) = hh;
      pos(2) = 240 - hh;
%       Htable.Position = pos;
%       Htable.Data = data;
      set(Htable, 'Position', pos);
      set(Htable, 'Data', data);
   end

   function plotRK(h,d)
%      if h.Value == 1
      if get(h, 'Value') == 1
         x = 1./T;
      else
         x = log(T);
      end
      if isempty(kFit)
         semilogy(x,kRev,'bo');
      else
         semilogy(x,kRev,'bo',x,kFit,'r-');
      end
      ylabel(['k (' kU ')']);
   end

   function showDev(h,d)
%       figure; stem(x,(kRev-kFit)./kRev);
      [hAx,hLine1,hLine2] = plotyy([x',x'],[kRev',kFit'],x,(kRev-kFit)./kRev,'semilogy','stem');
%       hLine1(1).LineStyle = 'none';
%       hLine1(1).Marker = 'o';
%       hLine1(1).Color = 'b';
%       hLine1(2).Color = 'r';
%       hLine2.Color  = [0 0.7 0];
%       hAx(2).YColor = [0 0.7 0];
       set(hLine1(1), 'LineStyle', 'none');
       set(hLine1(1), 'Marker', 'o');
       set(hLine1(1), 'Color', 'b');
       set(hLine1(2), 'Color', 'r');
       set(hLine2, 'Color', [0 0.7 0]);
       set(hAx(2), 'YColor', [0 0.7 0]);
      ylabel(hAx(1),['k (' kU ')']);
      ylabel(hAx(2),'deviation');
   end

   function accept(h,d)
%       coefNames  = Htable.RowName;
%       coefValues = Htable.Data;
      coefNames  = get(Htable, 'RowName');
      coefValues = get(Htable, 'Data');
%       switch Hfit.Value
      switch get(Hfit, 'Value')
         case {2 3 4}
            
%             keyboard
%             rkRev = ReactionLab.ReactionData.ReactionRate.MassAction;
            
         case 5   % k1 + k2
            
         otherwise
            
      end
%       closereq
   end

end