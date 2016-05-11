function sm = h5read(modelPath,wLinks)
% SurrogateModelObj = h5read(hdf5filePath,withLinks)
%   a static method of SurrogateModel class
%
% withLinks = true | false

% Copyright 2008-2013 primekinetics.org
%       Created: April 12, 2013, myf
%      Modified: April 15, 2013, myf
% Last modified: April 28, 2013, myf: switch to h5read

obj = PWAinterface(modelPath);

modelKeys = obj.h5read('/modelKey');
n = length(modelKeys);
sm = ReactionLab.ModelData.SurrogateModel.empty(0,n);
optVarStruct = sm.OptimizationVariables;
for i1 = 1:n
   i1m = i1 - 1;
   sm(i1).Key     = modelKeys{i1};
   sm(i1).Coef    = obj.h5read(['/modelCoefs/' int2str(i1m)]);
   sm(i1).Weight = 1;
   sm(i1).OptimizationVariables = setOptimizationVariables();
end

if wLinks
   primeIDs  = obj.h5read('/modelPrimeID');
   for i2 = 1:n
      sm(i1).PrimeId = primeIDs{i1};
   end
end


   function y = setOptimizationVariables()
      y = optVarStruct;
      optVars = obj.h5read(['/modelParamIDs' int2str(i1m)]);
      if length(optVars{1}) == 9  % variable primeId
         for i3 = 1:length(optVars)
            y(i3).varPrimeId = optVars{i3};
         end
      else
         for i3 = 1:length(optVars)
            y(i3).varId = optVars{i3};
         end
      end
   end

end