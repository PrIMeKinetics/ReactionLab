function flipDirection(r)
% flipDirection(ReactionObj)
% 
%  reverses Direction of reaction

% Copyright 1999-2016 Michael Frenklach
%  Created: January 1, 2016
% Modified: 


d0 = r.Direction;
if     strcmp('forward',d0)
   r.Direction = 'reverse';
elseif strcmp('reverse',d0)
   r.Direction = 'forward';
else
   error(['udefined Direction: ' d0]);
end

spe = r.Species;
for i1 = 1:length(spe)
   spe(i1).coef = spe(i1).coef * -1;
end
r.Species = spe;