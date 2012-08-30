function optvar = dom2optvar(optvarDoc,ovBndDoc)
% OptimizationVariableObj = dom2optvar(optvarDoc,ovBndDoc)

% Copyright 2008-2010 primekinetics.org
% Created by: Xiaoqing You, UC Berkeley, November 19, 2008
% Modified by: Xiaoqing You, UC Berkeley, January 23, 2009
% Modified: Michael Frenklach, April 27, 2010 - new Matlab OOP
% Modified: Michael Frenklach, May 21, 2010 - added variableBounds

optvar = ReactionLab.ModelData.OptimizationVariable();
optvar.PrimeId = strtrim(char(optvarDoc.DocumentElement.GetAttribute('primeID')));
optvar.Type = strtrim(char(optvarDoc.DocumentElement.GetAttribute('type')));

preferredKey = optvarDoc.GetElementsByTagName('preferredKey').Item(0);
key = strtrim(char(preferredKey.InnerText));
if ~isempty(key)
   optvar.Key = key;
else
   error('optimizationVariable XML file does not have preferredKey');
end

variableNode = optvarDoc.GetElementsByTagName('variable').Item(0);
optvar.Transformation = strtrim(char(variableNode.GetAttribute('transformation')));
actVarNode = variableNode.GetElementsByTagName('actualVariable').Item(0);
optvar.Name = strtrim(char(actVarNode.GetAttribute('propertyID')));
propertyLinkNodes = actVarNode.GetElementsByTagName('propertyLink');
numProps = double(propertyLinkNodes.Count);
units = cell(1,numProps);
links = cell(2,numProps);
for i1 = 1:numProps
   [units{i1},links(:,i1)] = parsePropertyNode(propertyLinkNodes.Item(i1-1));
end
if length(unique(units)) > 1
   error('inits do not match')
end
optvar.Units = units{1};
optvar.Links = links;

% bounds, from ovBndDoc
optvar.BoundsPrimeId = strtrim(char(ovBndDoc.DocumentElement.GetAttribute('primeID')));
bndRefNode = ovBndDoc.GetElementsByTagName('bibliographyLink').Item(0);
optvar.BoundsRef = strtrim(char(bndRefNode.GetAttribute('preferredKey')));
optvar.BoundsRefPrimeId = strtrim(char(bndRefNode.GetAttribute('primeID')));

boundsNode = ovBndDoc.GetElementsByTagName('bounds').Item(0);
optvar.BoundsKind = strtrim(char(boundsNode.GetAttribute('kind')));
upperNode = boundsNode.GetElementsByTagName('upper').Item(0);
ubValue = str2double(char(upperNode.InnerText));
lowerNode = boundsNode.GetElementsByTagName('lower').Item(0);
lbValue = str2double(char(lowerNode.InnerText));
optvar.Bounds = [lbValue ubValue];

additionalData = optvarDoc.GetElementsByTagName('additionalDataItem');
len = double(additionalData.Count);
if len > 0
   adata = optvar.AdditionalData;
   for i1 = 1:len
      dataItem = additionalData.Item(i1-1);
      adata(i1).itemType = char(dataItem.GetAttribute('itemType'));
      adata(i1).description = char(dataItem.GetAttribute('description'));
      adata(i1).content = char(dataItem.InnerText);
   end
   optvar.AdditionalData = adata;
end
optvar.Description = adata(1).description;


   function [units,ids] = parsePropertyNode(propertyLinkNode)
   % parge single propertyLink node
      propertyId = strtrim(char(propertyLinkNode.GetAttribute('id')));
      switch propertyId
      case {'a' 'lambda'}
         primeId1 = strtrim(char(propertyLinkNode.GetAttribute('reactionPrimeID')));
         primeId2 = strtrim(char(propertyLinkNode.GetAttribute('reactionRatePrimeID')));
%          rkDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeID',primeId1,primeId2});
         units = 'cm3,mol,s';
      case 'hf298'
         primeId1 = strtrim(char(propertyLinkNode.GetAttribute('speciesPrimeID')));
         primeId2 = strtrim(char(propertyLinkNode.GetAttribute('thermodynamicDataPrimeID')));
         thDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeID',primeId1,primeId2}); 
         dHnode = thDoc.GetElementsByTagName('dfH').Item(0);
%          optvar.Value = str2double(char(dHnode.InnerText));
         units = char(dHnode.GetAttribute('units'));
      otherwise
         error(['undefined property Id: ' propertyId '  ' optvar.PrimeId]);
      end
      ids = {primeId1; primeId2};
   end

end