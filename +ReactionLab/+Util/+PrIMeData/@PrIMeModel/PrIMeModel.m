classdef PrIMeModel < handle
   
% Copyright 1999-2013 Michael Frenklach
% Last modified: March 26, 2013

   properties (SetAccess = private)
      PWAcomponent = [];
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
               obj.DocIn = arg.DocIn;
               obj.LocalDirPath = arg.OutputDirectory;
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
      
      function indSource = getOption(obj,option)
         modelSourceNode   = obj.getnode(obj.docIn,'list','description',option);
         modelSourceOption = obj.getnode(modelSourceNode,'option','selected','true');
         indSource = char(modelSourceOption.GetAttribute('value'));
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
      
      function fileObj = getFile(obj,fileType)
         %    fileType = '.mat'  or  '.hdf5'
         % load/create ReactionSet or HDF5 of RSdoc
         % first check if file exists already in Warehouse
         file = ReactionLab.Util.PrIMeData.WarehouseFile('','',[obj.PrimeId fileType]);
         if file.Exist
            if obj.areDatesMatch(file)
               file.download(obj.LocalDirPath,1);
            else
               localFilePath = obj.createFile(fileType);
               if file.isAuthorized
                  file.replace(localFilePath,'update',1);
               end
            end
         else
            localFilePath = obj.createFile(fileType);
            if file.isAuthorized
               file.upload(localFilePath,'new',1);
            end
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
      
      function loadDOM(obj)
         docRS = ReactionLab.Util.gate2primeData('getDOM',{'primeId',obj.PrimeId});
         obj.getFromXml(docRS);
      end
      
      function localFilePath = createFile(obj,fileExt)
         if isempty(obj.RSobj)
            obj.RSobj = ReactionLab.ModelData.ReactionSet(obj.RSdoc);
         end
         localFilePath = fullfile(obj.LocalDirPath,[obj.PrimeId fileExt]);
         if strcmpi(fileExt,'.mat')
            f = obj.RSobj;
         elseif strcmpi(fileExt,'.hdf5')
            obj.RSobj.hdf5write(localFilePath);
            save(localFilePath,'f');
         else
            error(['undefined file ext: ' fileExt]);
         end
      end
   end
    
end