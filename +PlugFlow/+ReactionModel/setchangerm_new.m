function h = setchangerm_new(rm,rxnInd)
% handle = setchangerm(rm,rxnInd)
%  multiplies rates of reactions (rxnInd)
%  by respective factors
%
%     factor = a T^n exp(e/T) P^m
%
% in the loop:  rm_i = h(factor)

% Copyright 2010-2016 Michael Frenklach
% Modified: March  5, 2010, myf
% Modified: March 30, 2016, myf: removed try-catch
% Modified: April  5, 2016, myf: fixed multiplier for all arrhenius
% Modified: April 17, 2016, myf: added factor(a,n,e,m)
%                                   for a T^n exp(e/T) P^m

n = length(rxnInd);

jP = rm.order.P + 1;
jjP = [jP 2*jP 3*jP jP-1];
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
   % factor is double(nRxnx4) --- [ln(a) n e m]
      y = rm;
      mex = y.mex;
      for i2 = 1:n
         if indP(i2)   %  P-depnd rxn
            iP = ii{i2};
%             mex.kPres(jP,iP) = mex.kPres(jP,iP) + log(factor(i2));
%             mex.kPres(jP*(1:3),iP) = mex.kPres(jP*(1:3),iP) + factor(i2,1:3)';
%             if factor(i2,4) ~= 0
%                mex.kPres(jP-1,iP) = mex.kPres(jP-1,iP) + factor(i2,4);
%             end
            mex.kPres(jjP,iP) = mex.kPres(jjP,iP) + factor(i2,:)';
         else
            iArr = ii{i2};
%             mex.kArr(1,iArr) = mex.kArr(1,iArr) + factor(i2);
            mex.kArr(1:3,iArr) = mex.kArr(1:3,iArr) + ...
                         repmat(factor(i2,1:3),size(iArr))';
         end
      end
      y.mex = mex;
   end

end