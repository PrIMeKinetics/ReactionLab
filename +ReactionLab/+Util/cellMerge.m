function y = cellMerge(c1,c2,ind)
% c = cellMerge(c1,c2,ind)
%
% merge the two input cell arrays c1 and c2
%   by the specified column ind;
%   if not given, then by the first column
% c1 and c2 must have the same number of columns
%   and the same object classes in columns

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 20, 2012

narginchk(2,3);

if ~iscell(c1) || ~iscell(c2)
   error('the inputs must be cell arrays');
end

if isempty(c1) && isempty(c2)
   y = {};
   return
elseif isempty(c1)
   y = c2;
   return
elseif isempty(c2)
   y = c1;
   return
end

if size(c1,2) ~= size(c2,2)
   error('the number of columns does not match');
end

if nargin < 3 || isempty(ind)
   ind = 1;
elseif length(ind) > 1
   error('the ind must be a scalar not array');
end

c = vertcat(c1,c2);
[~,m] = unique(upper(c(:,ind)));
y = c(m,:);