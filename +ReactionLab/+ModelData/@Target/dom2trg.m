function trg = dom2trg(trgDoc)
% trgObj = dom2trg(TargetDoc)

% Copyright 2008-2013 primekinetics.org
%       Created: Xiaoqing You, UC Berkeley, November 19, 2008
%      Modified: Xiaoqing You, UC Berkeley, January 23, 2009
%       odified: Michael Frenklach, April 27, 2010 - new Matlab OOP
% Last Modified: Michael Frenklach, April 15, 2013 - new syntax for Bounds
% Last Modified: Matt Speight, July 23, 2013 - lines 66-71
trg = ReactionLab.ModelData.Target();
trg.PrimeId = char(trgDoc.DocumentElement.GetAttribute('primeID'));
trg.Type = char(trgDoc.DocumentElement.GetAttribute('type'));

preferredKey = trgDoc.GetElementsByTagName('preferredKey').Item(0);
key = strtrim(char(preferredKey.InnerText));
if ~isempty(key)
   trg.Key = key;
else
   error('dataAttribute XML file does not have preferredKey');
end

links = {};
linksNode = trgDoc.GetElementsByTagName('propertyLink');
for k = 0:double(linksNode.Count)-1
    linkID = strtrim(char(linksNode.Item(k).GetAttribute('experimentPrimeID')));
    if ~ismember(linkID, links)
        links = [links linkID];
    end
end
trg.Links = links;

trgValueNode = trgDoc.GetElementsByTagName('dataAttributeValue').Item(0);
type = strtrim(char(trgValueNode.GetAttribute('type')));
observableNode = trgValueNode.GetElementsByTagName('observable').Item(0);
propertyNode = observableNode.GetElementsByTagName('property').Item(0);
trg.Units = strtrim(char(propertyNode.GetAttribute('units')));
trg.Label = strtrim(char(propertyNode.GetAttribute('label')));
% trg.Transformation = strtrim(char(observableNode.GetAttribute('transformation')));
if strcmpi(type,'derived')
    valueNode = observableNode.GetElementsByTagName('value').Item(0);
    trgValue = str2double(char(valueNode.InnerText));
elseif strcmpi(type,'actual')
    valueNode = observableNode.GetElementsByTagName('valueLink').Item(0);    
    xPrimeID = strtrim(char(valueNode.GetAttribute('experimentPrimeID')));
    dataGroupID = strtrim(char(valueNode.GetAttribute('dataGroupID')));
    dataPointID = strtrim(char(valueNode.GetAttribute('dataPointID')));
    propertyID = strtrim(char(valueNode.GetAttribute('propertyID')));
    xDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeID',xPrimeID});                       
    dataGroupNodes = xDoc.GetElementsByTagName('dataGroup');
    for k = 0:double(dataGroupNodes.Count-1)
        dgId = char(dataGroupNodes.Item(k).GetAttribute('id'));
        if strcmp(dataGroupID,dgId)
            dataPointNodes = dataGroupNodes.Item(k).GetElementsByTagName('dataPoint');
            for m = 0:double(dataPointNodes.Count-1)
                dpId = char(dataPointNodes.Item(m).GetAttribute('id'));
                if strcmp(dataPointID,dpId)
                   propertyNode = dataPointNodes.Item(m).GetElementsByTagName(propertyID); 
                   trgValue = str2double(char(propertyNode.Item(0).InnerText));
                end
            end
        end
    end    
else
    error(['wrong value type: ' type]);
end
% edited by wms 
if strcmp(trg.Label,'t_ign')
   trg.Units = [char(181) 's'];
   trgValue=ReactionLab.Units.units2units(trgValue,strtrim(char(propertyNode.GetAttribute('units'))),'microsec');
end
% end edit
trg.Value = trgValue;

boundsNode = observableNode.GetElementsByTagName('bounds').Item(0);
trg.BoundsKind = strtrim(char(boundsNode.GetAttribute('kind')));
upperNode = boundsNode.GetElementsByTagName('upper').Item(0);
trg.UpperBound = str2double(char(upperNode.InnerText));
lowerNode = boundsNode.GetElementsByTagName('lower').Item(0);
trg.LowerBound = str2double(char(lowerNode.InnerText));

additionalData = trgDoc.GetElementsByTagName('additionalDataItem');
len = double(additionalData.Count);
if len > 0
   adata = trg.AdditionalData;
   for i1 = 1:len
      dataItem = additionalData.Item(i1-1);
      adata(i1).itemType = char(dataItem.GetAttribute('itemType'));
      adata(i1).description = char(dataItem.GetAttribute('description'));
      adata(i1).content = char(dataItem.InnerText);
   end
   trg.AdditionalData = adata;
end
trg.Description = adata(1).description;