function dc = dataset2dc(ds)
% DClabObj = dataset2dc(DatasetObj)
%
% convert DatasetObject into DClab object

% Copyright 2009-2014 primekinetics.org
%       Created: April 12, 2013, myf
%      Modified:   May 25, 2014, myf
% Last modified:  July  2, 2014, myf, added checking length(prm)


prm = ds.OptimizationVariables;
sm  = ds.SurrogateModels;
trg = ds.Targets;

len1 = length(sm);
modelCoeffs   = cell(len1,1);
modelParamIDs = cell(len1,1);
if ds.WithLinks
   for i1 = 1:len1
      modelCoeffs{i1}   =  sm(i1).Coef;
      modelParamIDs{i1} = {sm(i1).OptimizationVariables.varPrimeId}';
   end
   allOptmVars = [sm.OptimizationVariables];
   prmIdNew = unique({allOptmVars.varPrimeId});
   if length(prmIdNew) < length(prm)
      [~,indFound] = setdiff({prm.PrimeId},prmIdNew);
      prm(indFound) = [];  % do not include in dc unused parameters
   end
else
   for i1 = 1:len1
      modelCoeffs{i1}   =  sm(i1).Coef;
      modelParamIDs{i1} = {sm(i1).OptimizationVariables.varId}';
   end
end

dc = DClab.DCContainer();

dc.title = ds.Title;

dc.modelKey      = {sm.Key}';
dc.modelCoeffs   = modelCoeffs;
dc.modelParamIDs = modelParamIDs;

dc.parameterKey      = {prm.Key}';
dc.parameterID       = {prm.PrimeId}';
dc.parameterRange    = num2cell([[prm.LowerBound]' [prm.UpperBound]'],2);
dc.paramInitialValue = num2cell([prm.Value]');

dc.targetKey   = {trg.Key}';
dc.targetLabel = {trg.Label}';
dc.targetUnits = {trg.Units}';
dc.targetValue = num2cell([trg.Value]');
dc.uncRange    = num2cell([[trg.LowerBound]' [trg.UpperBound]'],2);

if ds.WithLinks
   dsId = ds.PrimeId;
   dc.datasetID    = dsId;
   dc.trialModelID = ds.ModelId;
   dc.callback2show  = @(id) ReactionLab.Util.gate2primeData('show',{'primeID',id});
   dc.callback2show2 = @(id1,id2) ReactionLab.Util.gate2primeData('show',{'primeID',id1,id2});
   
   dc.modelID = {sm.PrimeId}';
   
   dc.targetID    = {trg.PrimeId}';
   dc.targetTrans = {trg.Transformation}';

   dc.paramTrans = {prm.Transformation}';
   dc.centerSpan = num2cell([[prm.Center]' [prm.Span]'],2);
   dc.optVarUnits = {prm.Units}';
   
   len2 = length(trg);
   targetLinks = cell(len2,1);
   for i2 = 1:len2
      targetLinks{i2,1} = trg(i2).Links;
   end
   dc.targetLinks = targetLinks;
   
   len3 = length(prm);
   paramLinks = cell(len3,1);
   for i3 = 1:len3
      paramLinks{i3,1} = prm(i3).Links;
   end
   dc.parameterLinks = paramLinks;
end