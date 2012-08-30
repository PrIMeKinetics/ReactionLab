function arr = mrdivide(arr1,arr2)
%ARR = MRDIVIDE(arr1,arr2)
%  ARR = ARR1 / ARR2

% Copyright 1999-2008 Michael Frenklach
% $Revision: 1.1 $
% Last modified: May 18, 2008

if isa(arr1,'double')
   arr = arr2;
   arr.A = arr1 / arr.A;
   arr.n = -arr.n;
   arr.E = -arr.E;
elseif isa(arr2,'double')
   arr = arr1;
   arr.A = arr.A / arr2;
else
   arr = arr1;
   arr.A = arr.A / arr2.A;
   arr.n = arr.n - arr2.n;
   arr.E = arr.E - arr2.E;
end