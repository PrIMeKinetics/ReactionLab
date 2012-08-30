function [y,t,prop] = eval(th,T,prop)
%[y,Tactual,prop] = eval(Nasa7Obj,T,prop)
% prop = {property units};  eg:  {'Cp' 'cal'; 'H' 'kcal'}
% 
% y = [cp; h; s]
% Heat capacity, enthalpy, and entropy of NASA7 polynomials

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: June 11, 2011

p = th.Data;
len = length(p);
t = zeros(1,length(T)); y = zeros(3,length(T));
ind = 5:-1:1;
for i1 = 1:len
   if i1 == len           % is last interval
      indT = find(T>=p(i1).Trange(1) & T<=p(i1).Trange(2));
   else
      indT = find(T>=p(i1).Trange(1) & T< p(i1).Trange(2));
   end
   if ~isempty(indT)
      Tarray = T(indT);
      y(1,indT) = polyval(p(i1).coef(5:-1:1),Tarray);           % cp
      pH = p(i1).coef(ind)./ind;
      y(2,indT) = (Tarray.*polyval(pH,Tarray)+p(i1).coef(6));   % h
      pS = p(i1).coef(ind)./[4 3 2 1 1];
      y(3,indT) = (polyval(pS,Tarray) + p(i1).coef(7)...
                   + ( log(Tarray)-1 ) * p(i1).coef(1) );       % s
      t(indT) = Tarray;
   end
end

ind0 = find(t==0);
if ~isempty(ind0)
   range = num2str(th.Trange);
   Hdlg = warndlg(['Temperature ' num2str(T(ind0)) ...
                   ' is outside the range of validity: ' range],...
                   'ReactionLab.ThermoData.Nasa7:eval','modal');
   waitfor(Hdlg);
   t(ind0)   = [];
   y(:,ind0) = [];
end

if nargin > 2
   if isempty(y), return; end
   nP = size(prop,1);
   indY = zeros(1,nP);
   R = zeros(nP,1);
   for i1 = 1:size(prop,1)
      indY(i1) = find(strcmpi(prop(i1,1),{'Cp' 'H' 'S'}));
      [R(i1,1),prop{i1,2}] = ReactionLab.PhysConst.univR(prop{i1,2});
      if any(strcmpi(prop(i1,1),{'H'}))
         prop{i1,2} = strtok(prop{i1,2},'_');
      end
   end
   y = y(indY,:) .* repmat(R,1,size(y,2));
else
   prop = {'Cp' 'K/K'; 'H' 'K'; 'S' 'K/K'};
   if isempty(y), return; end
end