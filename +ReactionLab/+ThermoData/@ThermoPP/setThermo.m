function th = setThermo(th,T,y,props)
% ThermoPPobj = setThermo(ThermoPPobj,Tarray,values,properties)
%   convert into ThermoPP object

% Copyright 2006-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: August 3, 2010

th.ThermoProp = props;
th.Data = spline(T,y);
th.Trange = findTrange(th);