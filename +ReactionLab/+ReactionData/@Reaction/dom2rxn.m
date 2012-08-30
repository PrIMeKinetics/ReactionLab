function [rxn,speList] = dom2rxn(rxnDoc,isReversible)
% [rxnObj,speList] = dom2rxn(rxnDocObj,isReversible)
%   speList = cellArray, e.g.,
%   { 'O'  's00010285' }
%   { 'O2' 's00010295' }

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: April 18, 2010


NET.addAssembly('System.Xml');
import System.Xml.*;

rxn = ReactionLab.ReactionData.Reaction();
rxn.PrimeId = char(rxnDoc.DocumentElement.GetAttribute('primeID'));

if nargin > 1
   rxn.Reversible = isReversible;
end

spe = rxn.Species;
speNodes = rxnDoc.GetElementsByTagName('speciesLink');
for i1 = 1:double(speNodes.Count)
   reactantNode = speNodes.Item(i1-1);
   spe(i1).key = char(reactantNode.GetAttribute('preferredKey'));
   spe(i1).primeId = char(reactantNode.GetAttribute('primeID'));
   spe(i1).coef = str2double(char(reactantNode.InnerText));
end
rxn.Species = spe;
speList = spe;