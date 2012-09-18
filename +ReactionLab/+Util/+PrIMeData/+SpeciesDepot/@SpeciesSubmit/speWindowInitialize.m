function speWindowInitialize(speSubmit)
% speWindowInitialize(SpeciesSubmitObj)
% set the main window for species submission

% Copyright 1999-2012 Michael Frenklach
% % $Revision: 1.1 $
% Last modified: September 18, 2012

wLink = ReactionLab.Util.PrIMeData.WarehouseLink();

speWindowInitialize@ReactionLab.SpeciesData.SpeciesGUI(speSubmit);

Hfig = speSubmit.Hfig;   figColor = get(Hfig,'Color');
pos0 = get(Hfig,'Position');
pos0(1) = pos0(1) + 20;
pos0(2) = pos0(2) - 10;
set(Hfig,...
    'Name','Submit New Species to PrIMe',...
    'Position',pos0                      );
set(speSubmit.Hfind,'Visible','off');
set(speSubmit.Hid.panel(1),'visible','off')
uicontrol('Parent',Hfig,...
   'Style', 'text',...
   'Position', [10 440 120 20],...
   'BackgroundColor', figColor,...
   'ForegroundColor', 'b',...
   'FontSize', 10, ...
   'HorizontalAlignment','left',...
   'String','Species to submit');

set(speSubmit.Hlist,...
   'pos',[10 370 120 60], ...
   'Callback',@selectNewListItem );

d = speSubmit.Dict;
Hcomp = uicontrol('Parent',Hfig,...
   'Style', 'text',...
   'Position', [150 400 100 20],...
   'BackgroundColor', figColor,...
   'ForegroundColor', 'b',...
   'FontSize', 14, ...
   'HorizontalAlignment','left',...
   'String','');

Hinchi = uicontrol('Parent',Hfig,...
   'Style', 'text',...
   'Position', [10 340 400 20],...
   'BackgroundColor', figColor,...
   'ForegroundColor', 'b',...
   'FontSize', 10, ...
   'HorizontalAlignment','left',...
   'String','');


col2 = {'name' 'formula' ...
        'CASRegistryNumber' 'SMILES' 'PubChem' ...
        'CAIndexName' 'connectivity'};
speSubmit.Table = uitable('Parent',Hfig,...
   'Position',[10 45 400 250],...
   'ColumnWidth', { 300 98 },...
   'ColumnName',{'Species Identification' 'Type'},...
   'ColumnFormat',{'char' col2},...
   'ColumnEditable', [ true true], ...
   'RowName', [] ,...
   'Data', [] );

uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [30 10 140 20],...
   'FontSize', 10, ...
   'String','Add Species Name', ...
   'Tooltip','InChI is required',...
   'Callback', @addName );
uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [200 10 60 20],...
   'FontSize', 10, ...
   'String','Refresh', ...
   'Callback', @refresh );
uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [290 10 100 20],...
   'FontSize', 10, ...
   'String','Review', ...
   'Tooltip','Display XML',...
   'Callback', @showXML );


speSubmit.Hfound = uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [500 450 120 30],...
   'FontSize', 10, ...
   'String','Submit displayed', ...
   'Tooltip','InChI is required',...
   'Callback', @submitThis );
uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [680 450 60 30],...
   'FontSize', 10, ...
   'String','Close', ...
   'Callback', @done );

% set initial table values
% displaySpeNames();
selectNewListItem([],[]);
drawnow;


   function selectNewListItem(hh,dd)
      ind = get(speSubmit.Hlist,'value');
      spe = speSubmit.SpeList.Values(ind);
      speSubmit.CurrentSpeIndex = ind;
      speSubmit.CurrentSpecies = spe;
      set(Hcomp, 'String',upper(d{ind,5}));
      set(Hinchi,'String',spe.InChI);
      displaySpeNames();
      speSubmit.Hid.eval();
      if ~isempty(speSubmit.HgeomError)
         set(speSubmit.Hfound,'Enable','off');
      else
         set(speSubmit.Hfound,'Enable','on');
      end
   end

   function displaySpeNames()
      curSpe = speSubmit.CurrentSpecies;
      dat = {};
      if ~isempty(curSpe.Names)
         for i1 = 1:length(curSpe.Names)
            dat = [dat; {curSpe.Names{i1} 'name'}];
         end
      end
      if ~isempty(curSpe.Formulas)
         for i1 = 1:length(curSpe.Formulas)
            dat = [dat; {curSpe.Formulas{i1} 'formula'}];
         end
      end
      idKeys = curSpe.Ids.keys;
      if ~isempty(idKeys)
         for i1 = 1:length(idKeys)
            key = idKeys{i1};
            if strncmpi(key,'InChI',5)
            else
               dat = [dat; {curSpe.Ids(key) key}];
            end
         end
      end
      set(speSubmit.Table,'Data',dat);
   end
   
   function addName(h,d)
      dat = get(speSubmit.Table,'Data');
      answer = inputdlg('species identification','Enter value',1);
      if isempty(answer) || isempty(answer{:})
      else
         dat = [dat; answer {''}];
      end
      set(speSubmit.Table,'Data',dat);
   end

   function refresh(h,d)
      getData();
      speSubmit.setSpecies();
      displaySpeNames();
   end

   function getData()
    % remove empty lines from the table
      dat = get(speSubmit.Table,'Data');
      emptyLinesInd = find(cellfun(@isempty,dat(:,1)));
      if ~isempty(emptyLinesInd)
         dat(emptyLinesInd,:) = [];
         set(speSubmit.Table,'Data',dat);
      end
   end

   function showXML(h,d)
      refresh([],[]);
      curSpe = speSubmit.CurrentSpecies;
      speDoc = curSpe.spe2dom();
      v = ReactionLab.Util.PrIMeData.WarehouseLink.xmlViewer(speDoc);
      v.Title = curSpe.Key;
      v.ShowDialog;
   end

   function submitThis(hh,dd)
      refresh([],[]);
     % species to submit
      curSpe = speSubmit.CurrentSpecies;
     % before submitting as new species, check (again)
     %    if there exists a species with the same InChI in Warehouse
      primeId = ReactionLab.Util.PrIMeData.SpeciesDepot.PrIMeSpecies.warehouseSearch({'inchi',curSpe.InChI});
      if ~isempty(primeId)
         msg = {'There is already a species in the PrIMe Warehouse with the same InChI,'; ... 
                ' ';  curSpe.InChI ; ' '; ...
                'Resolve this before proceeding further.'; ' '; ...
                'Pressing OK will send an email to help with this.' };
         h = warndlg(msg,'multiple InChIs','modal');
         set(findobj(get(h,'Children'),'Tag','OKButton'),'Callback',@sendEmailFirst);
         return
      end
     % create a new XML doc for the new species
      speDoc = curSpe.spe2dom();
     % call submit window
      g = wLink.GenericEditor(curSpe.Key,speDoc.OuterXml);
      g.ShowDialog();
     % process the result
      if ~isempty(g.resultOfSubmitfile.status)
         cc = textscan(char(g.resultOfSubmitfile.result),'%s','delimiter','/');
         c = cc{:};
         newPrimeId = strtok(c{end},'.');
%          g.returnpath
%          g.returnobject
         speObj = ReactionLab.SpeciesData.Species(newPrimeId);
         speIDobj = speSubmit.SpeIdentity;
         speIDobj.addLocalSpecies(speObj);
         dictEntry = {curSpe.Key newPrimeId};
         speIDobj.updateSpeDict('buildupDictionary',dictEntry,'primeId');
         notInPrIMe = speIDobj.Hresults.notInPrIMe;
         notInPrIMe(strcmpi(notInPrIMe,curSpe)) = [];
         speIDobj.Hresults.notInPrIMe = notInPrIMe;
         speIDobj.displayResults;
      else
         errordlg(char(g.resultOfSubmitfile.statusMessage),'failed to submit','modal');
      end
%       g.resultOfValidateXML


         function sendEmailFirst(h,d)
            delete(gcbf);
            ReactionLab.Util.send_email('mfrenklach@gmail.com','duplicate species InChIs',...
               ['I want to submit a new species, ' curSpe.Key ', but a species' ...
                ' with the same InChI, ' curSpe.InChI ', already exist in the' ...
                ' PrIMe Warehouse.  Which one is the correct one?']  );
         end
         
   end

   function done(hh,dd)
      speSubmit.Completed = true;
      set(Hfig,'DeleteFcn',[]);
      closereq;
   end

end