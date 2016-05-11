function reportDataset(ds)
% reportDataset(DatasetObj)
%      save as an Excel table

% Copyright 2009-2014 primekinetics.org
%       Created:   May 25, 2014, myf
% Last modified:  July  2, 2014, myf, added 2 more columns

trg = ds.Targets;

val = [trg.Value]';
lb  = [trg.LowerBound]';
ub  = [trg.UpperBound]';
key = {trg.Key}';

nTrg = length(trg);

data = cell(nTrg,8);
for i1 = 1:nTrg
   data{i1,1} = key{i1};
   data{i1,2} = 10.^lb(i1);
   data{i1,3} = 10.^val(i1);
   data{i1,4} = 10.^ub(i1);
   data{i1,5} = log10(data{i1,2}/data{i1,3});  % log10(lb/val)
   data{i1,6} = log10(data{i1,4}/data{i1,3});  % log10(ub/val)
   data{i1,7} = data{i1,2}/data{i1,3};  % lb/val
   data{i1,8} = data{i1,4}/data{i1,3};  % ub/val
end

data = [{'target' 'Lower' 'Value' 'Upper' ... 
         'log10(LB/val)' 'log10(UB/val)' 'LB/val' 'UB/val'}; data]; 
xlswrite(ds.Title,data);