function hdf5write(ds,hdf5path)
% hdf5write(DatasetObj,hdf5path)
%
% convert SurrogateModels part of the DatasetObject into HDF5

% Copyright 2009-2014 primekinetics.org
% Created by: Xiaoqing You, UC Berkeley, June 29, 2009
% Modified by: Xiaoqing You, UC Berkeley, Feb. 28, 2010
% Modified: Michael Frenklach, May 6, 2010 - new ReactionLab
% Modified: Michael Frenklach, May 21, 2010 - added variableBounds
% Modified: Michael Frenklach, July 8, 2010 - new collection: Dataset
% Modified:  April 15, 2013, myf: added 'boundsPrimeID' to HDF5 file
% Modified:  April  5, 2014, myf: fixed for when boundsKind is empty and more
% Modified: August 22, 2014, myf: removed 'boundsPrimeID' that was added incorrectly
% Modified: September 16, 2014, myf: added check ds.WithLinks;
%                                    changed paramInitialValue for "absolute'
% Modified: September 18, 2014, myf: added parameterRange

% ReactionSet data
hdf5write(hdf5path,'/title',  ds.Title,...
                   '/primeID',ds.PrimeId,...
                   '/modelLinkId',ds.ModelId,...
                   '/modelLinkTitle',ds.ModelTitle );

% parameters and models
pars = ds.OptimizationVariables;
numPars = length(pars);

paramInitialValues = zeros(1,numPars);
parameterRanges    = zeros(2,numPars);
parameterTrans     =  cell(1,numPars);
parameterRanges    = zeros(2,numPars);
centerSpan = zeros(2,numPars);
parDir = '/surrogateModelData/parameters/';
parLinkDir = [parDir 'parameterLinks/'];
for i1 = 1:numPars
   boundsKind = pars(i1).BoundsKind;
   if ~isempty(boundsKind)
      lb = pars(i1).LowerBound;
      ub = pars(i1).UpperBound;
      if     strcmpi(boundsKind,'absolute')
         span   = 0.5 * (ub - lb);
         center = 0.5 * (ub + lb);
         paramInitialValues(i1) = pars(i1).Value;
         parameterTrans{i1} = pars(i1).Transformation;
         parameterRanges(1:2,i1) = pars.Bounds;
%          paramInitialValues(i1) = -(ub + lb)/(ub - lb);
%          parameterTrans{i1} = 'center+span*x';
      elseif strcmpi(boundsKind,'relative')
         span   = sqrt(ub/lb);
         center = sqrt(ub*lb);
         paramInitialValues(i1) = -log10(center)/log10(span);
         parameterRanges(1:2,i1) = [-1; 1];
         parameterTrans{i1} = 'center*span^x';
      else
         error(['incorrect bound kind: ' boundsKind]);
      end
   else
      parameterTrans{i1} = pars(i1).Transformation;
      if ~isempty(parameterTrans(i1))
         center = pars(i1).Center;
         span   = pars(i1).Span;
         paramInitialValues(i1) = pars(i1).Value;
      else
         error('neither bound kind nor transformation is specified');
      end
   end
   centerSpan(1:2,i1) = [center span];
   hdf5write(hdf5path,[parLinkDir pars(i1).PrimeId],pars(i1).Links,...
                       'WriteMode', 'append'                  );
end
hdf5write(hdf5path,[parDir 'parameterID'],   {pars.PrimeId},  ...
                   [parDir 'parameterKey'],  {pars.Key},      ...
                   [parDir 'parameterRange'], parameterRanges,...
                   [parDir 'optVarUnits'],   {pars.Units},    ...
                   [parDir 'paramInitialValue'],paramInitialValues, ...
                   [parDir 'paramTrans'],     parameterTrans, ...
                   [parDir 'centerSpan'],     centerSpan,     ...
                   'WriteMode', 'append'                              );

% models
sm = ds.SurrogateModels;
hdf5write(hdf5path,'surrogateModelData/modelPrimeID',{sm.PrimeId}, ...
                   'surrogateModelData/modelKey',    {sm.Key}    , ...
                   'WriteMode', 'append'                            );
for i1 = 1:length(sm)
   if ds.WithLinks
      modelParamIds = {sm(i1).OptimizationVariables.varPrimeId};  % variables of i-th model
   else
      modelParamIds = {sm(i1).OptimizationVariables.varId};
   end
   parIdDir = ['surrogateModelData/modelParamIDs/' num2str(i1-1)];
   hdf5write(hdf5path,parIdDir,modelParamIds,'WriteMode','append');
   coefDir = ['surrogateModelData/modelCoefs/' num2str(i1-1)];
   hdf5write(hdf5path,coefDir,sm(i1).coef2quad(),'WriteMode','append');
end

% targets
trgs = ds.Targets;
numTrgs = length(trgs); 
uncRange = zeros(2,numTrgs);
trgDir = '/surrogateModelData/targets/';
trgLinkDir = [trgDir 'targetLinks/'];
for i1 = 1:numTrgs
   uncRange(:,i1) = trgs(i1).Bounds;
   if ds.WithLinks
      hdf5write(hdf5path,[trgLinkDir trgs(i1).PrimeId],trgs(i1).Links,...
                       'WriteMode', 'append'                           );
   end
end

hdf5write(hdf5path,[trgDir 'targetPrimeID'],{trgs.PrimeId}       ,...
                   [trgDir 'targetKey'],    {trgs.Key}           ,...
                   [trgDir 'targetLabel'],  {trgs.Label}         ,...
                   [trgDir 'targetValue'],  [trgs.Value]        ,...
                   [trgDir 'targetUnits'],  {trgs.Units}         ,...
                   [trgDir 'uncRange'],      uncRange            ,...
                   [trgDir 'targetTrans'],  {trgs.Transformation},...
                   'WriteMode', 'append'                           );