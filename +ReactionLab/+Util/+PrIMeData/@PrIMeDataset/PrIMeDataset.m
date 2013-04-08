classdef PrIMeDataset < ReactionLab.Util.PrIMeData.PrIMeModel
   
% Copyright (c) 1999-2013 Michael Frenklach
%       Created: April 7, 2013, myf
% Last modified: April 7, 2013, myf

   properties
      ModelPrimeId = '';
      ModelObj     = [];
   end
   
   methods
      
      function setIdFromXml(obj,doc)
         obj.Doc = doc;
         docRoot = doc.DocumentElement;
         obj.PrimeId = strtrim(char(docRoot.GetAttribute('primeID')));
         obj.CatalogFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId);
         obj.commonSettings();
      end
      
      function setFromPrimeId(obj,primeId)
         obj.PrimeId = primeId;
         obj.CatalogFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId);
         obj.Doc = obj.CatalogFile.loadXml();
         obj.commonSettings();
      end
      
      function commonSettings(obj)
         docRoot = obj.Doc.DocumentElement;
         preferredKey = docRoot.GetElementsByTagName('preferredKey').Item(0);
         key = strtrim(char(preferredKey.InnerText));
         obj.Title = lower(key(isstrprop(key,'alphanum')));
         obj.MatFileWH   = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId,'.mat');
%          obj.H5fileWH    = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId,'.h5');
         obj.H5fileWH    = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId,'.txt');
         obj.MatFileLocal = fullfile(obj.LocalDirPath,[obj.PrimeId '.mat']);
         obj.H5pathLocal  = fullfile(obj.LocalDirPath,[obj.PrimeId '.h5']);
      end
      
      function xml2mat(obj)
      % specific to ReactionSet; need to be overloaded in derived classes
         obj.MatObj = ReactionLab.ModelData.ReactionSet(obj.Doc);
      end
      
   end
end