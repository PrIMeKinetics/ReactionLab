classdef SpeciesSubmit < ReactionLab.SpeciesData.SpeciesGUI

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: September 18, 2012

   properties
      Dict
     
      CurrentSpeIndex
      
      Found2add    = {};
      NotFound2add = {};

      HtopList
      Hfound
      HnotFound
      Completed = false;
      
      SpeIdentity
      Table
   end
  
   
   methods
      function obj = SpeciesSubmit(arg)
         if nargin > 0
            obj.SpeIdentity = arg;
            obj.Dict = arg.Hresults.notInPrIMe;
            
            obj.Completed = false;
            obj.CurrentSpeIndex = 1;
            obj.setSpeciesList();
            obj.CurrentSpecies = obj.SpeList.Values(1);
            speWindowInitialize(obj);
            obj.setWindowList();
            if isempty(obj.CurrentSpecies.InChI)
               set(obj.Hfound,'Enable','off');
            end
%             obj.displayIdPanel();
%             set(obj.Hid.panel,'Visible','on');
            set(obj.Hfig,'Visible','on');
         end
      end
   end

end