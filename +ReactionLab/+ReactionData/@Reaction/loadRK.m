function rk = loadRK(rxn,rkPrimeId)
% RateCoefObj = loadRK(rxnObj,rkPrimeId)
%                                                               
% return specified rate coefficent of reaction rxn

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: May 13, 2010

NET.addAssembly('System.Xml');
import System.Xml.*;

doc = System.Xml.XmlDocument;
rateLinkNode = doc.CreateElement('reactionRateLink');
rateLinkNode.SetAttribute('primeID',rkPrimeId);

rk = parseRateLinkNode(rxn,rateLinkNode);