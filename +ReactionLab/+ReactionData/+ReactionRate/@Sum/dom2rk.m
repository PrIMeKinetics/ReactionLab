function rk = dom2rk(rk,rkDoc)
% SumObj = dom2rk(SumObj,DOMobj)
%   parse Sum node(s) of reactionRate DOM(s)

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: April 19, 2010

NET.addAssembly('System.Xml');
import System.Xml.*;

rxnRateLinkNode = rkDoc.GetElementsByTagName('reactionRateLink');
% link to actual files
rk.PrimeId = char(rkDoc.DocumentElement.GetAttribute('primeID'));
rxnLinkNode = rkDoc.GetElementsByTagName('reactionLink').Item(0);
rk.RxnPrimeId = char(rxnLinkNode.GetAttribute('primeID'));
for i1 = 1:double(rxnRateLinkNode.Count)
   rkPrimeId = char(rxnRateLinkNode.Item(i1-1).GetAttribute('primeID'));
   rkDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',rk.RxnPrimeId,rkPrimeId});
   h = getHandle(rkDoc);
   rk.add(feval(h,rkDoc));
end


   function h = getHandle(doc)
   % determine the RK type and return a handle to
   %    the corresponding class constructor
      rkType = char(doc.DocumentElement.GetAttribute('rateLawType'));
      switch lower(rkType)
         case 'mass action'
            h = @ReactionLab.ReactionData.ReactionRate.MassAction;
         case 'third body'
            h = @ReactionLab.ReactionData.ReactionRate.ThirdBody;
         otherwise
            error(['SUM is not yet defined for: ' rkType]);
      end
   end


end