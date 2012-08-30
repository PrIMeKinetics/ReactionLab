function rk = dom2rk(rk,rkDoc)
% MassActionObj = dom2rk(MassActionObj,DOMobj)
%   parse reactionRate DOM object

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: May 12, 2010

NET.addAssembly('System.Xml');
import System.Xml.*;

rkNode = rkDoc.GetElementsByTagName('rateCoefficient').Item(0);
rk.PrimeId = char(rkDoc.DocumentElement.GetAttribute('primeID'));
rxnLinkNode = rkDoc.GetElementsByTagName('reactionLink').Item(0);
rk.RxnPrimeId = char(rxnLinkNode.GetAttribute('primeID'));
% rk.RxnEq      = char(rxnLinkNode.GetAttribute('preferredKey'));
% eqNode = rkDoc.GetElementsByTagName('preferredKey').Item(0);
rk.Direction = char(rkNode.GetAttribute('direction'));

exprNode = rkNode.GetElementsByTagName('expression');

numExpr = double(exprNode.Count);
if numExpr > 1
   error('multiple expressions are not defined yet')
end

for i1 = 1:double(exprNode.Count)
   exNode = exprNode.Item(i1-1);
   rkForm = char(exNode.GetAttribute('form'));
   switch lower(rkForm)
      case 'arrhenius'
         rk = rk.dom2arr(exNode,rk.Order);
      case 'constant'
         
         error('constant type is not supported yet')
      otherwise
         error(['undefined reaction rate form: ' rkForm]);
   end
end