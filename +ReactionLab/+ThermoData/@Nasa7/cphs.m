function y = cphs(th,T)
% y = cphs(Nasa7Obj,T)
% y = [cp; h; s] in K
%   this function computed without checking,
%   use eval otherwise

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: June 11, 2011

p = th.Data;
len = length(p);
y = zeros(3,length(T));
ind = 5:-1:1;
for i1 = 1:len
   if i1 == len           % is last interval
      indT = find(T>=p(i1).Trange(1) & T<=p(i1).Trange(2));
   else
      indT = find(T>=p(i1).Trange(1) & T< p(i1).Trange(2));
   end
   Tarray = T(indT);
   y(1,indT) = polyval(p(i1).coef(5:-1:1),Tarray);           % cp
   pH = p(i1).coef(ind)./ind;
   y(2,indT) = (Tarray.*polyval(pH,Tarray)+p(i1).coef(6));   % h
   pS = p(i1).coef(ind)./[4 3 2 1 1];
   y(3,indT) = (polyval(pS,Tarray) + p(i1).coef(7)...
                + ( log(Tarray)-1 ) * p(i1).coef(1) );       % s
end