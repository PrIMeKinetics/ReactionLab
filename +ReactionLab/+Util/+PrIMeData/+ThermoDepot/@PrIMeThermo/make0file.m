function th0Doc = make0file(obj,dataFileId)
% th0Doc = make0file(PrIMeThermoObj,dataFilePrimeId)
%
%  make th00000000 XmlDument file, point it to dataFileId
%    and validate

% Copyright 1999-2013 Michael Frenklach
% Last modified: December 9, 2012

NET.addAssembly('System.Xml');
import System.Xml.*;
wLink = ReactionLab.Util.PrIMeData.WarehouseLink();

% thpId = strtok(dataFileId,'.xml');
thpDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeID',obj.SpeciesId,dataFileId});
key = char(thpDoc.GetElementsByTagName('speciesLink').Item(0).GetAttribute('preferredKey'));

th0Doc = XmlDocument;
th0Doc.Load(which('+ReactionLab/+Util/+PrIMeData/+ThermoDepot/th00000000_template.xml'));
speNode = th0Doc.GetElementsByTagName('speciesLink').Item(0);
speNode.SetAttribute('preferredKey',key);
speNode.SetAttribute('primeID',obj.SpeciesId);

thLinkNode = th0Doc.GetElementsByTagName('thermodynamicDataLink').Item(0);
thLinkNode.SetAttribute('type','nasa7');
thLinkNode.SetAttribute('primeID',dataFileId);

if ~wLink.validateXml(th0Doc)
   error(['cannot validate th00000000 for ' obj.SpeciesId '/' dataFileId]);
end