function speWindowInitialize(speGUI)
% speWindowInitialize(SpeciesDataGUIobj)
% sets the main window for species

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: December 20, 2011

speWindowInitialize@ReactionLab.SpeciesData.SpeciesGUI(speGUI);

Hfig = speGUI.Hfig;
Hlist = speGUI.Hlist;

figColor = get(Hfig,'Color');

set(speGUI.Hfind,'Callback', @localFind );
set(speGUI.Hlist,'Callback', @selectNewListItem );

% Create the button group
Hbtns = uibuttongroup('parent',Hfig,...
   'Units',   'pixels',...
   'Position',[220 450 140 30],...
   'BorderType', 'none',...
   'BackgroundColor', figColor,...
   'SelectionChangeFcn', @dataButtonGroup );
Hid = uicontrol('Parent',Hbtns,...
   'Style', 'togglebutton',...
   'Position', [5 5 60 20],...
   'String','Identity' );
uicontrol('Parent',Hbtns,...
   'Style', 'togglebutton',...
   'Position', [70 5 60 20],...
   'String', 'Thermo' );
set(Hbtns,'SelectedObject', Hid );

speGUI.Hbtns = Hbtns;

speGUI.speThermoPanelInitialize();
speGUI.speThermoFilesInitialize();
speGUI.Hthermo.panel = [speGUI.Hthermo.panel speGUI.Hfiles.panel];
speGUI.speCompareThermoInitialize();
speGUI.Hcurrent = speGUI.Hid;


   function localFind(h,d)
      speKey = get(h,'string');
      speKeyList = get(Hlist,'string');
      ind = find(strcmpi(speKey,speKeyList));
      if ~isempty(ind)
         set(Hlist,'listboxTop',ind);
         set(Hlist,'value',ind);
         dataButtonGroup([],[]);
      end
   end

   function selectNewListItem(h,d)
      set(speGUI.Hfiles.dataPanel,'Visible','off');
      ind = get(speGUI.Hlist,'value');
      spe = speGUI.SpeList.Values(ind);
      speGUI.CurrentSpecies = spe;
      speGUI.Hthermo.currentThermo = spe.Thermo;
      speGUI.Hcurrent.eval();
   end

   function dataButtonGroup(h,d)
      HselectedBtn = get(speGUI.Hbtns,'SelectedObject');
      str = get(HselectedBtn,'String');
      set(speGUI.Hcurrent.panel,'Visible','off');  drawnow; pause(0.02);
      switch str    % String property of selected object
         case 'Identity'
            speGUI.Hcurrent = speGUI.Hid;
            speGUI.displayIdPanel();
         case 'Thermo'
            speGUI.Hcurrent = speGUI.Hthermo;
            speGUI.displayThermoPanel();
         otherwise

      end
      set(speGUI.Hcurrent.panel,'Visible','on'); %drawnow
   end

end