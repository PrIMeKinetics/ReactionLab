function dom2biblio(biblioObj)
% dom2biblio(PrIMeBiblioObj)
% 
% parse PrIMe thermo doc, getting the contents of the into
% a container, stored as a property of the PrIMeBiblioObj

% Copyright 1999-2011 Michael Frenklach
% $ Revision: 1.1 $
% Last modified: January 6, 2011


doc = biblioObj.Doc;
biblioObj.PrimeId = char(doc.DocumentElement.GetAttribute('primeID'));

nodes = doc.DocumentElement.ChildNodes;
data = cell(nodes.Count,2);
for i1 = 1:nodes.Count
   node = nodes.Item(i1-1);
   data{i1,1} = char(node.Name);
   data{i1,2} = char(node.InnerText);
end

biblioObj.Data = data;