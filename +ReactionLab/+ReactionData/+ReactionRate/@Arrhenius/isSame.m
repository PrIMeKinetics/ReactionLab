function y = isSame(rk,prm)
% true/false = isSame(ArrheniusObj,parameterArray)
%
% check if rk's parameter match those in prm array

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: May 13, 2010

d = abs(([rk.A rk.n rk.E] - prm)./prm);

if all(d < 0.001)
   y = 1;
else
   y = 0;
end


% if rk.A == prm(1)  && ...
%    rk.n == prm(2)  && ...
%    rk.E == prm(3)
%    y = 1;
% else
%    y = 0;
% end