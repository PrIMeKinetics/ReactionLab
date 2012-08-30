classdef SpeciesGUI < handle

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 21, 2012
   
   properties
      Hfig
      Hfind
      Hlist
      Hid
      Hgeom
      
      SpeList
      PrevSpeList
      
      CurrentSpecies
   end

   
   methods
      function obj = SpeciesGUI(arg)
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
            obj.displayIdPanel();
            set(obj.Hid.panel,'Visible','on');
            set(obj.Hfig,'Visible','on');
         end
      end
      
      function setWindowList(obj)
         s = obj.SpeList.Values;
         set(obj.Hlist,'String',{s.Key});
      end

   end
   
end