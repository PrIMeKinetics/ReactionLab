function optvar = h5read(modelPath,wLinks)
% OptimizationVariableObj = h5read(hdf5FilePath,withLinks)
%   static method of OptimizationVariable class
%
% withLinks = true | false

% Copyright 2008-2013 primekinetics.org
%       Created: April 12, 2013, myf
%      Modified: April 15, 2013, myf
% Last modified: April 28, 2013, myf: switch to h5read

obj = PWAinterface(modelPath);

parKeys   = obj.h5read('/parameterKey');
parInitVal= obj.h5read('/paramInitialValue');
parRange  = obj.h5read('/parameterRange');
n = length(targetKeys);
optvar = ReactionLab.ModelData.OptimizationVariable.empty(0,n);
for i1 = 1:n
   optvar(i1).Key     = parKeys{i1};
   optvar(i1).Value   = parInitVal(i1);
   optvar(i1).Bounds  = parRange(i1,:);
end

if wLinks
   primeIDs  = obj.h5read('/parameterID');
   parTrans  = obj.h5read('/paramTrans');
   parUnits  = obj.h5read('/optVarUnits');
   parCenterAndSpan = obj.h5read('/centerSpan');
   parBndId  = obj.h5read('/boundsPrimeID');
   for i2 = 1:n
      optvar(i1).PrimeId = primeIDs{i1};
      optvar(i1).Transformation = parTrans{i1};
      optvar(i1).Units   = parUnits{i1};
      optvar(i1).Links   = obj.h5read(['/parameterLinks/' primeIDs{i1}]);
      optvar(i1).Center  = parCenterAndSpan(i1,1);
      optvar(i1).Span    = parCenterAndSpan(i1,2);
      optvar(i1).BoundsPrimeId = parBndId{i1};
   end
end