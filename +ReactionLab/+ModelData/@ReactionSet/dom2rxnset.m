function rs = dom2rxnset(rs,modelDoc)
% ReactionSetObj = dom2rxnset(ReactionSetObj,modelDoc)
%
% read PrIMe modelXML file and convert it into ReactionSet object

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: November 18, 2010

NET.addAssembly('System.Xml');
import System.Xml.*;

rs.PrimeId = char(modelDoc.getDocumentElement.getAttribute('primeID'));

rs.Title = char(modelDoc.getElementsByTagName('preferredKey').item(0).getTextContent);

biblioNode = modelDoc.getElementsByTagName('bibliographyLink').item(0);
rs.BiblioKey = char(biblioNode.getAttribute('preferredKey'));
rs.BiblioId  = char(biblioNode.getAttribute('primeID'));

% loading species
speSetNode = modelDoc.getElementsByTagName('speciesSet');
speciesNode = speSetNode.item(0).getElementsByTagName('speciesLink');
numSpe = double(speciesNode.getLength);
elList = {};
speListObj = ReactionLab.SpeciesData.SpeciesList();
thList = containers.Map;
Hwait = waitbar(0,'species','Name',['Loading from PrIMe: ' rs.Title]);
for i1 = 1:numSpe
   speciesRecord = speciesNode.item(i1-1);
%    speKey     = char(speciesRecord.getAttribute('preferredKey'));
   spePrimeId = char(speciesRecord.getAttribute('primeID'));
   speObj = ReactionLab.SpeciesData.Species(spePrimeId);
   speListObj = speListObj.add(speObj);
   waitbar(i1/numSpe,Hwait,['species  ' speObj.Key '  (' spePrimeId ')'],...
                            'Name',['Loading from PrIMe: ' rs.Title]       );
   elList = unique([elList {speObj.Elements.symbol}]);
   thPrimeId = char(speciesRecord.getElementsByTagName('thermodynamicDataLink').item(0).getAttribute('primeID'));
   thDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',spePrimeId,thPrimeId});
   thList(spePrimeId) = ReactionLab.ThermoData.Nasa7(thDoc);
%    speObj.Thermo = thObj;
end
close(Hwait);

elListObj = ReactionLab.SpeciesData.ElementList();
for i1 = 1:length(elList)
   elObj = ReactionLab.SpeciesData.Element(elList{i1});
   elListObj = add(elListObj,elObj);
end
rs.Elements =  elListObj;

speObj = speListObj.Values;
for i1 = 1:numSpe
   speObj(i1).Mass = molweight(speObj(i1),rs);
end
rs.Species = speListObj;

rs.setThermo(thList);
          
% get reactions
rxnListObj = ReactionLab.ReactionData.ReactionList();
rxnSetNode = modelDoc.getElementsByTagName('reactionSet');
rxnNode = rxnSetNode.item(0).getElementsByTagName('reactionLink');
numRxn = double(rxnNode.getLength);
Hwait = waitbar(0,'reactions','Name',['Loading from PrIMe: ' rs.Title]);
for i1 = 1:numRxn
   rxnRecord = rxnNode.item(i1-1);
   rxnKey     = char(rxnRecord.getAttribute('preferredKey'));
   rxnPrimeId = char(rxnRecord.getAttribute('primeID'));
   waitbar(i1/numRxn,Hwait,['reaction ' rxnKey '  (' rxnPrimeId ')'],...
                            'Name',['Loading from PrIMe: ' rs.Title]      );
   rxnObj = ReactionLab.ReactionData.Reaction(rxnPrimeId);
   rxnObj.Reversible = str2num(char(rxnRecord.getAttribute('reversible')));
   rateDataLink = rxnRecord.getElementsByTagName('reactionRateLink');
   rk = rxnObj.parseRateLinkNode(rateDataLink);
   if isempty(rk)
      error(['no rate coefficient link for ' rxnPrimeId])
   end
   rxnObj.RateCoef = rk;
   rxnObj.setThermo(rs.Species);
   rxnListObj = rxnListObj.add(rxnObj);
end
close(Hwait);

rs.Reactions = rxnListObj;

additionalData = modelDoc.getElementsByTagName('additionalDataItem');
len = double(additionalData.getLength);
if len > 0
   adata = rs.AdditionalData;
   for i1 = 1:len
      dataItem = additionalData.item(i1-1);
      adata(i1).itemType = char(dataItem.getAttribute('itemType'));
      adata(i1).description = char(dataItem.getAttribute('description'));
      adata(i1).content = char(dataItem.getTextContent);
   end
   rs.AdditionalData = adata;
end