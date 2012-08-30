function arr = mtimes(arr1,arr2)
%arr = MTIMES(arr1,arr2)
%  arr = arr1 * arr2

% Copyright 1999-2008 Michael Frenklach
% $Revision: 1.1 $
% Last modified: May 18, 2008

if isa(arr1,'double')
   arr = arr2;
   arr.A = arr.A * arr1;
elseif isa(arr2,'double')
   arr = arr1;
   arr.A = arr.A * arr2;
else
   arr = arr1;
   arr.A = arr.A * arr2.A;
   arr.n = arr.n + arr2.n;
   e1 = arr.E;
   e2 = arr2.E;
   len1 = length(e1);
   len2 = length(e2);
   if     len1 > len2
      e2(len1-len2+1:len1) = 0;
   elseif len1 < len2
      e1(len2-len1+1:len2) = 0;
   end
   arr.E = e1 + e2;
end