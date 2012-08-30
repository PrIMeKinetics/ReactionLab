function speWindowInitialize(speGUI)
% speWindowInitialize(SpeciesGUIobj)
% sets the main window for species

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: April 7, 2012

pos = [50 200 850 490];
Hfig = figure('Position', pos,...
   'NumberTitle', 'off',...
   'Name', 'species',...
   'Tag', 'species',...
   'MenuBar', 'none',...
   'Visible','off',...
   'Resize','off' );

speGUI.Hfind = uicontrol('Parent',Hfig,...
   'Style', 'edit',...
   'BackgroundColor', 'white',...
   'ForegroundColor', 'blue',...
   'HorizontalAlignment', 'left',...
   'Position', [10 450 120 20],...
   'Callback', @localFind );
Hlist = uicontrol('Parent',Hfig,...
   'Style', 'listbox',...
   'BackgroundColor', 'white',...
   'Position', [10 10 120 430],...
   'Callback', @selectNewListItem );

speGUI.Hfig  = Hfig;
speGUI.Hlist = Hlist;

speGUI.speIdPanelInitialize();
speGUI.speGeomPanelInitialize();
speGUI.Hid.panel = [speGUI.Hid.panel speGUI.Hgeom.panel];


   function localFind(h,d)
      speKey = get(h,'string');
      speKeyList = get(Hlist,'string');
      ind = find(strcmpi(speKey,speKeyList));
      if ~isempty(ind)
         set(Hlist,'listboxTop',ind);
         set(Hlist,'value',ind);
      end
   end

   function selectNewListItem(h,d)
      ind = get(speGUI.Hlist,'value');
      spe = speGUI.SpeList.Values(ind);
      speGUI.CurrentSpecies = spe;
      speGUI.Hid.eval();
   end

end