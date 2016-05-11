function y = isDirectionMatch(r)
% y = isDirectionMatch(ReactionObj)
% 
%  checkes if Direction of reaction and 
%     those of its RateCoef's all match, i.e.,
%   y = 1  if all 'forward' or all 'reverse'
%   y = 0  otherwise

% Copyright 1999-2016 Michael Frenklach
%  Created: December 31, 2015
% Modified: 

rD = r.Direction;
rk0 = r.RateCoef;
y = 1;
checkDirection(rk0);


   function checkDirection(rk)
      rkClass = rk.getClass;
      switch rkClass
         case {'MassAction' 'ThirdBody'}
            y = strcmp(rD,rk.Direction);
            if ~y, return, end
         case 'Sum'
            rks = rk.Values;
            for i2 = 1:length(rks)
               checkDirection(rks{i2});
            end
         case {'Unimolecular' 'ChemicalActivation'}
            checkDirection(rk.Low)
            checkDirection(rk.High)
         otherwise
            error(['undefined rk class ' rkClass]);
      end
      
   end

end