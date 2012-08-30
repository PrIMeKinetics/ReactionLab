classdef ReactionGUI < dynamicprops

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011
   
   properties
      Hfig          = [];
      Hlist         = [];
      Hbtns         = [];
      Hid
      Hthermo
      Hrk
      HcurrentPanel = [];
      
      RxnList
      PrevRxnList
      
      CurrentReaction
      
      aUnitsList = {'cm3/mol,s' 'cm3,s'};
      eUnitsList = {'kcal/mol' 'cal/mol' 'kJ/mol' 'J/mol' 'K'};
      aUnitsIndex = 1;
      eUnitsIndex = 1;
      sUnitsList = {'cal/mol_K' 'J/mol_K'};
      hUnitsList = {'kcal/mol' 'kJ/mol'};
      thermoUnitsIndex = 1;
      eqKunitsList = {'mol/cm3' 'cm-3' 'atm'};
      eqKunitsIndex = 1;
      pUnitsList = {'atm' 'torr' 'bar'};
      pUnitsIndex = 1;
   end
   
   properties (Dependent = true)
      aUnits
      eUnits
      hUnits
      sUnits
      eqKunits
      pUnits
   end
   
   methods
      function obj = ReactionGUI(arg)
         rxnWindowInitialize(obj);
         if nargin > 0
            if isa(arg,'ReactionLab.ReactionData.ReactionList')
               obj.RxnList     = arg;
               obj.PrevRxnList = arg;
               obj.setWindowList();
            elseif isa(arg,'ReactionLab.ReactionData.Reaction')
               rxnList = ReactionLab.ReactionData.ReactionList();
               rxnList.add(arg);
               obj.RxnList = rxnList;
               obj.setWindowSet();
            else
               error(['incorrect object class ', class(arg)]);
            end
         end
         obj.buttonClick();
      end
      
      
      function y = get.aUnits(obj)
         y = obj.aUnitsList{obj.aUnitsIndex};
      end
      function y = get.eUnits(obj)
         y = obj.eUnitsList{obj.eUnitsIndex};
      end
      function y = get.hUnits(obj)
         y = obj.hUnitsList{obj.thermoUnitsIndex};
      end
      function y = get.sUnits(obj)
         y = obj.sUnitsList{obj.thermoUnitsIndex};
      end
      function y = get.eqKunits(obj)
         y = obj.eqKunitsList{obj.eqKunitsIndex};
      end
      function y = get.pUnits(obj)
         y = obj.pUnitsList{obj.pUnitsIndex};
      end
      
      function setWindowList(obj)
         r = obj.RxnList.Values;
         set(obj.Hlist,'String',{r.Eq});
      end
      
      function buttonClick(obj)
         ind = get(obj.Hlist,'value');
         rxn = obj.RxnList.Values(ind);
         obj.CurrentReaction = rxn;
         HselectedBtn = get(obj.Hbtns,'SelectedObject');
         tag = get(HselectedBtn,'Tag');
         if ~isempty(obj.HcurrentPanel)
            set(obj.HcurrentPanel,'Visible','off');
         end
         switch tag    % Tag of selected object
            case 'rxnIdentityBtn'
               displayIdPanel(obj,rxn);
            case 'rxnThermoBtn'
               displayThermoPanel(obj,rxn);
            case 'rxnRateCoefBtn'
               displayRateCoefPanel(obj,rxn);
            otherwise

         end
      end
   end
   
end