function th = removeProp(th,prop)
% ThermoPPobj = removeProp(ThermoPPobj,property2remove)

% Copyright 2006-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: June 1, 2011


props = th.ThermoProp;
ind = strcmpi(prop,props(:,1));

if isempty(ind)
   error(['there is property ' prop])
end
if length(ind) > 1
   error(['there are two many properties ' prop])
end


y = th.Data;

y(ind,:) = [];
ThermoProp(ind,:) = [];

th.Data = y;
th.ThermoProp = ThermoProp;