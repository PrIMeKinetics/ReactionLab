classdef PrIMeDataset < ReactionLab.Util.PrIMeData.PrIMeModel
   
% Copyright (c) 1999-2013 Michael Frenklach
%       Created: April  7, 2013, myf
% Last modified: April 15, 2013, myf

   properties (Dependent = true)
      ModelPrimeId
      ModelObj
   end

   
   methods
      function xml2mat(obj)
         obj.MatObj = ReactionLab.ModelData.Dataset(obj.Doc);
      end
      
      function y = get.ModelPrimeId(obj)
         y = obj.MatObj.ReactionModelId;
      end
      
      function y = get.ModelObj(obj)
         modelObj = ReactionLab.Util.PrIMeData.PrIMeModel(obj.PWAcomponent);
         y = modelObj.MatObj;
      end
      
      function updateWHfile(obj,type,doesFileExist)
         switch lower(type)
            case {'mat' '.mat'}
               whFile    = obj.MatFileWH;
               localFile = obj.MatFileLocal;
            case {'h5' '.h5' 'hdf' '.hdf' 'hdf5' '.hdf5'}
               whFile    = obj.H5fileWH;
               localFile = obj.H5pathLocal;
         end
         if whFile.isAuthorized
            if doesFileExist
               whFile.replacefile(1);
            else
               dirPath = fileparts(whFile.FilePath);
               whFile.makedir(dirPath);
               whFile.uploadfile(localFile,'new',1);
            end
            dateVal = obj.CatalogFile.getProperty('getlastmodified');
            whFile.setProperty('cataloglastmodified',dateVal);
         end
      end
      
      
   end
   
end