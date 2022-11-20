function spe = dom2spe(speDoc)
% speciesObj = dom2spe(speDocObj)

% Copyright 1999-2010 Michael Frenklach
%      modified: December 15, 2010
% Last modified:   August 15, 2022: line 54 fixed

NET.addAssembly('System.Xml');
import System.Xml.*;

spe = ReactionLab.SpeciesData.Species();

spe.Ids('primeID') = char(speDoc.DocumentElement.GetAttribute('primeID'));
speKeyNode = speDoc.GetElementsByTagName('preferredKey');
if speKeyNode.Count == 1
   spe.Key = char(speDoc.GetElementsByTagName('preferredKey').Item(0).InnerText);
else
   spe.Key = char(getnode(speDoc,'preferredKey','type','prime'));
end

chemicalIdentifier = speDoc.GetElementsByTagName('chemicalIdentifier');
namesNode = chemicalIdentifier.Item(0).GetElementsByTagName('name');
for i1 = 1:double(namesNode.Count)
   nameRecord = namesNode.Item(i1-1);
   name = char(nameRecord.InnerText);
   if nameRecord.HasAttribute('type')
      attr = char(nameRecord.GetAttribute('type'));
      if isempty(attr)
         spe.Names = name;
      elseif strcmpi(attr,'formula')
         spe.Formulas = name;
      else
         spe.Ids(attr) = name;
      end
   else
      spe.Names = name;
   end
end

chemicalComposition = speDoc.GetElementsByTagName('chemicalComposition');
elemNode = chemicalComposition.Item(0).GetElementsByTagName('atom');
numElems = double(elemNode.Count);
if numElems > 0
   for i1 = 1:numElems
      elemRecord = elemNode.Item(i1-1);
      spe.Elements(i1).symbol = char(elemRecord.GetAttribute('symbol'));
      spe.Elements(i1).number = str2double(char(elemRecord.InnerText));
   end
end

additionalData = speDoc.GetElementsByTagName('additionalDataItem');
len = double(additionalData.Count);
if len > 0
   adata = spe.AdditionalData;
   for i1 = 1:len
      dataItem = additionalData.Item(i1-1);
      adata(i1).itemType = char(dataItem.GetAttribute('itemType'));
      adata(i1).description = char(dataItem.GetAttribute('description'));
      adata(i1).content = char(dataItem.InnerText);
   end
   spe.AdditionalData = adata;
end