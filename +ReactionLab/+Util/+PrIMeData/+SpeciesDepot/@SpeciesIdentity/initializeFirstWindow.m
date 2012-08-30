function initializeFirstWindow(obj)
% initializeFirstWindow(SpeciesIdentityObj)
% set the initial panel: 
%  loading and identifying species

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: March 29, 2012

Hpanel = obj.Hpanel;

panelColor = get(Hpanel,'BackgroundColor');

uicontrol('Parent',Hpanel,...
   'Style', 'text',...
   'BackgroundColor', panelColor,...
   'ForegroundColor', 'blue',...
   'HorizontalAlignment', 'left',...
   'Position', [10 400 325 20],...
   'FontSize', 10, ...
   'String','IDENTIFYING SPECIES');

obj.SpeDictBtn = uicontrol('Parent',Hpanel,...
   'Style', 'pushbutton',...
   'Position', [10 350 200 20],...
   'FontSize', 10, ...
   'String','Upload Species Dictionary',...
   'Callback', @selectSpeDictFile );

obj.Table = uitable('Parent',Hpanel,...
   'Position',[10 230 310 100],...
   'ColumnWidth', { 184 60 60 },...
   'ColumnName',{'Name' 'ID Type' ' '},...
   'ColumnFormat',{'char','char','logical'},...
   'ColumnEditable', [ false false true ], ...
   'RowName', [] ,...
   'Data', [] );

uicontrol('Parent',Hpanel,...
   'Style', 'popupmenu',...
   'HorizontalAlignment', 'left',...
   'Position', [260 340 60 20],...
   'FontSize', 10, ...
   'String',{'Action' 'Remove' 'Merge' 'Restore' 'Edit' 'Convert'},...
   'Callback', @localAction );

obj.HrxnSpeBtn = uicontrol('Parent',Hpanel,...
   'Style', 'pushbutton',...
   'Position', [10 10 200 20],...
   'FontSize', 10, ...
   'String','Match Reaction Species',...
   'Visible', 'off',...
   'Callback', @matchRxnSpe );

% results of conversion
initializeResultsPanel(obj);
obj.setCurrentData();
if isempty(obj.Spe2id)
   set(obj.HrxnSpeBtn,'Visible','off');
else
   set(obj.HrxnSpeBtn,'Visible','on');
end


   function selectSpeDictFile(h,d)
      [c,fileName] = ReactionLab.Util.getExcelFile('Species Dictionary');
      if ~isempty(c)
%          answer = questdlg('Select Species Identifyier Type',...
%             'species id type','primeId','InChI','InChI');
         [~,fn] = fileparts(fileName);
         if strcmpi(fn(end-3:end),'comp')
            y = obj.addSpeDict(fileName,c,'comp');
         else
            y = obj.addSpeDict(fileName,c);
         end
         if y
            obj.setCurrentData();
         end
      end
   end

   function localAction(hh,dd)
      data = get(obj.Table,'Data');
      ind = find([data{:,3}]);
      val = get(hh,'Value');
      str = get(hh,'String');
      set(hh,'Value',1);
      option = str{val};
      if any(strcmp(option,{'Restore' 'New'}))
         ind = 0;
      end
      if ~isempty(ind)
         switch option
            case 'Action'
%             case 'View'
%                d = obj.SpeDict(ind(1));
%                ReactionLab.Util.displayCellArray(d.dict,d.fileName);
            case 'Remove'
               obj.SpeDictPrev = obj.SpeDict;
               obj.SpeDict(ind) = [];
               obj.setCurrentData();
            case 'Merge'
               if length(ind) < 2, return, end
               [d,type] = obj.getDictByIndex(ind);
               if isempty(d)
                  errordlg('Selected directories are not of the same type','','modal')
                  return
               end
               answer = inputdlg('Enter the name for the merged dictionary',...
                                 'Species Dictionary',1,{'mergedDictionary'} );
               if ~isempty(answer)
                  obj.SpeDictPrev = obj.SpeDict;
                  obj.SpeDict(ind) = [];
                  obj.addSpeDict(answer,d,type);
                  obj.setCurrentData();
               end
            case 'Restore'
               obj.SpeDict = obj.SpeDictPrev;
               obj.setCurrentData();
            case 'Edit'
               if length(ind) ~= 1
                  errordlg('use single selection','','modal');
                  return
               end
               obj.editCellArray(ind);
            case 'Convert'
               if length(ind) ~= 1
                  errordlg('use single selection','','modal');
                  return
               end
               di = obj.SpeDict(ind);
               switch lower(di.type)
                  case 'primeid'
                     
                  case 'inchi'
                     if isempty(di.match)
                        if check4duplicateKeys(di.dict,di.fileName), return, end
                        dOut = inchi2primeid(obj,di.dict);
                        d = dOut(2);
                        if d.completed
                           di.match = {dOut(1) dOut(2)};
                           obj.SpeDict(ind) = di;
                           obj.Hresults.dictInd = ind;
                          % matched by primeId
                           obj.updateSpeDict('buildupDictionary',dOut(1).found(:,1:2),'primeId');
                           obj.setCurrentData();
                        end
                     else                      
                        d = di.match{2};
                     end
                     obj.Hresults.matched  = ReactionLab.Util.cellMerge(obj.Hresults.matched, d.found   );
                     obj.Hresults.multiple = ReactionLab.Util.cellMerge(obj.Hresults.multiple,d.multiple);
                     obj.Hresults.notFound = ReactionLab.Util.cellMerge(obj.Hresults.notFound,d.notFound);
                     obj.displayResults();
                  otherwise
                     
               end
               
%             case 'Save'
%                d = obj.SpeDict(ind(1));
%                ReactionLab.Util.saveExcelFile(d.dict,d.fileName);
            otherwise
               error(['undefined option ' option]);
         end
%          set(hh,'Value',1);
      end
      
   end


   function y = check4duplicateKeys(d,fileName)
   % check if there are multiple keys in the dictionary
      dSorted = sortrows(d,1);
      [~,~,m] = unique(dSorted(:,1));
      ii = find(~diff(m));
      if isempty(ii)
         y = false;
      else
         y = true;
         errMessage = [{['multiple entries in dictionary ' fileName ':']}; ...
                        {' '}; dSorted(ii,1)                   ];
         errordlg(errMessage,'multiple records','modal');
      end
   end



%    function done(hh,dd)
%       obj.setSpeciesList2id();
%       obj.identifySpecies;
%    end

end