function sm = hdf5read(modelPath,wLinks)
% SurrogateModelObj = hdf5read(hdf5filePath,withLinks)
%   a static method of SurrogateModel class
%
% withLinks = true | false

% Copyright 2008-2014 primekinetics.org
%       Created: April 12, 2013, myf
%      Modified: April 15, 2013, myf
% Last modified: March 29, 2014, myf


modelKeys = get('/modelKey');
n = length(modelKeys);
sm = ReactionLab.ModelData.SurrogateModel.empty(0,n);
sm1 = ReactionLab.ModelData.SurrogateModel;
optVarStruct = sm1.OptimizationVariables;
for i1 = 1:n
   i1m = i1 - 1;
   sm(i1).Key     = modelKeys{i1};
   sm(i1).Coef    = get(['/modelCoefs/' int2str(i1m)]);
   sm(i1).Weight = 1;
   sm(i1).OptimizationVariables = setOptimizationVariables();
end

if wLinks
   primeIDs  = get('/modelPrimeID');
   for i2 = 1:n
      sm(i2).PrimeId = primeIDs{i2};
   end
end


   function y = setOptimizationVariables()
      y = optVarStruct;
      optVars = get(['/modelParamIDs/' int2str(i1m)]);
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

   function y = get(field)
      st = hdf5read(modelPath,['/surrogateModelData' field]);
      %       if isa(st,'double')
      if isnumeric(st)
         y = st;
      else
         len = length(st);
         y = cell(1,len);
         for i5 = 1:len
            y{i5} = st(i5).Data;
         end
      end
   end

end