function dOut = matchPrimeDict(obj,speNameList,d)
% out = matchPrimeDict(SpeciesIdentityObj,speNameList,dictPrimeId)
%    match the speNameList against primeId dictionary, 
%    either dictPrimeId if given,
%    or all primeId dictionaries of obj.SpeDict

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: March 18, 2012

if nargin < 3 || isempty(d)
   d = getDictByType(obj,'primeId');
end
if isempty(d)
   dOut.completed = false;
   return
end

dNew = cell(length(speNameList),2);
dNew(:,1) = speNameList;
foundList    = cell(0,2);
notFoundList = cell(0,3);

[y,ind] = ismember(upper(speNameList),upper(d(:,1)));
if any(y)
   dNew(y==1,2) = d(ind(y==1),2);
   indF = find(y==1);   % indexes of identified species
   foundList = [speNameList(indF) d(ind(y==1),2) num2cell(indF)];
%    foundList = [speNameList(indF) cell(length(indF),1) num2cell(indF)];
end
if any(~y)
   indNf = find(y==0);  % indexes of species not identified by primeId
   notFoundList = [speNameList(indNf) cell(length(indNf),1) num2cell(indNf)];
end

dOut.completed = true;
dOut.type      = 'primeId';
dOut.found     = foundList;
dOut.notFound  = notFoundList;
dOut.multiple  = {};
dOut.dIn       = d;
dOut.dNew      = dNew;