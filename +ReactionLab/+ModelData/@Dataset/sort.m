function sort(ds,prop)
% sort(DatasetObj,prop)
%     sort ds by prop = 'key|primeid'

% Copyright 2009-2014 primekinetics.org
%       Created:  June 24, 2014, myf
% Last modified:  June 25, 2014, myf

if     strcmpi(prop,'key')
   Prop = 'Key';
elseif strcmpi(prop,'primeid')
   Prop = 'PrimeId';
else
   error(['undefined request: ' prop]);
end

sm  = ds.SurrogateModels;
trg = ds.Targets;

[~,indSorted] = sort({trg.(Prop)});

ds.SurrogateModels = sm(indSorted);
ds.Targets         = trg(indSorted);