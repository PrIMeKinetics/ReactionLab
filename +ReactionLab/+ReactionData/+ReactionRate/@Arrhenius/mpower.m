function y = mpower(arr,pow)
%arrObg = MPOWER(arrObj,power)
%  arrObj = arrObj ^ power

% Copyright 1999-2008 Michael Frenklach
% $Revision: 1.1 $
% Last modified: May 18, 2008

y = arr;
y.A = arr.A ^ pow;
y.n = arr.n * pow;
y.E = arr.E * pow;