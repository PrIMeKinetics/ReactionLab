function speWindowInitialize(speIdGUI)
% speWindowInitialize(SpeciesIdentityGUIobj)
% sets the main window for species identity

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: March 30, 2012

d = speIdGUI.Dict;
speWindowInitialize@ReactionLab.SpeciesData.SpeciesGUI(speIdGUI);

Hfig = speIdGUI.Hfig;   figColor = get(Hfig,'Color');
pos0 = get(Hfig,'Position');
pos0(1) = pos0(1) + 20;
pos0(2) = pos0(2) - 10;
set(Hfig,'Name','Species by InChI',...
         'Position',pos0          ,...
         'DeleteFcn', @cancel       );
Hlist = speIdGUI.Hlist;
pos = get(Hlist,'Position');
pos(4) = 300;
cmenu2 = uicontextmenu;
uimenu(cmenu2,'Label','Select','Callback',@selectThis);
set(Hlist,'Position',pos, ...
          'Callback', @selectNewListItem,...
          'UIContextMenu',cmenu2);
set(speIdGUI.Hfind,'Visible','off');

cmenu1 = uicontextmenu;
uimenu(cmenu1,'Label','Add to ''not found''',...
              'Callback',@selectThis);
uicontrol('Parent',Hfig,...
   'Style', 'text',...
   'Position', [10 440 120 20],...
   'BackgroundColor', figColor,...
   'ForegroundColor', 'b',...
   'FontSize', 10, ...
   'HorizontalAlignment','left',...
   'String','Species to resolve');

pos(2) = 350;
pos(4) =  90;
speIdGUI.HtopList = uicontrol('Parent',Hfig,...
   'Style', 'listbox',...
   'Position', pos,...
   'String',d(:,1),...
   'Callback', @select2resolve,...
   'UIContextMenu',cmenu1);

uicontrol('Parent',Hfig,...
   'Style', 'text',...
   'Position', [10 310 120 20],...
   'BackgroundColor', figColor,...
   'ForegroundColor', 'b',...
   'FontSize', 10, ...
   'HorizontalAlignment','left',...
   'String','Match found' );

speIdGUI.Hfound = uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [200 450 120 30],...
   'FontSize', 10, ...
   'String','Select displayed', ...
   'Callback', @selectThis );
speIdGUI.HnotFound = uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [330 450 200 30],...
   'FontSize', 10, ...
   'String','Add unresolved to ''not found''', ...
   'Callback', @add2notFound );
uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [540 450 60 30],...
   'FontSize', 10, ...
   'String','Restore', ...
   'Callback', @restore );
uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [610 450 60 30],...
   'FontSize', 10, ...
   'String','Cancel', ...
   'Callback', @cancel );
uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [680 450 60 30],...
   'FontSize', 10, ...
   'String','Done', ...
   'Callback', @done );


   function selectNewListItem(hh,dd)
%       set(speIdGUI.Hfiles.dataPanel,'Visible','off');
      ind = get(speIdGUI.Hlist,'value');
      spe = speIdGUI.SpeList.Values(ind);
      speIdGUI.CurrentSpecies = spe;
      speIdGUI.Hid.eval();
   end

   function select2resolve(hh,dd)
      ind = get(speIdGUI.HtopList,'Value');
      speIdGUI.CurrentSpeIndex = ind;
      speIdGUI.setSpeciesList();
      speIdGUI.setWindowList();
      set(speIdGUI.Hlist,'Value',1);
      selectNewListItem([],[]);
   end

   function selectThis(hh,dd)
      indSelected  = get(speIdGUI.Hlist,'Value');
      indSpe2match = get(speIdGUI.HtopList,'Value');
      d = speIdGUI.Dict;
      speObj = speIdGUI.SpeList.Values(indSelected);
      found2add = [d(indSpe2match,1) {{speObj.PrimeId speObj}} d(indSpe2match,3) speObj.InChI];
      speIdGUI.Found2add = [speIdGUI.Found2add; found2add ];
      d(indSpe2match,:) = [];
      speIdGUI.Dict = d;
      if isempty(d)
         set(speIdGUI.HtopList,'String',{});
         set(speIdGUI.Hlist,   'String',{});
      else
         set(speIdGUI.HtopList,'String',d(:,1));
         set(speIdGUI.HtopList,'Value',1);
         select2resolve([],[]);
      end
   end

   function add2notFound(hh,dd)
%       indSelected    = get(speIdGUI.Hlist,'Value');
      indSpeNotFound = get(speIdGUI.HtopList,'Value');
      d = speIdGUI.Dict;
      speIdGUI.NotFound2add = [speIdGUI.NotFound2add; d(indSpeNotFound,:) ];
      d(indSpeNotFound,:) = [];
      speIdGUI.Dict = d;
      if isempty(d)
         set(speIdGUI.HtopList,'String',{});
         set(speIdGUI.Hlist,   'String',{});
      else
         set(speIdGUI.HtopList,'String',d(:,1));
         set(speIdGUI.HtopList,'Value',1);
         select2resolve([],[]);
      end
   end

   function restore(hh,dd)
      d = speIdGUI.PrevDict;
      speIdGUI.Dict = d;
      speIdGUI.Found2add    = {};
      speIdGUI.NotFound2add = {};
      set(speIdGUI.HtopList,'String',d(:,1));
      set(speIdGUI.HtopList,'Value',1);
      select2resolve([],[]);
   end

   function cancel(hh,dd)
%       restore([],[]);
      speIdGUI.Dict = speIdGUI.PrevDict;
      speIdGUI.Found2add    = {};
      speIdGUI.NotFound2add = {};
      closereq;
   end

   function done(hh,dd)
      speIdGUI.Completed = true;
      set(Hfig,'DeleteFcn',[]);
      closereq;
   end

end