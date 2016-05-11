function rs = dom2rxnset(rs,modelDoc)
% ReactionSetObj = dom2rxnset(ReactionSetObj,modelDoc)
%
% read PrIMe modelXML file and convert it into ReactionSet object

% Copyright 1999-2015 Michael Frenklach
% Modified: November 18, 2010
% Modified:     June  7, 2015, myf: added transportData to SpeciesObj
% Modified:     June 17, 2015, myf: added explicit call to WarehouseLink obj
% Modified: February 24, 2016, myf: added check and call for flipDirection

NET.addAssembly('System.Xml');
import System.Xml.*;

wLink = ReactionLab.Util.PrIMeData.WarehouseLink;
conn = wLink.conn;

rs.PrimeId = char(modelDoc.DocumentElement.GetAttribute('primeID'));

rs.Title = char(modelDoc.GetElementsByTagName('preferredKey').Item(0).InnerText);

biblioNode = modelDoc.GetElementsByTagName('bibliographyLink').Item(0);
rs.BiblioKey = char(biblioNode.GetAttribute('preferredKey'));
rs.BiblioId  = char(biblioNode.GetAttribute('primeID'));

% loading species
speSetNode = modelDoc.GetElementsByTagName('speciesSet');
speciesNode = speSetNode.Item(0).GetElementsByTagName('speciesLink');
numSpe = double(speciesNode.Count);
elList = {};
speListObj = ReactionLab.SpeciesData.SpeciesList();
thList = containers.Map;
Hwait = waitbar(0,'species','Name',['Loading from PrIMe: ' rs.Title]);
for i1 = 1:numSpe
   speciesRecord = speciesNode.Item(i1-1);
%    speKey     = char(speciesRecord.GetAttribute('preferredKey'));
   spePrimeId = char(speciesRecord.GetAttribute('primeID'));
   speObj = ReactionLab.SpeciesData.Species(spePrimeId);
   trNode = speciesRecord.GetElementsByTagName('transportDataLink').Item(0);
   % get the transport data
   if isempty(trNode)
      % do nothing for now; eventually, load the tr00000000 file and get the pointer
   else
      trPrimeId = char(trNode.GetAttribute('primeID'));
      filePath = ['depository/species/data/' spePrimeId '/' trPrimeId '.xml'];
      trDoc = conn.Load(filePath).result;
%       key = char(trDoc.GetElementsByTagName('preferredKey').Item(0).InnerText);
      par = trDoc.GetElementsByTagName('parameter');
      nPar = par.Count;
      v = zeros(1,nPar);
      for i2 = 1:nPar
         attr = char(par.Item(i2-1).GetAttribute('name'));
         switch attr
            case 'geometry'
               ind = 1;
            case 'potentialWellDepth'
               ind = 2;
            case 'collisionDiameter'
               ind = 3;
            case 'dipoleMoment'
               ind = 4;
            case 'polarizability'
               ind = 5;
            case 'rotationalRelaxation'
               ind = 6;
            otherwise
               error(['undefined attribute name ' attr]);
         end
         v(ind) = str2double(char(par.Item(i2-1).GetElementsByTagName('value').Item(0).InnerText));
      end
      speObj.AdditionalData(1).itemType = 'transportData';
      speObj.AdditionalData(1).description = trPrimeId;
      speObj.AdditionalData(1).content = v;
   end
   speListObj = speListObj.add(speObj);
   waitbar(i1/numSpe,Hwait,['species  ' speObj.Key '  (' spePrimeId ')'],...
                            'Name',['Loading from PrIMe: ' rs.Title]       );
   elList = unique([elList {speObj.Elements.symbol}]);
   thPrimeId = char(speciesRecord.GetElementsByTagName('thermodynamicDataLink').Item(0).GetAttribute('primeID'));
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
rxnSetNode = modelDoc.GetElementsByTagName('reactionSet');
rxnNode = rxnSetNode.Item(0).GetElementsByTagName('reactionLink');
numRxn = double(rxnNode.Count);
Hwait = waitbar(0,'reactions','Name',['Loading from PrIMe: ' rs.Title]);
for i1 = 1:numRxn
   rxnRecord = rxnNode.Item(i1-1);
   rxnKey     = char(rxnRecord.GetAttribute('preferredKey'));
   rxnPrimeId = char(rxnRecord.GetAttribute('primeID'));
   waitbar(i1/numRxn,Hwait,['reaction ' rxnKey '  (' rxnPrimeId ')'],...
                            'Name',['Loading from PrIMe: ' rs.Title]      );
   rxnObj = ReactionLab.ReactionData.Reaction(rxnPrimeId);
   rxnObj.Reversible = str2num(char(rxnRecord.GetAttribute('reversible')));
   rateDataLink = rxnRecord.GetElementsByTagName('reactionRateLink');
   rk = rxnObj.parseRateLinkNode(rateDataLink);
   if isempty(rk)
      error(['no rate coefficient link for ' rxnPrimeId])
   end
   rxnObj.RateCoef = rk;
   if ~isDirectionMatch(rxnObj)
      rxnObj.flipDirection();
      rxnObj.RateCoef = rxnObj.parseRateLinkNode(rateDataLink);
   end
   rxnObj.setRKeq();
   rxnObj.setThermo(rs.Species);
   rxnListObj = rxnListObj.add(rxnObj);
end
close(Hwait);

rs.Reactions = rxnListObj;

additionalData = modelDoc.GetElementsByTagName('additionalDataItem');
len = double(additionalData.Count);
if len > 0
   adata = rs.AdditionalData;
   for i1 = 1:len
      dataItem = additionalData.Item(i1-1);
      adata(i1).itemType = char(dataItem.GetAttribute('itemType'));
      adata(i1).description = char(dataItem.GetAttribute('description'));
      adata(i1).content = char(dataItem.InnerText);
   end
   rs.AdditionalData = adata;
end