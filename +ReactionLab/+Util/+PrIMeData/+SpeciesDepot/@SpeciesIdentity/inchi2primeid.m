function dOut = inchi2primeid(obj,dictInchi,dictPrimeId)
% out = inchi2primeid(SpeciesIdentityObj,dictInchi,dictPrimeId)
%    check PrIMe Warehouse to match given inchi's
%    of the inchi dictionary, dictInchi if given,
%    or all inchi dictionaries of dictPrimeId if given,
%    or all primeId disctionaries of obj.SpeDict
%
%  inchi2primeid(obj)               -- uses the dictionaries of obj
%  inchi2primeid(obj,givenInchi)    -- uses primeId dictionaries of obj
%  inchi2primeid(obj,'',givenPrIMe) -- used inchi disctionaries of obj

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: September 19, 2012


if nargin < 2 || isempty(dictInchi)
   dictInchi = getDictByType(obj,'inchi');
   if isempty(dictInchi)
      dOut.completed = false;
      return
   end
end

nTotal = size(dictInchi,1);
dNew = cell(nTotal,4);
dNew(:,1) = dictInchi(:,1);
dNew(:,4) = dictInchi(:,2);

foundList = cell(0,4);

% first check if there is already match with primeIds
if nargin < 3
   dictPrimeId = '';
end
dOut = matchPrimeDict(obj,dictInchi(:,1),dictPrimeId);
if dOut.completed
   notFoundPrime = dOut.notFound;
   if ~isempty(notFoundPrime)
      d = notFoundPrime(:,[1 2]);
      ind2match = [dOut.notFound{:,3}];
      indFound = [dOut.found{:,3}];
      nFound = length(indFound);
      dNew(:,2) = dOut.dNew(:,2);
   else
      nFound = 0;
      d = dictInchi;
      ind2match = 1:size(dictInchi,1);
   end
else
   d = dictInchi;
   ind2match = 1:size(dictInchi,1);
end

notFoundList = cell(0,4);
multiList    = cell(0,4);

nInchi = size(d,1);
Hwait = waitbar(0,'matching InChI / initializing ...');
for i1 = 1:nInchi
   ii = ind2match(i1);
   inchi = dictInchi{ii,2};
   primeId = ReactionLab.Util.PrIMeData.SpeciesDepot.PrIMeSpecies.warehouseSearch({'inchi',inchi});
   if isempty(primeId)
      notFoundList = [notFoundList; {d{i1,1} '' ii inchi}];
   elseif length(primeId) > 1
      foundAmongMulti = cell(0,4);
      for i2 = 1:length(primeId)
         speObj = obj.getSpeByPrimeid(primeId{i2});
%          speObj = ReactionLab.SpeciesData.Species(primeId{i2});
         if strcmpi(speObj.InChI,inchi)
            foundAmongMulti = [foundAmongMulti; {d{i1,1} speObj.PrimeId ii speObj}];
         end
      end
      if isempty(foundAmongMulti)
         notFoundList = [notFoundList; {d{i1,1} '' ii inchi}];
      elseif size(foundAmongMulti,1) == 1
         foundList = [foundList; {foundAmongMulti{1} foundAmongMulti([2 4]) ii inchi}];
         dNew{ii,2} = foundAmongMulti{2};
         dNew{ii,3} = foundAmongMulti{4};
      else
         multiList = [multiList; { d{i1,1} foundAmongMulti(:,[2 4]) ii inchi}];
      end
   else
      speObj = obj.getSpeByPrimeid(primeId{:});
%       speObj = ReactionLab.SpeciesData.Species(primeId{:});
      if strcmpi(speObj.InChI,inchi)
         foundList = [foundList; {d{i1,1} {primeId{1} speObj} ii inchi}];
         dNew{ii,2} = primeId{:};
         dNew{ii,3} = speObj;
      else
         notFoundList = [notFoundList; {d{i1,1} '' ii inchi}];
      end
   end
   waitbar((i1)/nInchi,Hwait,['matching InChI for ' dictInchi{ii,1}]);
%    waitbar((i1+nFound)/nTotal,Hwait,['matching InChI for ' dictInchi{ii,1}]);
end
close(Hwait);

indNext = length(dOut) + 1;

dOut(indNext).completed = true;
dOut(indNext).type      = 'inchi';
dOut(indNext).found     = foundList;
% dOut(indNext).found     = sortrows(foundList,3);
dOut(indNext).notFound  = notFoundList;
dOut(indNext).multiple  = multiList;
dOut(indNext).dIn       = dictInchi;
dOut(indNext).dNew      = dNew;