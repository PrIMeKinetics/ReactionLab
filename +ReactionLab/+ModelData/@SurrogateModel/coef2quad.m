function q = coef2quad(smObj)
% q = coef2quad(SurrogateModelObj)
%  converts coefficients of 2nd-order polynomial
%     [b0  b1  b2  b3  ...
%          b11 b12 b13 ...
%              b22 b23 ...  ]
%  to quadratic form 
%   1/2 * [ 2*b0   b1    b2 ...
%             b1 2*b11   b12 ...
%             b2   b21 2*b22 ... ]

%       Created: 2001, myf as part of quadpoly class
% Last modified: June 28, 2005 
% Last modified: July 22, 2014, myf
% Last modified: Sept 30, 2015, myf: adopted from ResponseSurface class

cc = smObj.Coef;
   v = reshape([cc.variables],2,length(cc))';
coef = [cc.value]';

if isempty(coef)
   q = [];
   return
end

n = length(coef);
m = length(v);
if m == 1
   if n ~= (v+1)*(v+2)/2
      error('length of coef does not match #var')
   end
   [j,i] = find(tril(ones(1+v)));
   for k = 1:length(i)
      a(i(k),j(k)) = coef(k);
   end
   au = triu(a);
   q = (au' + au);
else
   if n ~= m
      error('length of coef does not match #var')
   end
   for k = 1:m
      i = v(k,1)+1;  j = v(k,2)+1;
      if i == j
         q(i,i) = 2 * coef(k);
      else
         q(i,j) = coef(k);
         q(j,i) = q(i,j);
      end
   end
end
 q = q/2;