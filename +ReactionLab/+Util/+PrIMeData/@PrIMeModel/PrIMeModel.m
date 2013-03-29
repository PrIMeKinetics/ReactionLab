classdef PrIMeModel < handle
   
% Copyright (c) 1999-2013 Michael Frenklach
% Last modified: March 28, 2013

   properties (SetAccess = private)
      XmlAssembly  = NET.addAssembly('System.Xml');
      PWAcomponent = [];
      SourceIndex  = [];    % 1 - load from warehouse; 2 - local
      LocalDirPath = '';
      DocIn        = [];
      
      PrimeId      = '';
      Title        = '';
      CatalogFile  = [];
      
      RSdoc        = [];
      RSfile       = [];
      RSobj        = [];   % ReactionSet object
      
      H5file       = [];
   end
   
   methods
      function obj = PrIMeModel(arg)
         if nargin > 0
            if isa(arg,'Component')
               obj.PWAcomponent = arg;
               obj.DocIn        = arg.DocIn;
               obj.LocalDirPath = arg.OutputDirectory;
               obj.SourceIndex  = arg.getSelectedOption('Model Source');
            elseif isa(arg,'System.Xml.XmlDocument')
               obj.DocIn = arg;
            elseif ischar(arg)   % model primeId
               obj.PrimeId = arg;
               obj.CatalogFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId);
            else
               error(['incorrect object class ' class(arg)])
            end
         end
      end
      
      function setIdFromXml(obj,docRS)
         obj.RSdoc = docRS;
         docRoot = docRS.DocumentElement;
         obj.PrimeId = strtrim(char(docRoot.GetAttribute('primeID')));
         preferredKey = docRoot.GetElementsByTagName('preferredKey').Item(0);
         key = strtrim(char(preferredKey.InnerText));
         obj.Title = lower(key(isstrprop(key,'alphanum')));
         obj.CatalogFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId);
      end
      
      function setRS(obj)
         % check if ReactionSet object does not exist or not current in Warehouse 
         %     and create it from RSdoc and update, both .mat and .h5 files
         file = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId,'.mat');
         if file.Exist
            if obj.areDatesMatch(file)  % check if .mat is current - matches the catalog file
               obj.downloadBinary(file);
            else
               obj.rsFromXml(1);
               obj.h5FromRS();  % update the H5 file also
            end
         else
            obj.rsFromXml(0);
            obj.h5FromRS();  % update the H5 file also
         end
      end
      
      function y = areDatesMatch(obj,wFile)
         NET.addAssembly('System');
         DT = System.DateTime();
         df1 = obj.CatalogFile.getProperty('getlastmodified');
         b1 = DT.Parse(df1);
         df2 = wFile.getProperty('cataloglastmodified');
         if isempty(df2)
            y = 0;
         else
            b2 = DT.Parse(df2);
            y = b1.Equals(b2);
         end
      end
      
      function rsFromXml(obj,doesFileExist)
         obj.RSobj = ReactionLab.ModelData.ReactionSet(obj.RSdoc);
         localFilePath = fullfile(obj.LocalDirPath,[obj.PrimeId '.mat']);
         rs = obj.RSobj;
         save(localFilePath,'rs');
         if file.isAuthorized
            if doesFileExist
               file.deletefile(1);
            end
            file.uploadfile(localFilePath,'new',1);
         end
      end
      
      function downloadBinary(obj,matFile)
         matFile.download(obj.LocalDirPath,1);
         s = load(obj.LocalDirPath);
         f = filenames(s);
         obj.RSobj = s.(f{1});
         whFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId,'.h5');
         whFile.download(obj.LocalDirPath,1);
      end
      
      function h5FromRS(obj)
         whFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId,'.h5');
         localFilePath = fullfile(obj.LocalDirPath,[obj.PrimeId '.h5']);
         obj.RSobj.hdf5write(localFilePath);
         if whFile.isAuthorized
            if whFile.Exist
               file.deletefile(1);
            end
            file.uploadfile(localFilePath,'new',1);
         end
      end
      
      function loadDOM(obj)
         docRS = ReactionLab.Util.gate2primeData('getDOM',{'primeId',obj.PrimeId});
         obj.getIdFromXml(docRS);
      end
      
%  may be for later
%       function rsFromH5(obj)
%          whFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId,'.h5');
%          localFilePath = fullfile(obj.LocalDirPath,[obj.PrimeId '.h5']);
%          
%          captionStruc = hdf5read(filePath,'/title');
% 
%          obj = ReactionLab.Util.PrIMeData.PrIMeModel(primeId);
%          obj.setIdFromH5();
%       end
   end
    
end