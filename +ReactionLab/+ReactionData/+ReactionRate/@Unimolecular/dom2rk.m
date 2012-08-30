function rk = dom2rk(rk,rkDoc)
% UnimolecularObj = dom2rk(UnimolecularObj,DOMobj)
%   parse Unimolecular reactionRate DOM

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: May 6, 2010

NET.addAssembly('System.Xml');
import System.Xml.*;

rk.PrimeId = char(rkDoc.DocumentElement.GetAttribute('primeID'));
rxnLinkNode = rkDoc.GetElementsByTagName('reactionLink').Item(0);
rk.RxnPrimeId = char(rxnLinkNode.GetAttribute('primeID'));
rxn = ReactionLab.ReactionData.Reaction(rk.RxnPrimeId);
% rk.RxnEq      = char(rxnLinkNode.GetAttribute('preferredKey'));
% eqNode = rkDoc.GetElementsByTagName('preferredKey').Item(0);
pDepnNode = rkDoc.GetElementsByTagName('pressureDependence').Item(0);
rk.Falloff = ReactionLab.ReactionData.ReactionRate.Falloff(pDepnNode);

rxnRateLinkNodes = rxnLinkNode.GetElementsByTagName('reactionRateLink');
for i1 = 1:double(rxnRateLinkNodes.Count)
   linkNode = rxnRateLinkNodes.Item(i1-1);
   primeId = char(linkNode.GetAttribute('primeID'));
   pressureLimit = char(linkNode.GetAttribute('pressureLimit'));
   if strcmpi(pressureLimit,'high')
      rk.High = rxn.parseRateLinkNode(linkNode);
      rxnLinkNode.RemoveChild(linkNode);  % only low-P links left
      rk.Low = rxn.parseRateLinkNode(rxnRateLinkNodes);
      
%       highPnode = linkNode;
%       rk.High = ReactionLab.ReactionData.ReactionRate.MassAction(rk.RxnPrimeId,primeId);
      return
   end 
end

% rxnLinkNode.RemoveChild(highPnode);  % only low-P links left
% rk.Low = rxn.parseRateLinkNode(rxnRateLinkNodes);