function y = mix(tp,coef,comment)
%y = mix(ThermoPPobjArray, coefficients, description)
% creates a ThermoPP object from a mixture of ThermoPP objects
%         y = sum{ thermo(i) * coef(i) }

% Copyright 1999-2008 Michael Frenklach
% $Revision: 1.0 $
% Last modified: December 7, 2008

n = length(tp);
if length(coef) ~= n
   error(['lengths do not match: ' int2str([length(coef) n]) ])
end

% y = thermo7;
% y.file = get(th,'file',1);
% y.formula = 'combined polynomials';

if nargin > 2, y.Comment = comment; end

minT = max(tp.Tmin);
maxT = min(tp.Tmax);
y = ReactionLab.ThermoData.ThermoPP;




polyLow  = 0;
polyHigh = 0;
for i = 1:n
   minT(i)  = th(i).coef(1).Tmin;
   midT(i)  = th(i).coef(1).Tmax;
   maxT(i)  = th(i).coef(2).Tmax;
   polyLow  = polyLow  + th(i).coef(1).poly .* coef(i);
   polyHigh = polyHigh + th(i).coef(2).poly .* coef(i);
end

uniqMidT = unique(midT);
len = length(uniqMidT);
if len == 1
   y.coef(1).Tmin = max(minT);
   y.coef(1).Tmax = midT(1);
   y.coef(2).Tmin = midT(1);
   y.coef(2).Tmax = min(maxT);
   y.coef(1).poly = polyLow;
   y.coef(2).poly = polyHigh;
else
   y = th;
   for i = 1:n
      yi = y(i);
      set(yi,'stoichCoef',coef(i));
      y(i) = yi;
   end
end