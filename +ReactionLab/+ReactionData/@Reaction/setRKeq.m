function setRKeq(rxns)
% setRKeq(rxnObj)
%
%   add rxn eqs for those in third body, etc.

% Copyright 1999-2016 Michael Frenklach
%  Created: December 30, 2015
% Modified:  January 21, 2016
% Modified: February 24, 2016, myf

% rxns = rxn.Values;  % get the current rxn set
for i1 = 1:length(rxns)
   r = rxns(i1);
   eq = r.Eq;
   s1 = strsplit(eq);
   c1 = strfind(s1,'=');
   ind = find(~cellfun(@isempty,c1));
   sInit = s1(1:ind-1);
   sEnd  = s1(ind:end);
   rki = r.RateCoef;
   r.RateCoef = setEq(rki);
end
   
   
   function rk = setEq(rkIn)
      rk = rkIn;
      rkClass = rk.getClass;
      switch rkClass
         case 'MassAction'
            rk.Eq = eq;
         case 'Sum'
            rks = rk.Values;
            numRK = length(rks);
            rkClasses    = cell(1,numRK);
            rkDirections = cell(1,numRK);
            for i2 = 1:numRK
               kNew = setEq(rks{i2});
               rk = rk.replace('PrimeId',kNew.PrimeId,kNew);
               rkClasses{i2}    = kNew.getClass;
               rkDirections{i2} = kNew.Direction;
            end
            if all(strcmp('MassAction',rkClasses))
               rk.Eq = eq;
            else
               rk.Eq = localInsert('''M''');
            end
            rk.Direction = setDirection(unique(rkDirections));
         case 'ThirdBody'
            rk.Eq = localInsert(rk.Collider.key);
         case 'Unimolecular'
            rk.Eq = localInsert('(M)');
            rk.Low  = setEq(rk.Low);
            rk.High = setEq(rk.High);
            rk.Direction = setDirection(unique({rk.Low.Direction rk.High.Direction}));
         case 'ChemicalActivation'
            rk.Eq = localInsert('(M)');
            rk.Low  = setEq(rk.Low);
            rk.High = setEq(rk.High);
            rk.Direction = setDirection(unique({rk.Low.Direction rk.High.Direction}));
         otherwise
            error(['undefined rk class ' rkClass]);
      end
      
      
      function y = localInsert(colKey)
         sNew = [sInit {'+'} {colKey} sEnd {'+'} {colKey}];
         y = strjoin(sNew);
      end
      
      function y = setDirection(uniRKdirct)
         if length(uniRKdirct) == 1
            y = uniRKdirct{1};
         else
            y = 'mixed';
         end
      end
      
   end

end