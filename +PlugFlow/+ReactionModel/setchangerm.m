function h = setchangerm(rm,rxnInd)
% handle = setchangerm(rm,rxnInd)
%  multiplies rates of reaction (rxnInd)
%  by respective multipliers, factor
%
%   in the loop:  rm_i = h(factor)

% Copyright 2010-2016 Michael Frenklach
% Modified: March  5, 2010, myf&
% Modified: March 30, 2016, myf: removed try-catch
% Modified: April  5, 2016, myf: fixed multiplier for all arrhenius

n = length(rxnInd);

jP = rm.order.P + 1;
mex = rm.mex;
indArr = mex.indArr';   %  [0|1|2  colInd  rxnInd ]

indP = zeros(1,n);  % 0 - non P-depnd rxns;  1 - P-depnd rxns
ii = cell(1,n);  % iArr - non P-depnd rxns; iP - P-depnd rxns
for i1 = 1:n
   iRxn = rxnInd(i1);
   iArr = find(indArr(:,3) == iRxn);
   if indArr(iArr(1),1) == 2   %  P-depnd rxn
    indP(i1) = 1;
      ii{i1} = mex.indRxn(2,iRxn);
   else
      ii{i1} = iArr;
   end
end

h = @changerm;


   function y = changerm(factor)
      y = rm;
      mex = y.mex;
      for i2 = 1:n
         if indP(i2)   %  P-depnd rxn
            iP = ii{i2}; 
            mex.kPres(jP,iP) = mex.kPres(jP,iP) + log(factor(i2));
         else
            iArr = ii{i2};
            mex.kArr(1,iArr) = mex.kArr(1,iArr) + log(factor(i2));
         end
      end
      y.mex = mex;
   end

end