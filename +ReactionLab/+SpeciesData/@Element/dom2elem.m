function el = dom2elem(elDoc)
% elementObj = dom2elem(docObj)

% Copyright 2003-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 27, 2010

NET.addAssembly('System.Xml');
import System.Xml.*;

el = ReactionLab.SpeciesData.Element();

elDocRoot = elDoc.DocumentElement;

el.Id = char(elDocRoot.GetAttribute('primeID'));

el.Name = char(elDocRoot.GetElementsByTagName('elementName').Item(0).InnerText);

el.Symbol = char(elDocRoot.GetElementsByTagName('elementSymbol').Item(0).InnerText);

atomicMassNode = elDocRoot.GetElementsByTagName('relativeAtomicMass').Item(0);
el.Mass = str2double(char(atomicMassNode.GetElementsByTagName('numericalValue').Item(0).InnerText));

refElNode = elDocRoot.GetElementsByTagName('referenceElement').Item(0);
el.RefElemSymbol = char(refElNode.GetAttribute('preferredKey'));
el.RefElemId = char(refElNode.GetAttribute('primeID'));