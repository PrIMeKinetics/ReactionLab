classdef SpeciesIdentity < handle

% Copyright 1999-2013 Michael Frenklach
% Last modified: December 9, 2012

   properties (SetAccess = 'private')
      Chemkin
      Hpanel
      
      MainSpeDict
      
      SpeDictBtn
      Table
   end


   properties
      SpeDict = struct('fileName',{},'dict',{},'type',{},'match',{});
      SpeDictPrev
%       SetCurDataFcn

      LocalSpeWare = ReactionLab.SpeciesData.SpeciesList();

      HrxnSpeBtn
      Spe2id      = {};  % { speName }
      SpeFound    = {};  % { key,  primeId , ind, speObj}
      SpeNotFound = {};  % { key,       '' , ind, inchi }
      
      Hresults
   end
  
   
   methods
      function obj = SpeciesIdentity(chemkinObj)
         if nargin > 0
            [~,obj.MainSpeDict] = xlsread(which('+ReactionLab/+Util/+PrIMeData/+SpeciesDepot/defaultSpeciesDictionary.xlsx'));
            obj.addSpeDict('defaultSpeciesDictionary',obj.MainSpeDict,'primeId');
            obj.Chemkin = chemkinObj;
            obj.Hpanel = feval(chemkinObj.HpanelTemplate);
            obj.initializeFirstWindow();
         end
      end
      
      function addLocalSpecies(obj,s)
         obj.LocalSpeWare = obj.LocalSpeWare.add(s);
      end
      function speObj = getSpeByPrimeid(obj,id)
         speObj = obj.LocalSpeWare.find('PrimeId',id);
         if isempty(speObj)
            speObj = ReactionLab.SpeciesData.Species(id);
            obj.addLocalSpecies(speObj);
         end
      end
      
      function setCurrentData(obj)
         d = obj.SpeDict;
         dat = [{d(:).fileName}; {d(:).type}; repmat({false},1,length(d))]';
         set(obj.Table,'Data',dat);
         drawnow;
      end
      
      function y = addSpeDict(obj,fileName,dict,type)
      % add new dictionary
         if nargin < 4
            type = ReactionLab.Util.PrIMeData.SpeciesDepot.SpeciesIdentity.getDictType(dict);
         end
         if isempty(type)
            y = false; return
         else
            y = true;
            next = length(obj.SpeDict) + 1;
            obj.SpeDict(next).fileName = fileName;
            obj.SpeDict(next).dict     = dict;
            obj.SpeDict(next).type     = type;
%             obj.SpeDict = [obj.SpeDict ...
%                struct('fileName',fileName,'dict',{dict},'type',type,'match',[])];
         end
      end
      
      function updateSpeDict(obj,fileName,dict,type)
      % add to existing dictionary (fileName), or
      % create new if does not exist
         d = obj.SpeDict;
         ind = find(strcmpi(fileName,{d.fileName}));
         if isempty(ind)
            if addSpeDict(obj,fileName,dict)
               obj.setCurrentData();
            end
         else
            di = d(ind);
            if strcmpi(di.type,type)
               c = vertcat(di.dict,dict);
               [~,m] = unique(upper(c(:,1)));
               obj.SpeDict(ind).dict = c(m,:);
            else
               error(['not matching dictionary types: ' ...
                       di.type ' and ' type]                );
            end
         end
         if strcmp(fileName,'buildupDictionary') ... 
               && ~isempty(dict) && ~isempty(obj.Chemkin.ThermoArray)
            set(obj.Chemkin.BottomPanel.Hnext,'Enable','on');
         end
      end
      
      function d = getDictByType(obj,type)
      % return a merged dictionary of the specified type
         dd = obj.SpeDict;
         indType = find(strcmpi({dd.type},type));
         if isempty(indType)
            d = [];
         else
            d = obj.mergeDict(dd,indType);
         end
      end
      
      function [d,type] = getDictByIndex(obj,ind)
      % return a merged dictionary of the specified indexes
         dd = obj.SpeDict;
         type = unique({dd(ind).type});
         if length(type) ~= 1
            d = [];
         else
            d = obj.mergeDict(dd,ind);
            type = type{:};
         end
      end
      
      function d = getDictByName(obj,name)
         dd = obj.SpeDict;
         ind = strcmp({dd.fileName},name);
         d = dd(ind);
      end
      
      function setSpeciesList2id(obj)
      % get species list to identify
         speciesTxt = obj.Chemkin.SpeciesTxt;
         if isempty(speciesTxt)
            dd = obj.SpeDict;
            if isempty(dd), return, end
            indNonPrime = find(~strcmpi({dd.type},'primeId'));
            d = obj.mergeDict(dd,indNonPrime); %#ok<FNDSB>
            speNameList = d(:,1);
         else
            iSpe  = ReactionLab.Util.findKeyword(speciesTxt,'SPECIES');
            iEnd  = ReactionLab.Util.findKeyword(speciesTxt,'END');
            speTxt = speciesTxt(iSpe+1:iEnd(1)-1);
            speNameList = {};
            for i1 = 1:length(speTxt)
               c = textscan([speTxt{i1}],'%s');
               speNameList = [speNameList; c{:}];
            end
         end
         obj.Spe2id = speNameList;
         obj.Chemkin.Species = cell(length(speNameList),2);
         obj.Chemkin.Species(:,1) = speNameList;
      end
   end
   
   methods (Static)
      function y = getDictType(dict)
      % determine if dictionary's entries are all of same type
      % dict is dictionary of type cell(n,2)
         if     all(ReactionLab.Util.PrIMeData.isprimeid(dict(:,2),'s'))
            y = 'primeId';
         elseif all(ReactionLab.Util.PrIMeData.isinchi(dict(:,2)))
            y = 'inchi';
         else
            errordlg('directory''s entries are not of the same type: primeId or InChI','','modal' );
            y = '';
            return
         end
      end
      
      function d = mergeDict(dd,ind)
      % d = unique( dd(ind) )
         if isempty(ind)
            d = [];
         elseif length(ind) == 1
            d = dd(ind).dict;
         else
            c = vertcat(dd(ind).dict);
            [~,m] = unique(upper(c(:,1)));
            d = c(m,:);
         end
      end
   end
   
end