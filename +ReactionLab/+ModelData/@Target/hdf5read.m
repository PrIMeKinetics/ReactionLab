function trg = hdf5read(modelPath,wLinks)
% trgObj = hdf5read(hdf5filePath,withLinks)
%   a static method of Target class
%
% withLinks = true | false

% Copyright 2008-2014 primekinetics.org
%       Created: April 12, 2013, myf
%      Modified: April 15, 2013, myf
% Last modified: March 29, 2014, myf

trgKeys   = get('/targetKey');
trgLabels = get('/targetLabel');
trgUnits  = get('/targetUnits');
trgVal    = get('/targetValue');
trgUnc    = get('/uncRange')';
n = length(trgKeys);
trg = ReactionLab.ModelData.Target.empty(0,n);
for i1 = 1:n
   trg(i1).Key     = trgKeys{i1};
   trg(i1).Label   = trgLabels{i1};
   trg(i1).Units   = trgUnits{i1};
   trg(i1).Value   = trgVal(i1);
   trg(i1).Bounds  = trgUnc(i1,:);
end

if wLinks
   primeIDs  = get('/targetPrimeID');
   trgTrans  = get('/targetTrans');
   for i2 = 1:n
      trg(i2).PrimeId = primeIDs{i2};
      trg(i2).Transformation = trgTrans{i2};
      trg(i2).Links   = get(['/targetLinks/' primeIDs{i2}]);
   end
end


   function y = get(field)
      st = hdf5read(modelPath,['/surrogateModelData/targets' field]);
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