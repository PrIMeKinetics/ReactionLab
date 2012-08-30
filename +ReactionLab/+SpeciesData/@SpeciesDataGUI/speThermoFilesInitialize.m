function speThermoFilesInitialize(speGUI)
% speThermoFilesInitialize(speGUIobj)

% Copyright 1999-2011 Michael Frenklach
% $ Revision: 1.1 $
% Last modified: January 16, 2011

Hpanel = uipanel('parent',speGUI.Hfig,...
   'units','pixels',...
   'Position', [560 10 280 430],...
   'Visible', 'off' );
speGUI.Hfiles.panel = Hpanel;
speGUI.Hfiles.refElemThermo = containers.Map;
speGUI.Hfiles.thList = [];
speGUI.Hfiles.thObjMap  = [];
speGUI.Hfiles.thFileMap = [];
thObjSelected = [];
speGUI.Hfiles.thObjSelected = thObjSelected;

bkColor = [0.9 0.9 0.9];   % get(speGUI.Hfig,'Color')
uicontrol('Parent',Hpanel,...
   'Style', 'pushbutton',...
   'Position', [20 390 130 25],...
   'BackgroundColor', bkColor,...
   'ForegroundColor', 'blue',...
   'String', 'List PrIMe thermo files',...
   'Callback', @displayData );

HdataPanel = uipanel('parent',Hpanel,...
   'units','normalized',...
   'Position', [0 0 1 0.9],...
   'BorderType', 'none', ...
   'Visible', 'off'    );
speGUI.Hfiles.dataPanel = HdataPanel;

speGUI.Hfiles.spePrimeId = uicontrol('Parent',HdataPanel,...
   'Style', 'text',...
   'Position', [160 385 100 25],...
   'HorizontalAlignment', 'left',...
   'String', '' );

uicontrol('Parent',HdataPanel,...
   'Style', 'text',...
   'Position', [20 340 130 25],...
   'HorizontalAlignment', 'left',...
   'String', 'PrIMe BestCurrent Thermo: ' );
speGUI.Hfiles.bestCurrent = uicontrol('Parent',HdataPanel,...
   'Style', 'text',...
   'Position', [160 340 80 25],...
   'ForegroundColor', 'blue',...
   'HorizontalAlignment', 'left',...
   'String', '' );

Htable = uitable('Parent',HdataPanel,...
        'Position',[10 130 260 150],...
        'ColumnWidth', { 80 120 40 },...
        'ColumnName', {'primeID' 'source' 'select'},...
        'ColumnFormat', {'numeric' 'numeric' 'logical'},...
        'ColumnEditable', [ false false true ], ...
        'RowName', [] ,...
        'Data', {[] [] true}, ...
        'CellSelectionCallback', @selectThermo );
%         'CellEditCallback', @selectThermo );
speGUI.Hfiles.table = Htable;

uicontrol('Parent',HdataPanel,...
   'Style', 'popupmenu',...
   'Position', [210 285 60 20],...
   'BackgroundColor', bkColor,...
   'ForegroundColor', 'blue',...
   'String',{'Action' 'Compare all' 'Restore'},...
   'Callback', @localAction );

metaProperties = {'Metadata' 'submittedBy' 'updateReason' ...
          'getlastmodified' 'creationdate' ...
          'displayname' 'getcontentlength' 'getcontenttype'};
speGUI.Hfiles.metaProp = uicontrol('Parent',HdataPanel,...
   'Style', 'popupmenu',...
   'Position', [10 90 100 20],...
   'BackgroundColor', bkColor,...
   'ForegroundColor', 'blue',...
   'String',metaProperties,...
   'Callback', @metaData );
Hmeta = uicontrol('Parent',HdataPanel,...
   'Style', 'text',...
   'Position', [20 20 250 60],...
   'HorizontalAlignment', 'left',...
   'String', '' );


   function displayData(h,d)
      speGUI.displayThermoFiles();
      set(HdataPanel,'Visible','on');
      metaData([],[]);
   end

   function selectThermo(h,d)
      ii = d.Indices;
      if isempty(ii), return, end
      ind = unique(ii(:,1));
      data = get(Htable,'Data');
      data(:,3) = {false};
      thObjSelected = ReactionLab.ThermoData.ThermoPP.empty(1,0);
      for i1 = 1:length(ind)
         indSelected = ind(i1);
         thId = data{indSelected,1};
         thObjSelected(i1) = speGUI.Hfiles.thObjMap(thId);
         data{indSelected,3} = true;
      end
      set(Htable,'Data',data);
      speGUI.Hfiles.thObjSelected = thObjSelected;
      if length(ind) == 1
         localAction([],4);   % Display
      elseif length(ind) > 1
         localAction([],5)    % Compare
      end
      drawnow;
   end
   
   function localAction(h,d)
      if isempty(h)
         ind = d;
      else
         ind = get(h,'Value');   % 2-Compare all, 3-Restore, 4-Display, 5-Compare, 
      end
      switch ind
         case 1
            return;
         case 2    % Compare all
            data = get(Htable,'Data');
            if size(data,1) < 2, return, end
            data(:,3) = {true};
            set(Htable,'Data',data);
            speGUI.Hfiles.thObjSelected = speGUI.Hfiles.thList;
            speGUI.displayCompareThermo();
         case 3    % Restore
            speGUI.Hthermo.currentThermo = speGUI.CurrentSpecies.Thermo;
            data = get(Htable,'Data');
            ind = find(strcmp(data(:,1),speGUI.CurrentSpecies.Thermo.Id));
            for i2 = 1:size(data,1)
               if i2 == ind
                  data{i2,3} = true;
               else
                  data{i2,3} = false;
               end
            end
            set(Htable,'Data',data);
            speGUI.displayThermoPanel();
         case 4    %  Display
            if length(speGUI.Hfiles.thObjSelected) == 1
               speGUI.Hthermo.currentThermo = speGUI.Hfiles.thObjSelected;
               speGUI.displayThermoPanel();
            end
         case 5    % Compare
            if length(speGUI.Hfiles.thObjSelected) > 1
               speGUI.displayCompareThermo();
            end
      end
      set(h,'value',1);   % get back to diplaying 'Action')
      metaData([],[]);
   end

   function metaData(h,d)
      ind = get(speGUI.Hfiles.metaProp,'Value');
      if ind == 1
         set(Hmeta,'String','');
         return
      end
      if length(speGUI.Hfiles.thObjSelected) ~= 1
         set(h,'value',1);
         set(Hmeta,'String','');
         return
      end
      thFile = speGUI.Hfiles.thFileMap(speGUI.Hfiles.thObjSelected.Id);
      set(Hmeta,'String',thFile.getProperty(metaProperties{ind}));
   end

end