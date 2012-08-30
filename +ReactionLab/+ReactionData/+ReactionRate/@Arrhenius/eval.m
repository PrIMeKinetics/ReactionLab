function y = eval(arr,T)
%y = eval(ArrheniusObject,Temperature)
%  evaluates arrhenius expression arr
%     at temperature array T

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: March 30, 2010

y = repmat(arr.A,size(T));

if arr.n ~= 0
   y = y .* T.^arr.n;
end

if arr.E ~= 0
   y = y.*exp(-arr.E./T);
%    y = y .* exp(-polyval([arr.E(end:-1:1) 0],1./T));
end