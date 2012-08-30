classdef ChemkinMech < handle
   
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: February 13, 2012
   
   properties (SetAccess = 'private')
      MechFileName = '';
      StrMechFile  = {};
      
      ElementTxt  = {};
      SpeciesTxt  = {};
      
      ThermoFileName = '';
      ThermoTxt   = {};
      
      ReactionTxt = {};
      Reactions
      
      ThermoArray
      
      Hfig
      BottomPanel
      RightPanel
      HpanelTemplate
      Panels
      CurrentPanelIndex = 0;
      
      SpeciesIdentity
   end
   
   properties
      Species = {};
   end
   
   properties (Dependent)
      CurrentPanel
   end

   
   methods
      function obj = ChemkinMech(arg)
         if nargin > 0
            obj.mainWindowInitialize();
            switch lower(arg)
               case {'mech' 'mechanism' 'chemkin' ''}
                  
               case {'species'}
                  set(obj.Hfig,'Name','Identify Species');
                  set(obj.Panels{1}.title,'String','');
                  set(obj.Panels{1}.mechBtn,     'Visible','off');
                  set(obj.Panels{1}.transportBtn,'Visible','off');
                  set(obj.Panels{1}.thermoBtn,'String','Select Thermo File');
                  set(obj.Panels{1}.thermoBtn,'Enable', 'on' );
                  set(obj.BottomPanel.Hnext,  'Enable', 'on' );
               otherwise
                  error('undefined input argument');
            end
            
         end
      end
      
      function H = get.CurrentPanel(obj)
         curPanel = obj.Panels{obj.CurrentPanelIndex};
         H = curPanel.Hpanel;
      end
      
      function load(obj)
         [str,fileName] = ReactionLab.Util.getTextFile('Chemkin Mech File');
         if ~isempty(str)
            obj.MechFileName = fileName;
            obj.StrMechFile  = str;
         end
      end
      
      function parse2text(obj)
      % parse Chemkin mechanism file into text sections
         chemkinTxt = obj.StrMechFile;
         iElem = ReactionLab.Util.findKeyword(chemkinTxt,'ELEMENTS');
         iSpe  = ReactionLab.Util.findKeyword(chemkinTxt,'SPECIES');
         obj.ElementTxt = chemkinTxt(iElem:iSpe-1);
         iRxn  = ReactionLab.Util.findKeyword(chemkinTxt,'REACTIONS');
         iTh   = ReactionLab.Util.findKeyword(chemkinTxt,'THERMO');
         if ~isempty(iTh)
            obj.SpeciesTxt = chemkinTxt(iSpe:iTh-1);
            obj.ThermoTxt  = chemkinTxt(iTh:iRxn-1);
         else
            obj.SpeciesTxt = chemkinTxt(iSpe:iRxn-1);
         end
         obj.ReactionTxt = chemkinTxt(iRxn:end);
      end
   end
   
end