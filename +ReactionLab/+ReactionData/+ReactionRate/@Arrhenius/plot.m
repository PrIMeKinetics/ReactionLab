function plot(arr,T)% PLOT(arrheniusObj,T)% plots log10(k) vs 1/T%%   plot(k)   uses default Tmin = 1000 and Tmax = 2500%   plot(k,[Tmin Tmax])%   plot([k1,k2,...kn]) uses default Tmin and Tmax%   plot([k1,k2,...,kn],[Tmin Tmax])% Copyright 1999-2007 Michael Frenklach% $Revision: 1.1 $if nargin > 1   Tmin = T(1);   Tmax = T(2);else   Tmin = 1000;   Tmax = 2500;endx = linspace(1/Tmax, 1/Tmin, 30);Y = [];leg = [];for i1 = 1:length(arr)	%yi = eval(k(i1),1./x);   yi = arr(i1).eval(1./x);	Y = [Y; yi];	leg = [leg; int2str(i1)];endsemilogy(x,Y)	legend(leg)