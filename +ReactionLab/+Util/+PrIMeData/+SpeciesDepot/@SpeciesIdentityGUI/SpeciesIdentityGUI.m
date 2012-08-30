classdef SpeciesIdentityGUI < ReactionLab.SpeciesData.SpeciesGUI

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 21, 2012

   properties
      PrevDict
      Dict
     
      CurrentSpeIndex
      
      Found2add    = {};
      NotFound2add = {};

      HtopList
      Hfound
      HnotFound
      Completed = false;
   end
  
   
   methods
      function obj = SpeciesIdentityGUI(arg)
         if nargin > 0
            if iscell(arg)
               obj.Dict = arg;
               obj.PrevDict = arg;
            elseif ischar(arg)

            else
               error(['incorrect object class ', class(arg)]);
            end
            
            obj.CurrentSpeIndex = 1;
            obj.Completed = false;
            obj.setSpeciesList();
            speWindowInitialize(obj);
            obj.setWindowList();
            obj.CurrentSpecies = obj.SpeList.Values(1);
            obj.displayIdPanel();
            set(obj.Hid.panel,'Visible','on');
            set(obj.Hfig,'Visible','on');
         end
      end
      
      function setSpeciesList(obj)
         d   = obj.Dict;
         ind = obj.CurrentSpeIndex();
         speList = ReactionLab.SpeciesData.SpeciesList();
         speList = speList.add(d{ind,2}(:,2));
         obj.SpeList     = speList;
         obj.PrevSpeList = speList;
      end
   end
   
   methods (Abstract)
      setButtonNames(obj)
   end

end