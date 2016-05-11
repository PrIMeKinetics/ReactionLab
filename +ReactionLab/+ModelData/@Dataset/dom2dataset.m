function ds = dom2dataset(ds,dsDoc)
% DatasetObj = dom2dataset(DatasetObj,datasetDoc)
%
% read PrIMe modelXML file and convert it into Dataset object

% Copyright 1999-2013 Michael Frenklach
%      modified:  July 28, 2010, myf
% Last modified: April 15, 2013, myf

NET.addAssembly('System.Xml');
import System.Xml.*;

% ReactionSet links
modelNode = dsDoc.GetElementsByTagName('modelLink').Item(0);
key = char(modelNode.GetAttribute('preferredKey'));
ds.ModelTitle = key;
ds.ModelId = char(modelNode.GetAttribute('primeID'));

% dataset primeId
ds.PrimeId = char(dsDoc.DocumentElement.GetAttribute('primeID'));
ds.Title = char(dsDoc.GetElementsByTagName('preferredKey').Item(0).InnerText);
biblioNode = dsDoc.GetElementsByTagName('bibliographyLink').Item(0);
ds.BiblioKey = char(biblioNode.GetAttribute('preferredKey'));
ds.BiblioId  = char(biblioNode.GetAttribute('primeID'));

% surrogate models and targets
smSetNode = dsDoc.GetElementsByTagName('surrogateModelSet');
smNode = smSetNode.Item(0).GetElementsByTagName('surrogateModelLink');
numSm = double(smNode.Count);
optVars = {};     % { optvarPrimeId oprvarBoundsPrimeId; }
Hwait = waitbar(0,'surrogate models and targets','Name',['Loading from PrIMe: ' key]);
for i1 = 1:numSm
   smRecord = smNode.Item(i1-1);
   smKey     = strtrim(char(smRecord.GetAttribute('preferredKey')));
   smPrimeId = strtrim(char(smRecord.GetAttribute('primeID')));
   waitbar(i1/numSm,Hwait,['surrogate model ' smKey '  (' smPrimeId ')'],...
                            'Name',['Loading from PrIMe: ' key]      );
   sm(i1) = ReactionLab.ModelData.SurrogateModel(ds.PrimeId,smPrimeId);
   addOptVar(sm(i1).OptimizationVariables);
   modelTarget = sm(i1).Target;
   trgObj(i1) = ReactionLab.ModelData.Target(modelTarget.primeId);
   trgObj(i1).Transformation = modelTarget.transformation;
end
ds.Targets = trgObj;
ds.SurrogateModels = sm;

% optimization variables
optVars_sorted = sortrows(optVars,1);
numVars = size(optVars_sorted,1);
waitbar(0,Hwait,'optimization variables','Name',['Loading from PrIMe: ' key]);
for i1 = 1:numVars
   varPrimeId = optVars{i1,1};
   waitbar(i1/numVars,Hwait,['optimization variable '  optVars_sorted{i1,1}], ...
                             'Name',['Loading from PrIMe: ' key]     );
   ovObj(i1) = ReactionLab.ModelData.OptimizationVariable(optVars_sorted{i1,1:2});
end
ds.OptimizationVariables = ovObj;

close(Hwait);


   function addOptVar(ov)
   % check if var is already in the list and with the same bounds
      if isempty(optVars)
         optVars = [ {ov.varPrimeId} ; {ov.bndPrimeId} ]';
         return
      end
      [tf,ind] = ismember({ov.varPrimeId},optVars(:,1));
      for i2 = 1:length(tf)
         if tf(i2)   % already exist, check if bound primeIds are the same
            iv = ind(i2);
            if ~strcmpi(ov(i2).bndPrimeId,optVars{iv,2})
               error(['boundsPrimeIds do not match for ' ov(i2).varPrimeId]);
            end
         else
            optVars(end+1,1:2) = { ov(i2).varPrimeId  ov(i2).bndPrimeId };
         end
      end
   end


end