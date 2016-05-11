function rk = loadRK(rxn,rkPrimeId)
% RateCoefObj = loadRK(rxnObj,rkPrimeId)
%                                                               
% return specified rate coefficent of reaction rxn

% Copyright 1999-2016 Michael Frenklach
% Modified: May 13, 2010
% Modified: Dec 22, 2015, myf: minor fix

NET.addAssembly('System.Xml');
import System.Xml.*;

doc = System.Xml.XmlDocument;
rateLinkNode = doc.CreateElement('reactionRateLink');
rateLinkNode.SetAttribute('primeID',rkPrimeId);

rk = rxn.parseRateLinkNode(rateLinkNode);