function dOut = comp2primeid(obj,speNameList,dictComp)
% out = comp2primeid(SpeciesIdentityObj,speNameList,speciesCompositionDictionary|thermoObj)
%    match the speNameList against composition dictionary,
%    or thermoObj array
%
%  comp2primeid(obj,givenSpeList,dictComp)
%  comp2primeid(obj,givenSpeList)
%
%  e.g., compDict = { 'allene', 'c3 h4' 2 }
%                or { 'allene', 'c3 h4'   }
%
%  speNameList = { speciesName  ''  ind  inchi }

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: April 21, 2012


if nargin < 3 || isempty(dictComp)
   dictComp = getDictByType(obj,'comp');
   if isempty(dictComp) % then look for ThermoObjList
      thArray = obj.Chemkin.ThermoArray;
      if isempty(thArray)
         s = ['This operation requires either a species composition dictionary' ...
              ' or a thermodynamic data file to be uploaded'];
         waitfor(msgbox(s,'match species by composition','modal'));
         dOut.completed = false;
         return;
      else
         dictComp = cell(length(thArray),3);
         for i1 = 1:length(thArray)
            th = thArray(i1);
            elems = th.SpeciesElements;
            nElem = length(elems);
            comp = cell(nElem,2);
            for i2 = 1:nElem
               comp(i2,:) = {elems(i2).symbol int2str(elems(i2).number)};
            end
            compSorted = sortrows(comp,1);
            compStr = '';
            for i2 = 1:nElem
               compStr = [compStr compSorted{i2,1} compSorted{i2,2} ' ' ];
            end
            compStr(end) = [];
            dictComp(i1,1:3) = {th.SpeciesKey compStr nElem};
         end
         obj.addSpeDict(obj.Chemkin.ThermoFileName,dictComp,'comp');
         obj.setCurrentData();
      end
   else
      if size(dictComp,2) == 2  % add the number of elements if missing
         for i1 = 1:size(dictComp,1)
            dictComp{i1,3} = sum(isspace(dictComp{i1,2})) + 1;
         end
      end
   end
end

numSpe = size(speNameList,1);
% dNew = cell(numSpe,3);
% dNew(:,1) = speNameList(:,1);

foundList = cell(0,4);
notInDict = cell(0,4);
notInWare = cell(0,4);
Hwait = waitbar(0,'matching composition / initializing ...');
for i1 = 1:numSpe
   speName = speNameList{i1,1};
   ind = find(strcmpi(speName,dictComp(:,1)));
   if isempty(ind)
      notInDict = [notInDict; speNameList(i1,:)];
   elseif length(ind) > 1
      errMessage = {'multiple entries in composition dictionary';...
                    ['for species: ' speName]; ' ';...                      
                    'possible cause: multiple records in thermo file'};
      errordlg(errMessage,'multiple records','modal');
      close(Hwait);
      dOut.completed = false;
      return
   else
%       speNameList{i1,5} = dictComp{ind,2};
      primeId = ReactionLab.Util.PrIMeData.SpeciesDepot.PrIMeSpecies.warehouseSearch(...
         { 'brutoformula',dictComp{ind,2} },{ 'number of elements',dictComp{ind,3} });
      if isempty(primeId)
         notInWare = [notInWare; speNameList(i1,:)];
      else
         foundComp = cell(0,2);
         for i2 = 1:length(primeId)
            speObj = obj.getSpeByPrimeid(primeId{i2});
%             speObj = ReactionLab.SpeciesData.Species(primeId{i2});
            foundComp = [foundComp; {speObj.PrimeId speObj}];
         end
         foundList = [foundList; { speName foundComp } speNameList(i1,3:4) ];
      end
   end
   waitbar(i1/numSpe,Hwait,['matching composition for ' speName]);
end
close(Hwait);
   
dOut.completed = true;
dOut.type      = 'comp';
dOut.found     = foundList;
dOut.notInDict = notInDict;
dOut.notInWare = notInWare;
dOut.speListIn = speNameList;
dOut.dictComp  = dictComp;