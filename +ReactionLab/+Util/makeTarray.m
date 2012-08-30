function y = makeTarray(Trange,deltaT)
% arrayOfT = makeTarray(Trange,deltaT)

% Copyright 1999-2008 Michael Frenklach
% $Revision: 1.0 $
% Last modified: December 7, 2008

if nargin < 2
   deltaT = 100;   % default value
end

T1 =  ceil(Trange(1) / deltaT) * deltaT;
T2 = floor(Trange(2) / deltaT) * deltaT;
y = union(T1:deltaT:T2,Trange);