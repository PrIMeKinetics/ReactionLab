function cleanDoc = spe2dom(spe)
% speDocObj = spe2dom(SpeciesObj)

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: March 31, 2012

NET.addAssembly('System.Xml');
import System.Xml.*;

speDoc = XmlDocument;
speDoc.Load(which('+ReactionLab\+Util\+PrIMeData\+SpeciesDepot\s00000000_template.xml'));

% primeID node
if ~isempty(spe.PrimeId)
   speDoc.DocumentElement.SetAttribute('primeID',spe.PrimeId);
end

% copyright node
a = clock;
year = a(1);
copyrightNode = speDoc.GetElementsByTagName('copyright').Item(0);
copyrightNode.InnerText = ['primekinetics.org 2005-' num2str(year)];

% preferredKey node
preferredKeyNode = speDoc.GetElementsByTagName('preferredKey').Item(0);
preferredKeyNode.InnerText = spe.Key;

% chemicalIdentifier node
names2add = cell(0,2);    %  {attr  name}
if ~isempty(spe.Names)
   for i1 = 1:length(spe.Names)
      names2add = [names2add; {'' spe.Names{i1}}];
   end
end
if ~isempty(spe.Formulas)
   for i1 = 1:length(spe.Formulas)
      names2add = [names2add; {'formula' spe.Formulas{i1}}];
   end
end
keys = spe.Ids.keys;
for i1 = 1:length(keys)
   key = keys{i1};
   if strcmpi(key,'primeID')
   else
      names2add = [names2add; {key spe.Ids(key)}];
   end
end
chemicalIdentifier = speDoc.GetElementsByTagName('chemicalIdentifier');
for i1 = 1:size(names2add,1)
   nameElement = speDoc.CreateElement('name');
   if ~isempty(names2add{i1,1})
      nameElement.SetAttribute('type',names2add{i1,1});
   end
   nameElement.AppendChild(speDoc.CreateTextNode(names2add{i1,2}));
   chemicalIdentifier.Item(0).AppendChild(nameElement);
end

% chemicalComposition node
chemicalComposition = speDoc.GetElementsByTagName('chemicalComposition');
elem = spe.Elements;
for i1 = 1:length(elem)
   el = elem(i1);
   compElement = speDoc.CreateElement('atom');
   compElement.SetAttribute('symbol',upper(el.symbol));
   compElement.AppendChild(speDoc.CreateTextNode(int2str(el.number)));
   chemicalComposition.Item(0).AppendChild(compElement);
end

% removing junk
docStr = char(speDoc.OuterXml);
cleanStr = strrep(docStr,' xmlns=""','');
cleanDoc = XmlDocument;
cleanDoc.LoadXml(cleanStr);