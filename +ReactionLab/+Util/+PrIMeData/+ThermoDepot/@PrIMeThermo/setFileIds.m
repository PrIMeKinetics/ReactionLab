function setFileIds(obj)
% setFuleIds(PrIMeThermoObj)
%
% find
%      if the data directory exists
%      if the th00000000 file exit
%      data files
%      best current data file

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: July 30, 2011

wLink = ReactionLab.Util.PrIMeData.WarehouseLink();
conn = wLink.conn;

% data directory for given species
dirPath = ['depository/species/data/' obj.SpeciesId];
a = conn.Exist(dirPath);
if a.result == 1  %  data directory exists
   obj.isDataDir = 1;
else
   obj.isDataDir = 0;
   return
end

% th00000000 file
filePath = [dirPath '/th00000000.xml'];
a2 = conn.Exist(filePath);
if a2.result == 1  % th00000000.xml exists
   obj.isTh0 = 1;
else
   obj.isTh0 = 0;
end
   
% polynomial data files
obj.PolynomialFileIds = strtok(ReactionLab.Util.gate2primeData(...
                    'getDataFileList',{'primeID',obj.SpeciesId,'thp'}),'.xml');

% set the index of the best-current file if exist
if obj.isTh0
   bcId = ReactionLab.Util.gate2primeData(...
          'getBestCurrentId',{'primeID',obj.SpeciesId,'th'});
   obj.BestCurrentIndex = find(strcmp(obj.PolynomialFileIds,bcId));
end