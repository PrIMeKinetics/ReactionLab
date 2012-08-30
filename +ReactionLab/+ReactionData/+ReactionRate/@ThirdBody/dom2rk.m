function rk = dom2rk(rk,rkDoc)
% ThirdBodyObj = dom2rk(ThirdBodyObj,DOMobj)
%   parse collider node of reactionRate DOM

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: April 19, 2010

NET.addAssembly('System.Xml');
import System.Xml.*;

rk = dom2rk@ReactionLab.ReactionData.ReactionRate.MassAction(rk,rkDoc);

body3node = rkDoc.GetElementsByTagName('thirdBody').Item(0);
speLinkNode = body3node.GetElementsByTagName('speciesLink').Item(0);
rk.Collider.key     = char(speLinkNode.GetAttribute('preferredKey'));
rk.Collider.primeId = char(speLinkNode.GetAttribute('primeID'));