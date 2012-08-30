function hdf5write(ds,hdf5path)
% hdf5write(DatasetObj,hdf5path)
%
% convert SurrogateModels part of the DatasetObject into HDF5

% Copyright 2009-2010 primekinetics.org
% Created by: Xiaoqing You, UC Berkeley, June 29, 2009
% Modified by: Xiaoqing You, UC Berkeley, Feb. 28, 2010
% Modified: Michael Frenklach, May 6, 2010 - new ReactionLab
% Modified: Michael Frenklach, May 21, 2010 - added variableBounds
% Modified: Michael Frenklach, July 8, 2010 - new collection: Dataset

% ReactionSet data
hdf5write(hdf5path,'/title',  ds.Title,...
                   '/primeID',ds.PrimeId,...
                   '/modelLinkId',ds.ReactionModelId,...
                   '/modelLinkTitle',ds.ReactionModelTitle );

% parameters and models
pars = ds.OptimizationVariables;
numPars = length(pars);

paramInitialValues = zeros(1,numPars);
parameterTrans = cell(1,numPars);
centerSpan = zeros(2,numPars);
parDir = '/surrogateModelData/parameters/';
parLinkDir = [parDir 'parameterLinks/'];
for i1 = 1:numPars
   boundsKind = pars(i1).BoundsKind;
   lb = pars(i1).Bounds(1);
   ub = pars(i1).Bounds(2);
   if     strcmpi(boundsKind,'absolute')
      span   = 0.5 * (ub - lb);
      center = 0.5 * (ub + lb);
      paramInitialValues(i1) = -(ub + lb)/(ub - lb);
      parameterTrans{i1} = 'center+span*x';
   elseif strcmpi(boundsKind,'relative')
      span   = sqrt(ub/lb);
      center = sqrt(ub*lb);
      paramInitialValues(i1) = -log10(center)/log10(span);
      parameterTrans{i1} = 'center*span^x';
   else
      error(['incorrect bound kind: ' boundsKind]);
   end
   centerSpan(1:2,i1) = [center span];
   allLinks = [ pars(i1).Links; pars(i1).BoundsPrimeId ];
   hdf5write(hdf5path,[parLinkDir pars(i1).PrimeId],allLinks,...
                       'WriteMode', 'append'                  );
end
hdf5write(hdf5path,[parDir 'parameterID'],   {pars.PrimeId},  ...
                   [parDir 'parameterKey'],  {pars.Key},      ...
                   [parDir 'parameterRange'],repmat([-1; 1],1,numPars),...
                   [parDir 'optVarUnits'],   {pars.Units},    ...
                   [parDir 'paramInitialValue'],paramInitialValues, ...
                   [parDir 'paramTrans'],     parameterTrans, ...
                   [parDir 'centerSpan'],     centerSpan,     ...
                   'WriteMode', 'append'                           );

% models
sm = ds.SurrogateModels;
hdf5write(hdf5path,'surrogateModelData/modelPrimeID',{sm.PrimeId}, ...
                   'surrogateModelData/modelKey',    {sm.Key}    , ...
                   'WriteMode', 'append'                            );
for i1 = 1:length(sm)
   modelParamIds     = {sm(i1).OptimizationVariables.varPrimeId};  % variables of i-th model
   parIdDir = ['surrogateModelData/modelParamIDs/' num2str(i1-1)];
   hdf5write(hdf5path,parIdDir,modelParamIds,'WriteMode','append');
   coefs = sm(i1).Coef;
   % numCoef = length(coefs);  r = roots([0.5 0.5 -numCoef]);
   % d = r(find(r>0));  modelCoefs = zeros(d)
   % or  d = coefs(end).variables(1) + 1;
   modelCoefs = [];
   for i2 = 1:length(coefs)
      varInds = coefs(i2).variables + 1;
      m = varInds(1);
      n = varInds(2);
      if m == n
         modelCoefs(m,n) = coefs(i2).value;
      else
         modelCoefs(m,n) = 0.5 * coefs(i2).value;
         modelCoefs(n,m) = modelCoefs(m,n);
      end
   end
   coefDir = ['surrogateModelData/modelCoefs/' num2str(i1-1)];
   hdf5write(hdf5path,coefDir,modelCoefs,'WriteMode','append');
end

% targets
trgs = ds.Targets;
numTrgs = length(trgs);
trgValues = [trgs.Value];
boundsKind = {trgs.BoundsKind};  
uncRange = zeros(2,numTrgs);
trgLinkDir = '/surrogateModelData/targets/targetLinks/';
for i1 = 1:numTrgs
   trgBounds = trgs(i1).Bounds;
   if     strcmpi(boundsKind{i1},'absolute')
      uncRange(1:2,i1) = trgBounds + trgValues(i1);
   elseif strcmpi(boundsKind{i1},'relative')
      uncRange(1:2,i1) = trgBounds * trgValues(i1);
   else
      error(['incorrect bound kind: ' boundsKind]);
   end
   hdf5write(hdf5path,[trgLinkDir trgs(i1).PrimeId],trgs(i1).Links,...
                       'WriteMode', 'append'                        );
end
trgDir = '/surrogateModelData/targets/';
hdf5write(hdf5path,[trgDir 'targetPrimeID'],{trgs.PrimeId}       ,...
                   [trgDir 'targetKey'],    {trgs.Key}           ,...
                   [trgDir 'targetLabel'],  {trgs.Label}         ,...
                   [trgDir 'targetValue'],  log10(trgValues)     ,...
                   [trgDir 'targetUnits'],  {trgs.Units}         ,...
                   [trgDir 'uncRange'],     log10(uncRange)      ,...
                   [trgDir 'targetTrans'],  {trgs.Transformation},...
                   'WriteMode', 'append'                           );