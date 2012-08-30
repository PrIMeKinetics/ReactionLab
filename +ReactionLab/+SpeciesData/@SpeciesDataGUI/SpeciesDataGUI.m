classdef SpeciesDataGUI < ReactionLab.SpeciesData.SpeciesGUI

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 21, 2012
   
   properties
      Hbtns

      Hthermo
      HthermoCompare
      Hfiles
      Hcurrent
      
      sUnitsList = {'cal/mol_K','J/mol_K'};
      hUnitsList = {'kcal/mol','kJ/mol'};
      thermoUnitsIndex = 1;
   end
   
   properties (Dependent = true)
      hUnits
      sUnits
   end
   
   methods
      function obj = SpeciesDataGUI(arg)
         if nargin > 0
            if isa(arg,'ReactionLab.SpeciesData.SpeciesList')
               obj.SpeList     = arg;
               obj.PrevSpeList = arg;
            elseif isa(arg,'ReactionLab.SpeciesData.Species')
               speList = ReactionLab.SpeciesData.SpeciesList();
               speList.add(arg);
               obj.SpeList = speList;
            else
               error(['incorrect object class ', class(arg)]);
            end
            speWindowInitialize(obj);
            obj.setWindowList();
            obj.CurrentSpecies = obj.SpeList.Values(1);
            obj.Hthermo.currentThermo = obj.CurrentSpecies.Thermo;
            obj.displayIdPanel();
            set(obj.Hid.panel,'Visible','on');
            set(obj.Hfig,'Visible','on');
         end
      end
      
      function y = get.hUnits(obj)
         y = obj.hUnitsList{obj.thermoUnitsIndex};
      end
      function y = get.sUnits(obj)
         y = obj.sUnitsList{obj.thermoUnitsIndex};
      end

   end
   
end