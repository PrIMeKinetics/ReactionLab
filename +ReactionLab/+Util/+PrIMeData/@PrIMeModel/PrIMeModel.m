classdef PrIMeModel < handle
   
% Copyright (c) 1999-2015 Michael Frenklach
%  Created: March 2013, myf
% Modified:   April  8, 2013, myf
% Modified: Jenuary  5, 2015, myf
% Modified:    JUne  8, 2015, myf: commented out "deletefile"

   properties
      XmlAssembly  = NET.addAssembly('System.Xml');
      PWAcomponent = [];
      SourceIndex  = [];   % 1 - load from warehouse; 2 - local
      LocalDirPath = '';
      DocIn        = [];   % input from PWA
      
      PrimeId      = '';
      Title        = '';
      CatalogFile  = [];   % file obj of XML catalog file 
      Doc          = [];   % XmlDocument of MatObj
      
      MatObj       = [];   % object (ReactionSet)
      MatFileWH    = [];   % file object of MatObj in warehouse
      MatFileLocal = '';   % path to local mat file
      H5fileWH     = [];   % file obj of HDF5 in warehouse
      H5pathLocal  = '';   % path to local HDF5 file
   end
   
   methods
      function obj = PrIMeModel(arg)
         if nargin > 0
            if isa(arg,'Component')   % PWA Component object
               obj.PWAcomponent = arg;
               obj.DocIn        = arg.DocIn;
               obj.LocalDirPath = arg.OutputDirectory;
               obj.SourceIndex  = arg.getSelectedOption('Source');
            else
               error(['incorrect object class ' class(arg)])
            end
         end
      end
      
      function y = get.MatObj(obj)
         if isempty(obj.MatObj)
            obj.setMat();
            s = load(obj.MatFileLocal);
            f = fieldnames(s);
            obj.MatObj = s.(f{1});
         end
         y = obj.MatObj;
      end
      
      function y = get.H5pathLocal(obj)
         if isempty(obj.H5pathLocal)
            obj.setH5();
         end
         y = obj.H5pathLocal;
      end
      
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
         obj.H5fileWH    = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId,'.hdf');
         obj.MatFileLocal = fullfile(obj.LocalDirPath,[obj.PrimeId '.mat']);
         obj.H5pathLocal  = fullfile(obj.LocalDirPath,[obj.PrimeId '.h5']);
      end
      
      function xml2mat(obj)
         obj.MatObj = ReactionLab.ModelData.ReactionSet(obj.Doc);
      end
      
      function setMat(obj)
         % if mat file does not exist or is not current in Warehouse,
         %     create it from Doc and update
         % check if .mat is current - matches with the catalog file
         if obj.MatFileWH.exist
            if obj.areDatesMatch(obj.MatFileWH)
               obj.downloadMat();
            else
               obj.matFromXml(1);
            end
         else
            obj.matFromXml(0);
         end
      end
      
      function setH5(obj)
         % if h5 file does not exist or is not current in Warehouse,
         %     create it from mat and update
         % check if .h5 is current - matches with the catalog file
         if obj.H5fileWH.exist
            if obj.areDatesMatch(obj.H5fileWH)  
               obj.downloadH5();
            else
               obj.h5fromMat(1);
            end
         else
            obj.h5fromMat(0);
         end
      end
      
      function y = areDatesMatch(obj,whFile)
         NET.addAssembly('System');
         DT = System.DateTime();
         df1 = obj.CatalogFile.getProperty('getlastmodified');
         b1 = DT.Parse(df1);
         df2 = whFile.getProperty('cataloglastmodified');
         if isempty(df2)
            y = 0;
         else
            b2 = DT.Parse(df2);
            y = b1.Equals(b2);
         end
      end
      
      function downloadMat(obj)
         obj.MatFileWH.download(obj.LocalDirPath);
      end
      
      function downloadH5(obj)
         hdfFilePath = obj.H5fileWH.download(obj.LocalDirPath);
         copyfile(hdfFilePath,obj.H5pathLocal);
         delete(hdfFilePath);
      end
      
      function matFromXml(obj,doesFileExist)
         obj.xml2mat();
         matObj = obj.MatObj; %#ok<NASGU>
         save(obj.MatFileLocal,'matObj');
         obj.updateWHfile('mat',doesFileExist);
      end
      
      function h5fromMat(obj,doesFileExist)
         if isempty(obj.MatObj)
            obj.MatObj();
         end
         obj.MatObj.hdf5write(obj.H5pathLocal);
         updateWHfile(obj,'h5',doesFileExist);
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
%                whFile.deletefile(1);
            else
               dirPath = fileparts(whFile.FilePath);
               whFile.makedir(dirPath);
            end
            whFile.uploadfile(localFile,'new',1);
            dateVal = obj.CatalogFile.getProperty('getlastmodified');
            whFile.setProperty('cataloglastmodified',dateVal);
         end
      end
   end
end