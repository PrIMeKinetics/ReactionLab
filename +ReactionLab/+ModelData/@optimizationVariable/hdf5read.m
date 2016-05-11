function optvar = hdf5read(modelPath,wLinks)
% OptimizationVariableObj = hdf5read(hdf5FilePath,withLinks)
%   static method of OptimizationVariable class
%
% withLinks = true | false

% Copyright 2008-2014 primekinetics.org
%  Created:   April 12, 2013, myf
% Modified:   April 15, 2013, myf
% Modified:   March 29, 2014, myf
% Modified:  August 22, 2014, myf: rem boundPrimeId
% Modified: October 10, 2014, myf: moved IDs into i1 loop
% Modified:     May  6, 2015, myf: fixed ids in line 36

parKeys   = get('/parameterKey');
parInitVal= get('/paramInitialValue');
parRange  = get('/parameterRange')';
ids  = get('/parameterID');
parTrans  = get('/paramTrans');
parUnits  = get('/optVarUnits');
n = length(parKeys);
optvar = ReactionLab.ModelData.OptimizationVariable.empty(0,n);
for i1 = 1:n
   optvar(i1).Key     = parKeys{i1};
   optvar(i1).Value   = parInitVal(i1);
   optvar(i1).Bounds  = parRange(i1,:);
   optvar(i1).PrimeId = ids{i1};
   optvar(i1).Transformation = parTrans{i1};
   optvar(i1).Units   = parUnits{i1};
end

if wLinks
   parCenterAndSpan = get('/centerSpan')';
%   parBndId  = get('/boundsPrimeID');
   for i2 = 1:n
      optvar(i2).Links   = get(['/parameterLinks/' ids{i2}]);
      optvar(i2).Center  = parCenterAndSpan(i2,1);
      optvar(i2).Span    = parCenterAndSpan(i2,2);
%      optvar(i2).BoundsPrimeId = parBndId{i2};
   end
end


   function y = get(field)
      st = hdf5read(modelPath,['/surrogateModelData/parameters' field]);
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