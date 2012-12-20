function cleanDoc = rxnset2dom(rs)
% rxnsetDocObj = rxn2dom(ReactionSetObj)

% Copyright 1999-2013 Michael Frenklach
% Last modified: December 12, 2012

NET.addAssembly('System.Xml');
import System.Xml.*

rsDoc = System.Xml.XmlDocument;
rsDoc.Load(which('+ReactionLab\+Util\+PrIMeData\+ReactionDepot\m00000000_template.xml'));

% primeID node
if ~isempty(rs.PrimeId)
   rsDoc.DocumentElement.SetAttribute('primeID',rs.PrimeId);
end

% copyright node
a = clock;
year = a(1);
copyrightNode = rsDoc.GetElementsByTagName('copyright').Item(0);
copyrightNode.InnerText = ['primekinetics.org 2005-' num2str(year)];

% preferredKey node
preferredKeyNode = rsDoc.GetElementsByTagName('preferredKey').Item(0);
preferredKeyNode.InnerText = rs.Title;

% bibliography
bibliographyElement = rsDoc.GetElementsByTagName('bibliographyLink').Item(0);
bibliographyElement.SetAttribute('preferredKey',rs.BiblioKey);
bibliographyElement.SetAttribute('primeID',     rs.BiblioId );

% species list
speObjArray = rs.Species.Values;
numSpe = length(speObjArray);
speciesSetNode = rsDoc.GetElementsByTagName('speciesSet').Item(0);
speciesElement = speciesSetNode.GetElementsByTagName('speciesLink').Item(0);
for i1 = 2:numSpe
   newSpeciesElement = speciesElement.Clone();
   speciesSetNode.AppendChild(newSpeciesElement);
end
speNodes = speciesSetNode.ChildNodes;
for i1 = 1:numSpe
   speObj  = speObjArray(i1);
   speNode = speNodes.Item(i1-1);
   speNode.SetAttribute('preferredKey',speObj.Key);
   speNode.SetAttribute('primeID',     speObj.PrimeId);
   thNode = speNode.GetElementsByTagName('thermodynamicDataLink').Item(0);
   thNode.SetAttribute('preferredKey',strtrim(speObj.Thermo.Comment));
   thNode.SetAttribute('primeID',     speObj.Thermo.Id);
end

% reaction list
rxnObjArray = rs.Reactions.Values;
numRxn = length(rxnObjArray);
rxnSetNode = rsDoc.GetElementsByTagName('reactionSet').Item(0);
rxnElement = rxnSetNode.GetElementsByTagName('reactionLink').Item(0);
for i1 = 2:numRxn
   newRxnElement = rxnElement.Clone();
   rxnSetNode.AppendChild(newRxnElement);
end
rxnNodes = rxnSetNode.ChildNodes;
for i1 = 1:numRxn
   rxnObj  = rxnObjArray(i1);
   rxnNode = rxnNodes.Item(i1-1);
   rxnNode.SetAttribute('preferredKey',rxnObj.Eq);
   rxnNode.SetAttribute('primeID',     rxnObj.PrimeId);
   if ~rxnObj.Reversible
      rxnNode.SetAttribute('reversible','false');
   end
   rkNode = rxnNode.GetElementsByTagName('reactionRateLink').Item(0);
   rkNode.SetAttribute('preferredKey',rxnObj.RateCoef.Eq);
   rkNode.SetAttribute('primeID',     rxnObj.RateCoef.PrimeId);
end

% removing junk
docStr = char(rsDoc.OuterXml);
cleanStr = strrep(docStr,' xmlns=""','');
cleanDoc = System.Xml.XmlDocument;
cleanDoc.LoadXml(cleanStr);