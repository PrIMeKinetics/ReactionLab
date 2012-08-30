function [y,t,prop] = eval(tp,T,prop)
%[data,T,propOut] = eval(ThermoPPobj,T,propIn)
% prop = {property units};  eg:  {'Cp' 'cal'; 'H' 'kcal'}

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: December 15, 2010

Tmin = tp.Tmin;
Tmax = tp.Tmax;
indT = find(T>=Tmin & T<=Tmax);
ind0 = setdiff(1:length(T),indT);
if ~isempty(ind0)
   range = [num2str(Tmin) ' - ' num2str(Tmax)];
   Hdlg = warndlg({'Temperature '; num2str(T(ind0)); ...
                   [' is outside the range of validity: ' range]},...
                   'thermopp:eval','modal');
   waitfor(Hdlg)
end

t = T(indT);
if isempty(t), y = []; return; end

if nargin > 2
   yy = ppval(tp.Data,t);
   for i1 = 1:size(prop,1)
      indY(i1) = find(strcmpi(prop(i1,1),tp.ThermoProp(:,1)));
      [R(i1,1),prop{i1,2}] = ReactionLab.PhysConst.univR(prop{i1,2});
      if ~any(strcmpi(prop(i1,1),{'Cp' 'S'}))
         prop{i1,2} = strtok(prop{i1,2},'_');
      end
   end
   y = yy(indY,:) .* repmat(R,1,size(yy,2));
else
   y = ppval(tp.Data,t);
   prop = tp.ThermoProp;
end