function [y,h1] = calcTargets(D,xVals,iPlot)
% [y,Hfig] = calcTargets(DatasetObj,xVals,iPlot)
%     xVals = numTargets x numRunsD

% Modified: May 6, 2015, myf: add if D.WithLinks; added iPlot

trg = D.Targets;
numY = length(trg);
numX = size(xVals,2);
if D.WithLinks
   allVarList = {D.OptimizationVariables.PrimeId};
else
   allVarList = {D.OptimizationVariables.Key};
end
y = zeros(numX,numY);
for i1 = 1:numY
   sm = D.SurrogateModels(i1);
   if D.WithLinks
      trgVarList = {sm.OptimizationVariables.varPrimeId};
   else
      trgVarList = {sm.OptimizationVariables.varId};
   end
   nvar = length(trgVarList);
   vars = zeros(nvar,numX);
   for i2 = 1:nvar
      indX = find(strcmpi(trgVarList{i2},allVarList));
      if isempty(indX)
         error(['did not find X ' trgVarList{i2}])
      end
      vars(i2,:) = xVals(indX,:);
   end
   q = sm.Coef;
   for i3 = 1:numX
      x = [1; vars(:,i3)];
      y(i3,i1) = x' * q * x;
   end
end

if nargin > 2 && iPlot
   figure; h1 = gplotmatrix(y);
else
   h1 = [];
end