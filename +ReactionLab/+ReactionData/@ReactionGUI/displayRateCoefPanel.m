function displayRateCoefPanel(rxnGUI,r)
% displayRateCoefPanel(rxnGUIobj,ReactionObject)

% Copyright 1999-2010 Michael Frenklach
% $ Revision: 1.1 $
% Last modified: November 21, 2010

set(rxnGUI.Hrk.eqn,'String', r.Eq );
rk = r.RateCoef;

% get pressure value
if rk.isPdepedent
   indP = 1;
   set([rxnGUI.Hrk.pLabel rxnGUI.Hrk.P rxnGUI.Hrk.pUnits],...
       'Visible', 'on');
   P = str2num(get(rxnGUI.Hrk.P, 'String'));
   if isempty(P) || any(P < 0)
      Hdlg = errordlg('Pressure values must be positive',...
                   'evaluation of rate coefficient','modal');
      waitfor(Hdlg);
      setFields('');
      set(rxnGUI.Hrk.panel,'Visible','on');
      rxnGUI.HcurrentPanel = rxnGUI.Hrk.panel;
      return;
   end
   lenP = length(P);
else
   indP = 0;
   set([rxnGUI.Hrk.pLabel rxnGUI.Hrk.P rxnGUI.Hrk.pUnits],...
       'Visible', 'off');
end

%  get temperature value
T = str2num(get(rxnGUI.Hrk.T, 'String'));
if isempty(T) || any(T <= 0)
   Hdlg = errordlg('Temperature values must be positive',...
                   'evaluation of rate coefficient','modal');
   waitfor(Hdlg);
   setFields('');
   set(rxnGUI.Hrk.panel,'Visible','on');
   rxnGUI.HcurrentPanel = rxnGUI.Hrk.panel;
   return;
end
lenT = length(T);
if lenT == 2
   T = linspace(1/T(1),1/T(end),30);
   lenT = length(T);
end

% evaluation
rxnGUI.eqKunitsIndex = rxnGUI.aUnitsIndex;
eqK = r.keq(T,rxnGUI.eqKunits);
if indP == 0
   if lenT > 1
      setFields('');
      kF = rk.eval(T,rxnGUI.aUnits);
      rxnGUI.displayRateCoefTable(r,T,kF,eqK);
   else % no P, array of T
      setFields( rk.eval(T,rxnGUI.aUnits) );
   end
else
   if lenP == 2
      P = logspace(P(1),P(end),30);
      lenP = length(P);
   end
   if lenT == 1 && lenP == 1
      setFields(rk.eval(T,rxnGUI.aUnits,P,rxnGUI.pUnits));
   elseif lenT > 1  && lenP > 1
      setFields('');
      kF = zeros(lenT,lenP);
      for i1 = 1:lenP
         kF(:,i1) = rk.eval(T',rxnGUI.aUnits,P(i1),rxnGUI.pUnits);
      end
      kR = kF./repmat(eqK',1,lenP);
      rxnGUI.displayRateCoefTable3d(r,T,kF,kR,P);
   else
      setFields('');
      kF = rk.eval(T,rxnGUI.aUnits,P,rxnGUI.pUnits);
      rxnGUI.displayRateCoefTable(r,T,kF,eqK,P);
   end
end

set(rxnGUI.Hrk.panel,'Visible','on');
rxnGUI.HcurrentPanel = rxnGUI.Hrk.panel;


   function setFields(kF)
      if isempty(kF)
         set(rxnGUI.Hrk.Forw,'String','');
         set(rxnGUI.Hrk.Rev, 'String','');
         set(rxnGUI.Hrk.eqK, 'String','');
      else
         set(rxnGUI.Hrk.Forw,'String',sprintf('%.2g',kF));
         set(rxnGUI.Hrk.Rev, 'String',sprintf('%.2g',kF./eqK));
         set(rxnGUI.Hrk.eqK, 'String',sprintf('%.2g',  eqK  ));
      end
   end


end