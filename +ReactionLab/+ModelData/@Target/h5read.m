function trg = h5read(modelPath,wLinks)
% trgObj = h5read(hdf5filePath,withLinks)
%   a static method of Target class
%
% withLinks = true | false

% Copyright 2008-2013 primekinetics.org
%       Created: April 12, 2013, myf
%      Modified: April 15, 2013, myf
% Last modified: April 28, 2013, myf: switch to h5read

obj = PWAinterface(modelPath);

trgKeys   = obj.h5read('/targetKey');
trgLabels = obj.h5read('/targetLabel');
trgUnits  = obj.h5read('/targetUnits');
trgVal    = obj.h5read('/targetValue');
trgUnc    = obj.h5read('/uncRange')';
n = length(targetKeys);
trg = ReactionLab.ModelData.Target.empty(0,n);
for i1 = 1:n
   trg(i1).Key     = trgKeys{i1};
   trg(i1).Label   = trgLabels{i1};
   trg(i1).Units   = trgUnits{i1};
   trg(i1).Value   = trgVal(i1);
   trg(i1).Bounds  = trgUnc(i1,:);
end

if wLinks
   primeIDs  = obj.h5read('/targetPrimeID');
   trgTrans  = obj.h5read('/targetTrans');
   for i2 = 1:n
      trg(i1).PrimeId = primeIDs{i1};
      trg(i1).Transformation = trgTrans{i1};
      trg(i1).Links   = obj.h5read(['/targetLinks/' primeIDs{i1}]);
   end
end