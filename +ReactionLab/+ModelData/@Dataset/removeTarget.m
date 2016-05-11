function removeTarget(ds,trgId,tokeep)
% removeTarget(DatasetObj,targetPrimeId)
%       remove trgId target(s) from ds
%              trgId is a cell array of target PrimeIds
% removeTarget(DatasetObj,targetPrimeId,true)
%       keep trgId target(s) in ds, remove the rest
% removeTarget(DatasetObj,targetPrimeId,false)
%       remove trgId target from ds, keep the rest

% Copyright 2009-2014 primekinetics.org
%       Created: April  6, 2014, myf
%      Modified:   May 28, 2014, myf
%      Modified:  June 24, 2014, myf
% Last modified:  July  2, 2014, myf


prm = ds.OptimizationVariables;
sm  = ds.SurrogateModels;
trg = ds.Targets;

len1 = length(sm);
modelCoeffs   = cell(len1,1);
modelParamIDs = cell(len1,1);
if ds.WithLinks
   for i1 = 1:len1
      modelCoeffs{i1}   =  sm(i1).Coef;
      modelParamIDs{i1} = {sm(i1).OptimizationVariables.varPrimeId};
   end
else
   for i1 = 1:len1
      modelCoeffs{i1}   =  sm(i1).Coef;
      modelParamIDs{i1} = {sm(i1).OptimizationVariables.varId};
   end
end

oldTrgIds = {trg.PrimeId};
if ischar(trgId)
   trgId = {trgId};
end

% check for duplicate targets
if length(trgId) ~= length(unique(trgId))
   error('there are duplicate targets');
end

% check if there are targets in trgId that are not in oldTrgIds
[idFound,indFound] = setdiff(trgId,oldTrgIds);
if ~isempty(idFound)
   disp(['targets: ' idFound ' is not found']);
   trgId(indFound) = [];   % remove the one that is not found
end
% get targets in oldTrgIds that are not in trgId
[idFound,indFound] = setdiff(oldTrgIds,trgId);
if isempty(idFound)
   error('you ask to remove all the targets');
end

if     nargin == 3 && tokeep    % keep given, remove the rest
%   trgInd2keep = setdiff(1:len1,indFound);
   trgInd2rem  = indFound;
elseif nargin == 3 && ~tokeep   % remove given, keep the rest
%   trgInd2keep = indFound;
   trgInd2rem  = setdiff(1:len1,indFound);
else
   error('incorrect number of input arguments');
end

% removing the targets
 sm(trgInd2rem) = [];
trg(trgInd2rem) = [];
ds.SurrogateModels = sm;
ds.Targets         = trg;

% get the common set of parameters
allOptmVars = [sm.OptimizationVariables];
prmIdNew = unique({allOptmVars.varPrimeId});
if length(prmIdNew) ~= length(prm)
%    keyboard
%    error('deal with this now')
   warndlg(['number changed to ' int2str(length(prmIdNew))],...
            'opt variables','modal')
end